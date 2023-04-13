// Runtime dependency: `yarn preprod:up cardano-node-ogmios postgres` (can be any network)
/* eslint-disable import/no-extraneous-dependencies */
const { Bootstrap, Mappers, requestNext, logProjectionProgress } = require('@cardano-sdk/projection');
const {
  createDataSource,
  withTypeormTransaction,
  typeormTransactionCommit,
  TypeormStabilityWindowBuffer,
  BlockDataEntity,
  BlockEntity,
  StakePoolEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  storeBlock,
  storeStakePools,
  storeStakePoolMetadataJob,
  isRecoverableTypeormError
} = require('@cardano-sdk/projection-typeorm');
const { OgmiosObservableCardanoNode } = require('@cardano-sdk/ogmios');
const { defer, from, of } = require('rxjs');
const { createDatabase } = require('typeorm-extension');
const { shareRetryBackoff } = require('@cardano-sdk/util-rxjs');

const logger = {
  ...console,
  debug: () => void 0
};

const entities = [BlockDataEntity, BlockEntity, StakePoolEntity, PoolRegistrationEntity, PoolRetirementEntity];
const extensions = {
  pgBoss: true
};

const cardanoNode = new OgmiosObservableCardanoNode(
  {
    connectionConfig$: of({
      port: 1339
    })
  },
  { logger }
);
const buffer = new TypeormStabilityWindowBuffer({ logger });

// #region TypeORM setup

const connectionConfig = {
  database: 'projection',
  host: 'localhost',
  password: 'doNoUseThisSecret!',
  username: 'postgres'
};

const dataSource$ = defer(() =>
  from(
    (async () => {
      const dataSource = createDataSource({
        connectionConfig,
        devOptions: process.argv.includes('--drop')
          ? {
              dropSchema: true,
              synchronize: true
            }
          : undefined,
        entities,
        extensions,
        logger
      });
      await createDatabase({
        options: {
          type: 'postgres',
          ...connectionConfig,
          installExtensions: true
        }
      });
      await dataSource.initialize();
      await buffer.initialize(dataSource.createQueryRunner());
      return dataSource;
    })()
  )
);

// #endregion

Bootstrap.fromCardanoNode({
  buffer,
  cardanoNode,
  logger
})
  .pipe(
    Mappers.withCertificates(),
    Mappers.withStakePools(),
    shareRetryBackoff(
      (evt$) =>
        evt$.pipe(
          withTypeormTransaction({ dataSource$, logger }, extensions),
          storeBlock(),
          buffer.storeBlockData(),
          storeStakePools(),
          storeStakePoolMetadataJob(),
          typeormTransactionCommit()
        ),
      { shouldRetry: isRecoverableTypeormError }
    ),
    requestNext(),
    logProjectionProgress(logger)
  )
  .subscribe();
