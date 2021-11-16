/* eslint-disable max-len */
import { Asset, CSL, Cardano, coreToCsl } from '../../src';

const txIn: Cardano.TxIn = {
  address:
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
  index: 0,
  txId: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
};
const txOut: Cardano.TxOut = {
  address:
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
  value: {
    assets: {
      '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740': 20n,
      '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41': 50n
    },
    coins: 10n
  }
};

const coreTxBody: Cardano.TxBodyAlonzo = {
  certificates: [
    {
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: 500,
      poolId: 'pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc'
    }
  ],
  fee: 10n,
  inputs: [txIn],
  outputs: [txOut],
  validityInterval: {
    invalidBefore: 100,
    invalidHereafter: 1000
  },
  withdrawals: [
    {
      quantity: 5n,
      stakeAddress: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
    }
  ]
};

describe('coreToCsl', () => {
  it('txIn', () => {
    expect(coreToCsl.txIn(txIn)).toBeInstanceOf(CSL.TransactionInput);
  });
  it('txOut', () => {
    expect(coreToCsl.txOut(txOut)).toBeInstanceOf(CSL.TransactionOutput);
  });
  it('utxo', () => {
    expect(coreToCsl.utxo([[txIn, txOut]])[0]).toBeInstanceOf(CSL.TransactionUnspentOutput);
  });
  describe('value', () => {
    it('coin only', () => {
      const quantities = { coins: 100_000n };
      const value = coreToCsl.value(quantities);
      expect(value.coin().to_str()).toEqual(quantities.coins.toString());
      expect(value.multiasset()).toBeUndefined();
    });
    it('coin with assets', () => {
      const value = coreToCsl.value(txOut.value);
      expect(value.coin().to_str()).toEqual(txOut.value.coins.toString());
      const multiasset = value.multiasset()!;
      expect(multiasset.len()).toBe(2);
      for (const assetId in txOut.value.assets) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
        const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
        expect(assetQuantity).toBe(txOut.value.assets[assetId]);
      }
      expect(value).toBeInstanceOf(CSL.Value);
    });
  });
  it('txBody', () => {
    const cslBody = coreToCsl.txBody(coreTxBody);
    expect(cslBody.certs()?.get(0).as_pool_retirement()?.epoch()).toBe(500);
    expect(cslBody.fee().to_str()).toBe(coreTxBody.fee.toString());
    expect(Buffer.from(cslBody.inputs().get(0).transaction_id().to_bytes()).toString('hex')).toBe(
      coreTxBody.inputs[0].txId
    );
    expect(cslBody.outputs().get(0).amount().coin().to_str()).toBe(coreTxBody.outputs[0].value.coins.toString());
    expect(cslBody.validity_start_interval()).toBe(coreTxBody.validityInterval.invalidBefore);
    expect(cslBody.ttl()).toBe(coreTxBody.validityInterval.invalidHereafter);
    expect(cslBody.withdrawals()?.get(cslBody.withdrawals()!.keys().get(0)!)?.to_str()).toBe(
      coreTxBody.withdrawals![0].quantity.toString()
    );
  });
  it('tx', () => {
    const vkey = 'ed25519_pk1dgaagyh470y66p899txcl3r0jaeaxu6yd7z2dxyk55qcycdml8gszkxze2';
    const signature =
      'bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755';
    const coreTx: Cardano.NewTxAlonzo = {
      body: coreTxBody,
      id: 'doesnt-matter',
      witness: {
        signatures: {
          [vkey]: signature
        }
      }
    };
    const cslTx = coreToCsl.tx(coreTx);
    expect(cslTx.body()).toBeInstanceOf(CSL.TransactionBody);
    const witness = cslTx.witness_set().vkeys()!.get(0)!;
    expect(witness.vkey().public_key().to_bech32()).toBe(vkey);
    expect(witness.signature().to_hex()).toBe(signature);
  });
});
