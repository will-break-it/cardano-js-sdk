/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionBody } from '../../../src/Serialization';
import { mintTokenMap, params, txIn, txOut } from './testData';

// Test data used in the following tests was generated with the cardano-serialization-lib

const cbor = HexBlob(
  'b100818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000181825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc820aa3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c411832581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e020a031903e804828304581c26b17b78de4f035dc0bfce60d1d3c3a8085c38dcce5fb8767e518bed1901f48405581c0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4581ca646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a582003170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c11131405a2581de013cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d005581de0404b5a4088ae9abcf486a7e7b8f82069e6fcfe1bf226f1851ce72570030682a3581c00000000000000000000000000000000000000000000000000000001b60018640118c80219012c03190190041901f4051a001e8480061a0bebc200071903200819038409d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e820103101903e8111988b812a10098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b0000000100000000161903ba581c00000000000000000000000000000000000000000000000000000002b60018640118c80219012c03190190041901f4051a001e8480061a0bebc200071903200819038409d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e820103101903e8111988b812a10098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b0000000100000000161903ba581c00000000000000000000000000000000000000000000000000000003b60018640118c80219012c03190190041901f4051a001e8480061a0bebc200071903200819038409d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e820103101903e8111988b812a10098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b0000000100000000161903ba19020b0758202ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa08186409a3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c413831581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e0b58206199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de0d818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5010e81581c6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d390f0110825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc820aa3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c411832581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e11186412818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d500'
);

const conwayCbor = HexBlob(
  'b500818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000181825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc820aa3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c411832581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e020a031903e804828304581c26b17b78de4f035dc0bfce60d1d3c3a8085c38dcce5fb8767e518bed1901f48405581c0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4581ca646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a582003170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c11131405a2581de013cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d005581de0404b5a4088ae9abcf486a7e7b8f82069e6fcfe1bf226f1851ce72570030682a3581c00000000000000000000000000000000000000000000000000000001b60018640118c80219012c03190190041901f4051a001e8480061a0bebc200071903200819038409d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e820103101903e8111988b812a10098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b0000000100000000161903ba581c00000000000000000000000000000000000000000000000000000002b60018640118c80219012c03190190041901f4051a001e8480061a0bebc200071903200819038409d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e820103101903e8111988b812a10098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b0000000100000000161903ba581c00000000000000000000000000000000000000000000000000000003b60018640118c80219012c03190190041901f4051a001e8480061a0bebc200071903200819038409d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e820103101903e8111988b812a10098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b0000000100000000161903ba19020b0758202ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa08186409a3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c413831581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e0b58206199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de0d818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5010e81581c6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d390f0110825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc820aa3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c411832581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e11186412818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d50013a28202581c10000000000000000000000000000000000000000000000000000000a38258201000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258202000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258203000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008203581c20000000000000000000000000000000000000000000000000000000a28258201000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258203000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000001481841a000f4240581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f830582582000000000000000000000000000000000000000000000000000000000000000000382827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000f6827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000151907d0161903e8'
);

export const core: Cardano.TxBody = {
  auxiliaryDataHash: Crypto.Hash32ByteBase16('2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'),
  certificates: [
    {
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: Cardano.EpochNo(500),
      poolId: Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc')
    },
    {
      __typename: Cardano.CertificateType.GenesisKeyDelegation,
      genesisDelegateHash: Crypto.Hash28ByteBase16('a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a'),
      genesisHash: Crypto.Hash28ByteBase16('0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4'),
      vrfKeyHash: Crypto.Hash32ByteBase16('03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c111314')
    }
  ],
  collateralReturn: txOut,
  collaterals: [{ ...txIn, index: txIn.index + 1 }],
  fee: 10n,
  inputs: [txIn],
  mint: mintTokenMap,
  networkId: Cardano.NetworkId.Mainnet,
  outputs: [txOut],
  referenceInputs: [txIn],
  requiredExtraSignatures: [Crypto.Ed25519KeyHashHex('6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d39')],
  scriptIntegrityHash: Crypto.Hash32ByteBase16('6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de'),
  totalCollateral: 100n,
  update: {
    epoch: Cardano.EpochNo(523),
    proposedProtocolParameterUpdates: new Map([
      ['00000000000000000000000000000000000000000000000000000001', params],
      ['00000000000000000000000000000000000000000000000000000002', params],
      ['00000000000000000000000000000000000000000000000000000003', params]
    ]) as Cardano.ProposedProtocolParameterUpdates
  } as Cardano.Update,
  validityInterval: {
    invalidBefore: Cardano.Slot(100),
    invalidHereafter: Cardano.Slot(1000)
  },
  withdrawals: [
    {
      quantity: 3n,
      stakeAddress: Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv')
    },
    {
      quantity: 5n,
      stakeAddress: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
    }
  ]
};

export const conwayCore: Cardano.TxBody = {
  ...core,
  donation: 1000n,
  proposalProcedures: [
    {
      anchor: {
        dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
        url: 'https://www.someurl.io'
      },
      deposit: 1_000_000n,
      governanceAction: {
        __typename: Cardano.GovernanceActionType.new_constitution,
        constitution: {
          anchor: {
            dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
            url: 'https://www.someurl.io'
          },
          scriptHash: null
        },
        governanceActionId: {
          actionIndex: 3,
          id: '0000000000000000000000000000000000000000000000000000000000000000'
        }
      },
      rewardAccount: 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'
    } as Cardano.ProposalProcedure
  ],
  treasuryValue: 2000n,
  votingProcedures: [
    {
      voter: {
        __typename: 'dRepKeyHash',
        credential: {
          hash: '10000000000000000000000000000000000000000000000000000000',
          type: 0
        }
      },
      votes: [
        {
          actionId: {
            actionIndex: 3,
            id: '1000000000000000000000000000000000000000000000000000000000000000'
          },
          votingProcedure: {
            anchor: {
              dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
              url: 'https://www.someurl.io'
            },
            vote: 0
          }
        },
        {
          actionId: {
            actionIndex: 3,
            id: '2000000000000000000000000000000000000000000000000000000000000000'
          },
          votingProcedure: {
            anchor: {
              dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
              url: 'https://www.someurl.io'
            },
            vote: 0
          }
        },
        {
          actionId: {
            actionIndex: 3,
            id: '3000000000000000000000000000000000000000000000000000000000000000'
          },
          votingProcedure: {
            anchor: {
              dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
              url: 'https://www.someurl.io'
            },
            vote: 0
          }
        }
      ]
    },
    {
      voter: {
        __typename: 'dRepScriptHash',
        credential: {
          hash: '20000000000000000000000000000000000000000000000000000000',
          type: 1
        }
      },
      votes: [
        {
          actionId: {
            actionIndex: 3,
            id: '1000000000000000000000000000000000000000000000000000000000000000'
          },
          votingProcedure: {
            anchor: {
              dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
              url: 'https://www.someurl.io'
            },
            vote: 0
          }
        },
        {
          actionId: {
            actionIndex: 3,
            id: '3000000000000000000000000000000000000000000000000000000000000000'
          },
          votingProcedure: {
            anchor: {
              dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
              url: 'https://www.someurl.io'
            },
            vote: 0
          }
        }
      ]
    }
  ] as Cardano.VotingProcedures
};

describe('TransactionBody', () => {
  const canonicallySortedWithdrawals = [
    {
      quantity: 5n,
      stakeAddress: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
    },
    {
      quantity: 3n,
      stakeAddress: 'stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv'
    }
  ];
  const expectedCore = {
    ...core,
    withdrawals: canonicallySortedWithdrawals
  };

  const expectedConwayCore = {
    ...conwayCore,
    withdrawals: canonicallySortedWithdrawals
  };

  it('can encode TransactionBody to CBOR', () => {
    const body = TransactionBody.fromCore(core);

    expect(body.toCbor()).toEqual(cbor);
  });

  it('can encode TransactionBody to Core', () => {
    const body = TransactionBody.fromCbor(cbor);

    expect(body.toCore()).toEqual(expectedCore);
  });

  it('can encode conway TransactionBody to CBOR', () => {
    const body = TransactionBody.fromCore(conwayCore);

    expect(body.toCbor()).toEqual(conwayCbor);
  });

  it('can encode conway TransactionBody to Core', () => {
    const body = TransactionBody.fromCbor(conwayCbor);

    expect(body.toCore()).toEqual(expectedConwayCore);
  });

  it('sorts withdrawals canonically', () => {
    const body = TransactionBody.fromCbor(cbor);
    const withdrawals = body.withdrawals();
    const expectedWithdrawals = new Map();
    for (const withdrawal of canonicallySortedWithdrawals) {
      expectedWithdrawals.set(withdrawal.stakeAddress, withdrawal.quantity);
    }

    expect(withdrawals).toEqual(expectedWithdrawals);
  });
});
