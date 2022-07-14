import { Asset, Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { InMemoryCache } from '../InMemoryCache';
import { Logger } from 'ts-log';
import { TokenMetadataService } from './types';
import axios, { AxiosInstance } from 'axios';

const DEFAULT_METADATA_SERVER_URI = 'https://tokens.cardano.org';

interface NumberValue {
  value?: number;
}

interface StringValue {
  value?: string;
}

interface TokenMetadataServiceRecord {
  decimals?: NumberValue;
  description?: StringValue;
  logo?: StringValue;
  name?: StringValue;
  subject?: string;
  ticker?: StringValue;
  url?: StringValue;
}

const toProviderError = (error: unknown, details: string) => {
  if (error instanceof ProviderError) return error;

  const message = error instanceof Error ? `${error.message} ` : '';

  return new ProviderError(ProviderFailure.Unknown, error, `${message}${details}`);
};

/**
 * Configuration options for CardanoTokenRegistry
 */
export interface CardanoTokenRegistryConfiguration {
  /**
   * The cache TTL in seconds. Default: 10 minutes.
   */
  cacheTTL?: number;

  /**
   * The Cardano Token Registry public API base URL. Default: https://tokens.cardano.org
   */
  metadataServerUri?: string;
}

interface CardanoTokenRegistryConfigurationWithRequired extends CardanoTokenRegistryConfiguration {
  cacheTTL: number;
  metadataServerUri: string;
}

/**
 * Dependencies that are need to create CardanoTokenRegistry
 */
export interface CardanoTokenRegistryDependencies {
  /**
   * The cache engine. Default: InMemoryCache with CardanoTokenRegistryConfiguration.cacheTTL as default TTL
   */
  cache?: InMemoryCache;

  /**
   * The logger object
   */
  logger: Logger;
}

/**
 * TokenMetadataService implementation using Cardano Token Registry public API
 */
export class CardanoTokenRegistry implements TokenMetadataService {
  /**
   * The axios client used to retrieve metadata from API
   */
  #axiosClient: AxiosInstance;

  /**
   * The in memory cache engine
   */
  #cache: InMemoryCache;

  /**
   * The logger object
   */
  #logger: Logger;

  constructor({ cache, logger }: CardanoTokenRegistryDependencies, config: CardanoTokenRegistryConfiguration = {}) {
    const defaultConfig: CardanoTokenRegistryConfigurationWithRequired = {
      cacheTTL: 600,
      metadataServerUri: DEFAULT_METADATA_SERVER_URI,
      ...config
    };

    this.#cache = cache || new InMemoryCache(defaultConfig.cacheTTL);
    this.#axiosClient = axios.create({ baseURL: defaultConfig.metadataServerUri });
    this.#logger = logger;
  }

  shutdown() {
    this.#cache.shutdown();
  }

  async getTokenMetadata(assetIds: Cardano.AssetId[]) {
    this.#logger.debug(`Requested asset metatada for "${assetIds}"`);

    const [assetIdsToRequest, tokenMetadata] = this.getTokenMetadataFromCache(assetIds);

    // All metadata was taken from cache
    if (assetIdsToRequest.length === 0) return tokenMetadata;

    this.#logger.debug(`Fetching asset metatada for "${assetIdsToRequest}"`);

    try {
      const response = await this.#axiosClient.post<{ subjects: TokenMetadataServiceRecord[] }>('metadata/query', {
        properties: ['decimals', 'description', 'logo', 'name', 'ticker', 'url'],
        subjects: assetIdsToRequest
      });

      for (const record of response.data.subjects) {
        try {
          const { subject } = record;

          if (subject) {
            const assetId = Cardano.AssetId(subject);
            const metadata = this.parseTokenMetadataServiceRecord(record);

            tokenMetadata[assetIds.indexOf(assetId)] = metadata;
            this.#cache.set(assetId.toString(), metadata);
          } else
            throw new ProviderError(
              ProviderFailure.InvalidResponse,
              undefined,
              `Missing 'subject' property in metadata record ${JSON.stringify(record)}`
            );
        } catch (error) {
          throw toProviderError(error, `while evaluating metatada record ${JSON.stringify(record)}`);
        }
      }
    } catch (error) {
      throw toProviderError(error, 'while fetching metadata from token registriy');
    }

    return tokenMetadata;
  }

  getTokenMetadataFromCache(assetIds: Cardano.AssetId[]) {
    const assetIdsToRequest: Cardano.AssetId[] = [];
    // eslint-disable-next-line unicorn/no-new-array
    const cachedTokenMetadata: (Asset.TokenMetadata | null)[] = new Array(assetIds.length).fill(null);

    for (const [i, assetId] of assetIds.entries()) {
      const stringAssetId = assetId.toString();

      const cachedMetadata = this.#cache.getVal<Asset.TokenMetadata>(stringAssetId);

      if (cachedMetadata) {
        this.#logger.debug(`Using chached asset metatada value for "${stringAssetId}"`);
        cachedTokenMetadata[i] = cachedMetadata;
      } else assetIdsToRequest.push(assetId);
    }

    return [assetIdsToRequest, cachedTokenMetadata] as const;
  }

  private parseTokenMetadataServiceRecord(record: TokenMetadataServiceRecord) {
    const { decimals, description, logo, name, ticker, url } = record;
    const metadata: Asset.TokenMetadata = {};

    metadata.decimals = decimals?.value;
    metadata.desc = description?.value;
    metadata.icon = logo?.value;
    metadata.name = name?.value;
    metadata.ticker = ticker?.value;
    metadata.url = url?.value;

    return metadata;
  }
}
