import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import {
  AccountKeyDerivationPath,
  AddressType,
  CardanoKeyConst,
  GroupedAddress,
  KeyRole,
  TxInId,
  TxInKeyPathMap,
  util
} from '@cardano-sdk/key-management';
import {
  CONTEXT_WITHOUT_KNOWN_ADDRESSES,
  CONTEXT_WITH_KNOWN_ADDRESSES,
  poolId,
  poolId2,
  poolParameters,
  stakeCredential
} from '../testData';
import { Cardano } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { LedgerTxTransformerContext } from '../../src';
import { getKnownAddress, mapCerts } from '../../src/transformers/certificates';

export const stakeKeyPath = {
  index: 0,
  role: KeyRole.Stake
};
const createGroupedAddress = (
  address: Cardano.PaymentAddress,
  rewardAccount: Cardano.RewardAccount,
  type: AddressType,
  index: number,
  stakeKeyDerivationPath: AccountKeyDerivationPath
): GroupedAddress =>
  ({
    address,
    index,
    rewardAccount,
    stakeKeyDerivationPath,
    type
  } as GroupedAddress);

const createChainId = (networkId: number, networkMagic: number): Cardano.ChainId =>
  ({
    networkId,
    networkMagic
  } as Cardano.ChainId);

const ownRewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
const address1 = Cardano.PaymentAddress(
  'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
);
const address2 = Cardano.PaymentAddress(
  'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
);

export const createTxInKeyPathMapMock = (knownAddresses: GroupedAddress[]): TxInKeyPathMap => {
  const result: TxInKeyPathMap = {};
  for (const [index, address] of knownAddresses.entries()) {
    const txInId: TxInId = `MockTxIn_${index}` as TxInId; // Mock TxInId creation
    result[txInId] = {
      index: address.index,
      role: KeyRole.Internal
    };
  }
  return result;
};

const mockContext: LedgerTxTransformerContext = {
  accountIndex: 0,
  chainId: createChainId(1, 764_824_073),
  dRepPublicKey: undefined,

  handleResolutions: [],

  knownAddresses: [
    createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0, stakeKeyPath),
    createGroupedAddress(address2, ownRewardAccount, AddressType.External, 1, stakeKeyPath)
  ],
  sender: undefined,
  txInKeyPathMap: createTxInKeyPathMapMock([
    createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0, stakeKeyPath),
    createGroupedAddress(address2, ownRewardAccount, AddressType.External, 1, stakeKeyPath)
  ])
};

const EXAMPLE_URL = 'https://example.com';
const DNS_NAME = 'example.com';

describe('certificates', () => {
  describe('mapCerts', () => {
    it('returns null when given an undefined token map', async () => {
      const certs: Cardano.Certificate | undefined = undefined;
      const ledgerCerts = mapCerts(certs, CONTEXT_WITHOUT_KNOWN_ADDRESSES);

      expect(ledgerCerts).toEqual(null);
    });

    it('can map a script hash stake registration certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeRegistration,
            stakeCredential
          }
        ],
        CONTEXT_WITHOUT_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            stakeCredential: {
              scriptHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
            }
          },
          type: Ledger.CertificateType.STAKE_REGISTRATION
        }
      ]);
    });

    it('can map a stake key stake registration certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeRegistration,
            stakeCredential
          }
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            stakeCredential: {
              keyPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                KeyRole.Stake,
                0
              ],
              type: Ledger.StakeCredentialParamsType.KEY_PATH
            }
          },
          type: Ledger.CertificateType.STAKE_REGISTRATION
        }
      ]);
    });

    it('can map a script hash stake deregistration certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeDeregistration,
            stakeCredential
          }
        ],
        CONTEXT_WITHOUT_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            stakeCredential: {
              scriptHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
            }
          },
          type: Ledger.CertificateType.STAKE_DEREGISTRATION
        }
      ]);
    });

    it('can map a stake key stake deregistration certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeDeregistration,
            stakeCredential
          }
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            stakeCredential: {
              keyPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                KeyRole.Stake,
                0
              ],
              type: Ledger.StakeCredentialParamsType.KEY_PATH
            }
          },
          type: Ledger.CertificateType.STAKE_DEREGISTRATION
        }
      ]);
    });

    it('can map a pool registration certificate with known keys', async () => {
      expect(
        mapCerts(
          [
            {
              __typename: Cardano.CertificateType.PoolRegistration,
              poolParameters
            }
          ],
          CONTEXT_WITH_KNOWN_ADDRESSES
        )
      ).toEqual([
        {
          params: {
            cost: 1000n,
            margin: {
              denominator: 5,
              numerator: 1
            },
            metadata: {
              metadataHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
              metadataUrl: EXAMPLE_URL
            },
            pledge: 10_000n,
            poolKey: {
              params: {
                path: [
                  util.harden(CardanoKeyConst.PURPOSE),
                  util.harden(CardanoKeyConst.COIN_TYPE),
                  util.harden(0),
                  2,
                  0
                ]
              },
              type: Ledger.PoolKeyType.DEVICE_OWNED
            },
            poolOwners: [
              {
                params: {
                  stakingPath: [
                    util.harden(CardanoKeyConst.PURPOSE),
                    util.harden(CardanoKeyConst.COIN_TYPE),
                    util.harden(0),
                    2,
                    0
                  ]
                },
                type: Ledger.PoolOwnerType.DEVICE_OWNED
              }
            ],
            relays: [
              {
                params: {
                  dnsName: DNS_NAME,
                  portNumber: 5000
                },
                type: 1
              },
              {
                params: {
                  ipv4: '127.0.0.1',
                  portNumber: 6000
                },
                type: 0
              },
              {
                params: {
                  dnsName: DNS_NAME
                },
                type: 1
              }
            ],
            rewardAccount: {
              params: {
                path: [
                  util.harden(CardanoKeyConst.PURPOSE),
                  util.harden(CardanoKeyConst.COIN_TYPE),
                  util.harden(0),
                  2,
                  0
                ]
              },
              type: Ledger.PoolRewardAccountType.DEVICE_OWNED
            },
            vrfKeyHashHex: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
          },
          type: 3
        }
      ]);
    });

    it('can map a pool registration certificate with unknown keys', async () => {
      expect(
        mapCerts(
          [
            {
              __typename: Cardano.CertificateType.PoolRegistration,
              poolParameters
            }
          ],
          CONTEXT_WITHOUT_KNOWN_ADDRESSES
        )
      ).toEqual([
        {
          params: {
            cost: 1000n,
            margin: {
              denominator: 5,
              numerator: 1
            },
            metadata: {
              metadataHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
              metadataUrl: EXAMPLE_URL
            },
            pledge: 10_000n,
            poolKey: {
              params: {
                keyHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'
              },
              type: Ledger.PoolKeyType.THIRD_PARTY
            },
            poolOwners: [
              {
                params: {
                  stakingKeyHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'
                },
                type: Ledger.PoolOwnerType.THIRD_PARTY
              }
            ],
            relays: [
              {
                params: {
                  dnsName: DNS_NAME,
                  portNumber: 5000
                },
                type: 1
              },
              {
                params: {
                  ipv4: '127.0.0.1',
                  portNumber: 6000
                },
                type: 0
              },
              {
                params: {
                  dnsName: DNS_NAME
                },
                type: 1
              }
            ],
            rewardAccount: {
              params: {
                rewardAccountHex: 'e1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'
              },
              type: Ledger.PoolRewardAccountType.THIRD_PARTY
            },
            vrfKeyHashHex: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
          },
          type: 3
        }
      ]);
    });

    it('throws if its given a pool retirement certificate but the signing key cant be found', async () => {
      expect(() =>
        mapCerts(
          [
            {
              __typename: Cardano.CertificateType.PoolRetirement,
              epoch: Cardano.EpochNo(500),
              poolId: Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc')
            }
          ],
          CONTEXT_WITHOUT_KNOWN_ADDRESSES
        )
      ).toThrow("Invalid argument 'certificate': Missing key matching pool retirement certificate.");
    });

    it('can map a stake pool retirement certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: Cardano.EpochNo(500),
            poolId: Cardano.PoolId(poolId)
          }
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            poolKeyPath: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(0),
              KeyRole.Stake,
              0
            ],
            retirementEpoch: 500
          },
          type: Ledger.CertificateType.STAKE_POOL_RETIREMENT
        }
      ]);
    });

    it('can map a delegation certificate with unknown stake key', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: poolId2,
            stakeCredential
          }
        ],
        CONTEXT_WITHOUT_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            poolKeyHashHex: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            stakeCredential: {
              scriptHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
            }
          },
          type: Ledger.CertificateType.STAKE_DELEGATION
        }
      ]);
    });

    it('can map a delegation certificate with known stake key', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: poolId2,
            stakeCredential
          }
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            poolKeyHashHex: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            stakeCredential: {
              keyPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                2,
                0
              ],
              type: Ledger.StakeCredentialParamsType.KEY_PATH
            }
          },
          type: Ledger.CertificateType.STAKE_DELEGATION
        }
      ]);
    });
  });

  describe('getKnownAddress', () => {
    it('should return undefined immediately if context is not provided', () => {
      const fakeCertificate: Cardano.StakeDelegationCertificate = {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: 'pool1' as Cardano.PoolId,
        stakeCredential: {
          hash: 'fakehash' as Hash28ByteBase16,
          type: Cardano.CredentialType.KeyHash
        }
      };

      const result = getKnownAddress(fakeCertificate);
      expect(result).toBeUndefined();
    });

    it('should return the matching known address when context is provided', () => {
      const hashUsedForTest = '13cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d0' as Hash28ByteBase16;
      const fakeCertificate: Cardano.StakeDelegationCertificate = {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: 'pool1' as Cardano.PoolId,
        stakeCredential: {
          hash: hashUsedForTest,
          type: Cardano.CredentialType.KeyHash
        }
      };

      const expectedAddress = mockContext.knownAddresses[0];
      const result = getKnownAddress(fakeCertificate, mockContext);
      expect(result).not.toBeUndefined();
      expect(result).toEqual(expectedAddress);
    });

    it('should return undefined if no addresses match the stake credential hash', () => {
      const hashUsedForTest = 'unknown-hash' as Hash28ByteBase16;
      const fakeCertificate: Cardano.StakeDelegationCertificate = {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: 'pool1' as Cardano.PoolId,
        stakeCredential: {
          hash: hashUsedForTest,
          type: Cardano.CredentialType.KeyHash
        }
      };

      const result = getKnownAddress(fakeCertificate, mockContext);
      expect(result).toBeUndefined();
    });
  });
});
