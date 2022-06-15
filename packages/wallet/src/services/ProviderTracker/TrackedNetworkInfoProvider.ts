import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { NetworkInfoProvider } from '@cardano-sdk/core';

export class NetworkInfoProviderStats {
  readonly networkInfo$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly currentWalletProtocolParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly genesisParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly ledgerTip$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.networkInfo$.complete();
    this.currentWalletProtocolParameters$.complete();
    this.genesisParameters$.complete();
    this.ledgerTip$.complete();
  }

  reset() {
    this.networkInfo$.next(CLEAN_FN_STATS);
    this.currentWalletProtocolParameters$.next(CLEAN_FN_STATS);
    this.genesisParameters$.next(CLEAN_FN_STATS);
    this.ledgerTip$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a NetworkInfoProvider, tracking # of calls of each function
 */
export class TrackedNetworkInfoProvider extends ProviderTracker implements NetworkInfoProvider {
  readonly stats = new NetworkInfoProviderStats();
  readonly networkInfo: NetworkInfoProvider['networkInfo'];
  readonly ledgerTip: NetworkInfoProvider['ledgerTip'];
  readonly currentWalletProtocolParameters: NetworkInfoProvider['currentWalletProtocolParameters'];
  readonly genesisParameters: NetworkInfoProvider['genesisParameters'];

  constructor(networkInfoProvider: NetworkInfoProvider) {
    super();
    networkInfoProvider = networkInfoProvider;

    this.networkInfo = () => this.trackedCall(networkInfoProvider.networkInfo, this.stats.networkInfo$);
    this.ledgerTip = () => this.trackedCall(networkInfoProvider.ledgerTip, this.stats.ledgerTip$);
    this.currentWalletProtocolParameters = () =>
      this.trackedCall(
        networkInfoProvider.currentWalletProtocolParameters,
        this.stats.currentWalletProtocolParameters$
      );
    this.genesisParameters = () =>
      this.trackedCall(networkInfoProvider.genesisParameters, this.stats.genesisParameters$);
  }
}
