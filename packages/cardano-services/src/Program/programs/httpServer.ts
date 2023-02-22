/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import {
  AssetHttpService,
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  StubTokenMetadataService
} from '../../Asset';
import { CardanoNode } from '@cardano-sdk/core';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../../ChainHistory';
import {
  CommonProgramOptions,
  OgmiosProgramOptions,
  PosgresProgramOptions,
  PostgresOptionDescriptions,
  RabbitMqProgramOptions
} from '../options';
import { DbSyncEpochPollService, loadGenesisData } from '../../util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService, createHttpStakePoolExtMetadataService } from '../../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../../Utxo';
import { DnsResolver, createDnsResolver, serviceSetHas } from '../utils';
import { GenesisData } from '../../types';
import { HttpServer, BuildInfo as HttpServerBuildInfo, HttpServerConfig, HttpService } from '../../Http';
import { InMemoryCache } from '../../InMemoryCache';
import { Logger } from 'ts-log';
import { MissingProgramOption, MissingServiceDependency, RunnableDependencies, UnknownServiceName } from '../errors';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { SrvRecord } from 'dns';
import { TxSubmitHttpService } from '../../TxSubmit';
import { URL } from 'url';
import { createDbSyncMetadataService } from '../../Metadata';
import { createLogger } from 'bunyan';
import { getOgmiosCardanoNode, getOgmiosTxSubmitProvider, getPool, getRabbitMqTxSubmitProvider } from '../services';
import { isNotNil } from '@cardano-sdk/util';
import memoize from 'lodash/memoize';
import pg from 'pg';

export const API_URL_DEFAULT = 'http://localhost:3000';
export const PAGINATION_PAGE_SIZE_LIMIT_DEFAULT = 25;
export const USE_QUEUE_DEFAULT = false;
export const ENABLE_METRICS_DEFAULT = false;

/**
 * Used as mount segments, so must be URL-friendly
 *
 */
export enum ServiceNames {
  Asset = 'asset',
  StakePool = 'stake-pool',
  NetworkInfo = 'network-info',
  TxSubmit = 'tx-submit',
  Utxo = 'utxo',
  ChainHistory = 'chain-history',
  Rewards = 'rewards'
}

export const cardanoNodeDependantServices = new Set([
  ServiceNames.NetworkInfo,
  ServiceNames.StakePool,
  ServiceNames.Utxo,
  ServiceNames.Rewards,
  ServiceNames.Asset,
  ServiceNames.ChainHistory
]);

export enum HttpServerOptionDescriptions {
  ApiUrl = 'API URL',
  BuildInfo = 'HTTP server build info',
  CardanoNodeConfigPath = 'Cardano node config path',
  DbCacheTtl = 'Cache TTL in seconds between 60 and 172800 (two days), an option for database related operations',
  EpochPollInterval = 'Epoch poll interval',
  EnableMetrics = 'Enable Prometheus Metrics',
  TokenMetadataCacheTtl = 'Token Metadata API cache TTL in minutes',
  TokenMetadataServerUrl = 'Token Metadata API server URL',
  UseQueue = 'Enables RabbitMQ',
  PaginationPageSizeLimit = 'Pagination page size limit shared across all providers'
}

export type HttpServerOptions = CommonProgramOptions &
  PosgresProgramOptions &
  OgmiosProgramOptions &
  RabbitMqProgramOptions & {
    serviceNames?: ServiceNames[];
    enableMetrics?: boolean;
    buildInfo?: HttpServerBuildInfo;
    cardanoNodeConfigPath?: string;
    tokenMetadataCacheTTL?: number;
    tokenMetadataServerUrl?: string;
    epochPollInterval: number;
    dbCacheTtl: number;
    useQueue?: boolean;
    paginationPageSizeLimit?: number;
  };
export interface LoadHttpServerDependencies {
  dnsResolver?: (serviceName: string) => Promise<SrvRecord>;
  logger?: Logger;
}
export interface ProgramArgs {
  apiUrl: URL;
  serviceNames: (
    | ServiceNames.Asset
    | ServiceNames.StakePool
    | ServiceNames.TxSubmit
    | ServiceNames.ChainHistory
    | ServiceNames.Utxo
    | ServiceNames.NetworkInfo
    | ServiceNames.Rewards
  )[];
  /*
    TODO: optimize passed options -> 'options' is always passed by default and shouldn't be optional field,
    no need to check it with '.?' everywhere.Will be fixed within ADP-1990
  */
  options?: HttpServerOptions;
}

interface ServiceMapFactoryOptions {
  args: ProgramArgs;
  dbConnection?: pg.Pool;
  dnsResolver: DnsResolver;
  genesisData?: GenesisData;
  logger: Logger;
  node?: OgmiosCardanoNode;
}

const serviceMapFactory = (options: ServiceMapFactoryOptions) => {
  const { args, dbConnection, dnsResolver, genesisData, logger, node } = options;
  const withDbSyncProvider =
    <T>(factory: (db: pg.Pool, cardanoNode: CardanoNode) => T, serviceName: ServiceNames) =>
    () => {
      if (!dbConnection)
        throw new MissingProgramOption(serviceName, [
          PostgresOptionDescriptions.ConnectionString,
          PostgresOptionDescriptions.ServiceDiscoveryArgs
        ]);

      if (!node) throw new MissingServiceDependency(serviceName, RunnableDependencies.CardanoNode);

      return factory(dbConnection, node);
    };

  const getEpochMonitor = memoize((dbPool) => new DbSyncEpochPollService(dbPool, args.options!.epochPollInterval!));

  return {
    [ServiceNames.Asset]: withDbSyncProvider(async (db, cardanoNode) => {
      const ntfMetadataService = new DbSyncNftMetadataService({
        db,
        logger,
        metadataService: createDbSyncMetadataService(db, logger)
      });
      const tokenMetadataService = args.options?.tokenMetadataServerUrl?.startsWith('stub:')
        ? new StubTokenMetadataService()
        : new CardanoTokenRegistry({ logger }, args.options);
      const assetProvider = new DbSyncAssetProvider({
        cardanoNode,
        db,
        logger,
        ntfMetadataService,
        tokenMetadataService
      });

      return new AssetHttpService({ assetProvider, logger });
    }, ServiceNames.Asset),
    [ServiceNames.StakePool]: withDbSyncProvider(async (db, cardanoNode) => {
      if (!genesisData)
        throw new MissingProgramOption(ServiceNames.StakePool, HttpServerOptionDescriptions.CardanoNodeConfigPath);
      const stakePoolProvider = new DbSyncStakePoolProvider(
        { paginationPageSizeLimit: args.options!.paginationPageSizeLimit! },
        {
          cache: new InMemoryCache(args.options!.dbCacheTtl!),
          cardanoNode,
          db,
          epochMonitor: getEpochMonitor(db),
          genesisData,
          logger,
          metadataService: createHttpStakePoolExtMetadataService(logger)
        }
      );
      return new StakePoolHttpService({ logger, stakePoolProvider });
    }, ServiceNames.StakePool),
    [ServiceNames.Utxo]: withDbSyncProvider(
      async (db, cardanoNode) =>
        new UtxoHttpService({ logger, utxoProvider: new DbSyncUtxoProvider({ cardanoNode, db, logger }) }),
      ServiceNames.Utxo
    ),
    [ServiceNames.ChainHistory]: withDbSyncProvider(async (db, cardanoNode) => {
      const metadataService = createDbSyncMetadataService(db, logger);
      const chainHistoryProvider = new DbSyncChainHistoryProvider(
        { paginationPageSizeLimit: args.options!.paginationPageSizeLimit! },
        { cardanoNode, db, logger, metadataService }
      );
      return new ChainHistoryHttpService({ chainHistoryProvider, logger });
    }, ServiceNames.ChainHistory),
    [ServiceNames.Rewards]: withDbSyncProvider(async (db, cardanoNode) => {
      const rewardsProvider = new DbSyncRewardsProvider(
        { paginationPageSizeLimit: args.options!.paginationPageSizeLimit! },
        { cardanoNode, db, logger }
      );
      return new RewardsHttpService({ logger, rewardsProvider });
    }, ServiceNames.Rewards),
    [ServiceNames.NetworkInfo]: withDbSyncProvider(async (db, cardanoNode) => {
      if (!genesisData)
        throw new MissingProgramOption(ServiceNames.NetworkInfo, HttpServerOptionDescriptions.CardanoNodeConfigPath);
      const networkInfoProvider = new DbSyncNetworkInfoProvider({
        cache: new InMemoryCache(args.options!.dbCacheTtl!),
        cardanoNode,
        db,
        epochMonitor: getEpochMonitor(db),
        genesisData,
        logger
      });
      return new NetworkInfoHttpService({ logger, networkInfoProvider });
    }, ServiceNames.NetworkInfo),
    [ServiceNames.TxSubmit]: async () => {
      const txSubmitProvider = args.options?.useQueue
        ? await getRabbitMqTxSubmitProvider(dnsResolver, logger, args.options)
        : await getOgmiosTxSubmitProvider(dnsResolver, logger, args.options);
      return new TxSubmitHttpService({ logger, txSubmitProvider });
    }
  };
};

export const loadHttpServer = async (args: ProgramArgs, deps: LoadHttpServerDependencies = {}): Promise<HttpServer> => {
  const { apiUrl, options, serviceNames } = args;
  const services: HttpService[] = [];
  const logger =
    deps?.logger ||
    createLogger({
      level: options?.loggerMinSeverity,
      name: 'http-server'
    });
  const dnsResolver =
    deps?.dnsResolver ||
    createDnsResolver(
      {
        factor: options?.serviceDiscoveryBackoffFactor,
        maxRetryTime: options?.serviceDiscoveryTimeout
      },
      logger
    );
  const db = await getPool(dnsResolver, logger, options);
  const cardanoNode = serviceSetHas(serviceNames, cardanoNodeDependantServices)
    ? await getOgmiosCardanoNode(dnsResolver, logger, options)
    : undefined;
  const genesisData = options?.cardanoNodeConfigPath
    ? await loadGenesisData(options?.cardanoNodeConfigPath)
    : undefined;
  const serviceMap = serviceMapFactory({ args, dbConnection: db, dnsResolver, genesisData, logger, node: cardanoNode });

  for (const serviceName of serviceNames) {
    if (serviceMap[serviceName]) {
      services.push(await serviceMap[serviceName]());
    } else {
      throw new UnknownServiceName(serviceName, Object.values(ServiceNames));
    }
  }
  const config: HttpServerConfig = {
    listen: {
      host: apiUrl.hostname,
      port: Number.parseInt(apiUrl.port)
    },
    meta: { ...options?.buildInfo, startupTime: Date.now() }
  };
  if (options?.enableMetrics) {
    config.metrics = { enabled: options?.enableMetrics };
  }
  return new HttpServer(config, { logger, runnableDependencies: [cardanoNode].filter(isNotNil), services });
};
