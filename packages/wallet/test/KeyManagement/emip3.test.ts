import { createPbkdf2Key, emip3decrypt, emip3encrypt } from '../../src/KeyManagement';

describe('emip3', () => {
  it('decrypting encrypted value results in original unencrypted value', async () => {
    const unencryptedHex = '123abc';
    const password = Buffer.from('password');
    const encrypted = await emip3encrypt(Buffer.from(unencryptedHex, 'hex'), password);
    expect(Buffer.from(encrypted).toString('hex')).not.toEqual(unencryptedHex);
    const decrypted = await emip3decrypt(encrypted, password);
    expect(Buffer.from(decrypted!).toString('hex')).toEqual(unencryptedHex);
  });

  it('createPbkdf2Key implementation is aligned with Rust cryptoxide', async () => {
    const password = Buffer.from('Cardano Rust for the winners!', 'utf-8');
    const salt = new Uint8Array([
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1
    ]);
    const rustKey = '200a09ed78c49e029a3a47e759e6eb4f4da7eac47421b0c0959aed2b9af2a6aa';
    const key = await createPbkdf2Key(password, salt);
    expect(key.toString('hex')).toEqual(rustKey);
  });
});
