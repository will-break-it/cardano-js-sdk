import { Asset, AssetProvider, Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { AssetBuilder } from './AssetBuilder';
import { DbSyncProvider } from '../DbSyncProvider';
import { Logger } from 'ts-log';
import { NftMetadataService, TokenMetadataService } from './types';
import { Pool } from 'pg';

/**
 * Dependencies that are need to create DbSyncAssetProvider
 */
export type DbSyncAssetProviderDependencies = {
  /**
   * The db-sync database Pgpool
   */
  db: Pool;

  /**
   *
   * The logger object
   */
  logger: Logger;

  /**
   * The NftMetadataService to retrieve Asset.NftMetadata.
   */
  ntfMetadataService: NftMetadataService;

  /**
   * The TokenMetadataService toretrieve Asset.TokenMetadata.
   */
  tokenMetadataService: TokenMetadataService;
};

type AssetExtraData = Parameters<AssetProvider['getAsset']>[1];

/**
 * AssetProvider implementation using NftMetadataService, TokenMetadataService
 * and cardano-db-sync database as sources
 */
export class DbSyncAssetProvider extends DbSyncProvider implements AssetProvider {
  #builder: AssetBuilder;
  #dependencies: DbSyncAssetProviderDependencies;

  constructor(dependencies: DbSyncAssetProviderDependencies) {
    const { db, logger } = dependencies;

    super(db);

    this.#builder = new AssetBuilder(db, logger);
    this.#dependencies = dependencies;
  }

  async getAsset(assetId: Cardano.AssetId, extraData?: AssetExtraData) {
    const name = Asset.util.assetNameFromAssetId(assetId);
    const policyId = Asset.util.policyIdFromAssetId(assetId);
    const multiAsset = await this.#builder.queryMultiAsset(policyId, name);

    if (!multiAsset)
      throw new ProviderError(ProviderFailure.NotFound, undefined, 'No entries found in multi_asset table');

    const fingerprint = Cardano.AssetFingerprint(multiAsset.fingerprint);
    const quantities = await this.#builder.queryMultiAssetQuantities(multiAsset.id);
    const quantity = BigInt(quantities.sum);
    const mintOrBurnCount = Number(quantities.count);

    const assetInfo: Asset.AssetInfo = { assetId, fingerprint, mintOrBurnCount, name, policyId, quantity };

    if (extraData?.history) await this.loadHistory(assetInfo);
    if (extraData?.nftMetadata)
      assetInfo.nftMetadata = await this.#dependencies.ntfMetadataService.getNftMetadata(assetInfo);
    if (extraData?.tokenMetadata)
      assetInfo.tokenMetadata = (await this.#dependencies.tokenMetadataService.getTokenMetadata([assetId]))[0];

    return assetInfo;
  }

  private async loadHistory(assetInfo: Asset.AssetInfo) {
    assetInfo.history = (
      await this.#builder.queryMultiAssetHistory(assetInfo.policyId, assetInfo.name)
    ).map<Asset.AssetMintOrBurn>(({ hash, quantity }) => ({
      quantity: BigInt(quantity),
      transactionId: Cardano.TransactionId(hash.toString('hex'))
    }));
  }
}
