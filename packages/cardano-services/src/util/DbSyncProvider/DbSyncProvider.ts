import { Cardano, CardanoNode, HealthCheckResponse, Provider, ProviderDependencies } from '@cardano-sdk/core';
import { DB_BLOCKS_BEHIND_TOLERANCE, DB_MAX_SAFE_INTEGER, LedgerTipModel, findLedgerTip } from './util';
import { Logger } from 'ts-log';
import { Pool } from 'pg';

/**
 * Properties that are need to create DbSyncProvider
 */
export interface DbSyncProviderDependencies extends ProviderDependencies {
  /**
   * DB connection
   */
  db: Pool;
  /**
   * Ogmios Cardano Node provider
   */
  cardanoNode: CardanoNode;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type AnyArgs = any[];

export const DbSyncProvider = <
  T extends (abstract new (...args: AnyArgs) => {}) | (new (...args: AnyArgs) => {}) = { new (): {} }
>(
  BaseClass?: T
) => {
  abstract class Mixin extends (BaseClass || Object) implements Provider {
    public db: Pool;
    public cardanoNode: CardanoNode;
    public logger: Logger;

    constructor(...args: AnyArgs) {
      const [dependencies, ...baseArgs] = [...args] as [DbSyncProviderDependencies, ...AnyArgs];
      const { db, cardanoNode, logger } = dependencies;

      super(...baseArgs);

      this.db = db;
      this.cardanoNode = cardanoNode;
      this.logger = logger;
    }

    public async healthCheck(): Promise<HealthCheckResponse> {
      const response: HealthCheckResponse = { ok: false };
      try {
        const cardanoNode = await this.cardanoNode.healthCheck();
        response.localNode = cardanoNode.localNode;
        const tip = (await this.db.query<LedgerTipModel>(findLedgerTip)).rows[0];

        if (tip) {
          response.projectedTip = {
            blockNo: Cardano.BlockNo(tip.block_no),
            hash: tip.hash.toString('hex') as unknown as Cardano.BlockId,
            slot: Cardano.Slot(Number(tip.slot_no))
          };
          response.ok =
            cardanoNode.ok &&
            tip?.block_no >=
              (cardanoNode.localNode?.ledgerTip?.blockNo ?? DB_MAX_SAFE_INTEGER) - DB_BLOCKS_BEHIND_TOLERANCE;

          this.logger.debug(
            `Service /health: projected block tip: ${tip.block_no},local node block tip: ${cardanoNode.localNode?.ledgerTip?.blockNo}.`
          );
        }
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        this.logger.error(error.message);
      }
      return response;
    }
  }

  type BaseArgs = T extends abstract new (...baseArgs: infer A) => {}
    ? A
    : T extends new (...baseArgs: infer A) => {}
    ? A
    : never;
  type BaseInstance = T extends abstract new (...baseArgs: AnyArgs) => infer I
    ? I
    : T extends new (...baseArgs: AnyArgs) => infer I
    ? I
    : never;
  type ReturnedType = BaseInstance & {
    db: Pool;
    cardanoNode: CardanoNode;
    logger: Logger;
    healthCheck: () => Promise<HealthCheckResponse>;
  };

  return Mixin as unknown as (T extends new (...baseArgs: AnyArgs) => {}
    ? new (dependencies: DbSyncProviderDependencies, ...args: BaseArgs) => ReturnedType
    : abstract new (dependencies: DbSyncProviderDependencies, ...args: BaseArgs) => ReturnedType) & {
    prototype: { healthCheck: () => Promise<HealthCheckResponse> };
  };
};
