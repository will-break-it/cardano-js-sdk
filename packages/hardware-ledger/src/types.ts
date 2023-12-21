import { Cardano } from '@cardano-sdk/core';
import { SignTransactionContext } from '@cardano-sdk/key-management';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import TransportWebHID from '@ledgerhq/hw-transport-webhid';

export enum DeviceType {
  Ledger = 'Ledger'
}

export type LedgerTransportType = TransportWebHID | TransportNodeHid;

/**
 * The LedgerTxTransformerContext type represents the additional context necessary for
 * transforming a Core transaction into a Ledger device compatible transaction.
 */
export type LedgerTxTransformerContext = {
  /** The Cardano blockchain's network identifier (e.g., mainnet or testnet). */
  chainId: Cardano.ChainId;
  /** Non-hardened account in cip1852 */
  accountIndex: number;
} & SignTransactionContext;
