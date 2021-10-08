import * as Schema from '@cardano-ogmios/schema';
import { CSL, Transaction } from '@cardano-sdk/core';
import { Withdrawal } from './withdrawal';

export type InitializeTxProps = {
  outputs: Set<Schema.TxOut>;
  certificates?: CSL.Certificate[];
  withdrawals?: Withdrawal[];
  options?: {
    validityInterval?: Transaction.ValidityInterval;
  };
};
