import * as Queries from './queries';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { TxMetadataModel, TxMetadataService } from './types';
import { hexStringToBuffer } from '@cardano-sdk/util';
import { mapTxMetadataByHashes } from './util';

export type TxMetadataByHashes = Map<Cardano.TransactionId, Cardano.TxMetadata>;

export const createDbSyncMetadataService = (db: Pool, logger: Logger): TxMetadataService => ({
  async queryTxMetadataByHashes(hashes: Cardano.TransactionId[]): Promise<TxMetadataByHashes> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash));
    logger.debug('About to find metadata for txs:', hashes);

    const result: QueryResult<TxMetadataModel> = await db.query(Queries.findTxMetadataByTxHashes, [byteHashes]);

    if (result.rows.length === 0) return new Map();
    return mapTxMetadataByHashes(result.rows);
  },
  async queryTxMetadataByRecordIds(ids: string[]): Promise<TxMetadataByHashes> {
    logger.debug('About to find metadata for transactions with ids:', ids);

    const result: QueryResult<TxMetadataModel> = await db.query(Queries.findTxMetadataByTxIds, [ids]);

    if (result.rows.length === 0) return new Map();
    return mapTxMetadataByHashes(result.rows);
  }
});
