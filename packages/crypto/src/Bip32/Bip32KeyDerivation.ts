import { BN } from 'bn.js';
import { InvalidArgumentError } from '../errors';
import { crypto_auth_hmacsha512, crypto_scalarmult_ed25519_base_noclamp } from 'libsodium-wrappers-sumo';
import { eddsa } from 'elliptic';

const ed25519 = new eddsa('ed25519');

/**
 * Check if the index is hardened.
 *
 * @param index The index to verify.
 * @returns true if hardened; otherwise; false.
 */
const isHardenedDerivation = (index: number) => index >= 0x80_00_00_00;

/**
 * Derives the private key with a hardened index.
 *
 * @param index The derivation index.
 * @param scalar Ed25519 curve scalar.
 * @param iv Ed25519 binary blob used as IV for signing.
 * @param chainCode The chain code.
 */
const deriveHardened = (
  index: number,
  scalar: Buffer,
  iv: Buffer,
  chainCode: Buffer
): { zMac: Uint8Array; ccMac: Uint8Array } => {
  const data = Buffer.allocUnsafe(1 + 64 + 4);
  data.writeUInt32LE(index, 1 + 64);
  scalar.copy(data, 1);
  iv.copy(data, 1 + 32);

  data[0] = 0x00;
  const zMac = crypto_auth_hmacsha512(data, chainCode);
  data[0] = 0x01;
  const ccMac = crypto_auth_hmacsha512(data, chainCode);

  return { ccMac, zMac };
};

/**
 * Derives the private key with a 'soft' index.
 *
 * @param index The derivation index.
 * @param scalar Ed25519 curve scalar.
 * @param chainCode The chain code.
 */
const deriveSoft = (index: number, scalar: Buffer, chainCode: Buffer): { zMac: Uint8Array; ccMac: Uint8Array } => {
  const data = Buffer.allocUnsafe(1 + 32 + 4);
  data.writeUInt32LE(index, 1 + 32);

  const vk = Buffer.from(crypto_scalarmult_ed25519_base_noclamp(scalar));

  vk.copy(data, 1);

  data[0] = 0x02;
  const zMac = crypto_auth_hmacsha512(data, chainCode);
  data[0] = 0x03;
  const ccMac = crypto_auth_hmacsha512(data, chainCode);

  return { ccMac, zMac };
};

/**
 * Adds the left hand side to 28 bytes of the right hand side and multiplies the result by 8.
 *
 * @param lhs Left hand side Little-Endian big number.
 * @param rhs Right hand side Little-Endian big number.
 */
const truc28Mul8 = (lhs: Uint8Array, rhs: Uint8Array): Buffer =>
  new BN(lhs, 16, 'le').add(new BN(rhs.slice(0, 28), 16, 'le').mul(new BN(8))).toArrayLike(Buffer, 'le', 32);

/**
 * Computes `(8 * sk[:28])*G` where `sk` is a little-endian encoded int and `G` is the curve's base point.
 *
 * @param sk The secret key.
 */
const pointOfTrunc28Mul8 = (sk: Uint8Array) => {
  const left = new BN(sk.slice(0, 28), 16, 'le').mul(new BN(8));
  return ed25519.curve.g.mul(left);
};

/**
 * Adds the left hand side to the right hand side.
 *
 * @param lhs Left hand side Little-Endian big number.
 * @param rhs Right hand side Little-Endian big number.
 */
const add = (lhs: Uint8Array, rhs: Uint8Array): Buffer => {
  let r = new BN(lhs, 16, 'le').add(new BN(rhs, 16, 'le')).toArrayLike(Buffer, 'le').subarray(0, 32);

  if (r.length !== 32) {
    r = Buffer.from(r.toString('hex').padEnd(32, '0'), 'hex');
  }

  return r;
};

/**
 * Derive the given private key with the given index.
 *
 * # Security considerations
 *
 * hard derivation index cannot be soft derived with the public key.
 *
 * # Hard derivation vs Soft derivation
 *
 * If you pass an index below 0x80000000 then it is a soft derivation.
 * The advantage of soft derivation is that it is possible to derive the
 * public key too. I.e. derivation the private key with a soft derivation
 * index and then retrieving the associated public key is equivalent to
 * deriving the public key associated to the parent private key.
 *
 * Hard derivation index does not allow public key derivation.
 *
 * This is why deriving the private key should not fail while deriving
 * the public key may fail (if the derivation index is invalid).
 *
 * @param key The parent key to be derived.
 * @param index The derivation index.
 * @returns The child BIP32 key.
 */
export const derivePrivate = (key: Buffer, index: number): Buffer => {
  const kl = key.subarray(0, 32);
  const kr = key.subarray(32, 64);
  const cc = key.subarray(64, 96);

  const { ccMac, zMac } = isHardenedDerivation(index) ? deriveHardened(index, kl, kr, cc) : deriveSoft(index, kl, cc);

  const chainCode = ccMac.slice(32, 64);
  const zl = zMac.slice(0, 32);
  const zr = zMac.slice(32, 64);

  const left = truc28Mul8(kl, zl);
  const right = add(kr, zr);

  return Buffer.concat([left, right, chainCode]);
};

/**
 * Derive the given public key with the given index.
 *
 * Public key derivation is only possible with non-hardened indices.
 *
 * @param key The parent key to be derived.
 * @param index The derivation index.
 * @returns The child BIP32 key.
 */
export const derivePublic = (key: Buffer, index: number): Buffer => {
  const pk = key.subarray(0, 32);
  const cc = key.subarray(32, 64);

  const data = Buffer.allocUnsafe(1 + 32 + 4);
  data.writeUInt32LE(index, 1 + 32);

  if (isHardenedDerivation(index))
    throw new InvalidArgumentError('index', 'Public key can not be derived from a hardened index.');

  pk.copy(data, 1);
  data[0] = 0x02;
  const z = crypto_auth_hmacsha512(data, cc);
  data[0] = 0x03;
  const c = crypto_auth_hmacsha512(data, cc);

  const chainCode = c.slice(32, 64);
  const zl = z.slice(0, 32);

  const p = pointOfTrunc28Mul8(zl);
  const pp = ed25519.decodePoint(pk.toString('hex'));
  const point = pp.add(p);

  return Buffer.concat([Buffer.from(ed25519.encodePoint(point)), chainCode]);
};
