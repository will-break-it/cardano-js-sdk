import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, getCertificatesByType } from '@cardano-sdk/core';
import { Observable, combineLatest, distinctUntilChanged, map } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';
import { transactionsEquals } from '../util/equals';
import last from 'lodash/last';

export const isLastStakeKeyCertOfType = (
  transactionsCertificates: Cardano.Certificate[][],
  certTypes: readonly Cardano.RegAndDeregCertificateTypes[],
  rewardAccount?: Cardano.RewardAccount
) => {
  const stakeKeyHash = rewardAccount
    ? Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount))
    : null;
  const lastRegOrDereg = last(
    transactionsCertificates
      .map((certificates) => {
        const allStakeKeyCertificates = Cardano.stakeKeyCertificates(certificates);
        const addressStakeKeyCertificates = stakeKeyHash
          ? allStakeKeyCertificates.filter(({ stakeCredential: certStakeCred }) => stakeKeyHash === certStakeCred.hash)
          : allStakeKeyCertificates;
        return last(addressStakeKeyCertificates);
      })
      .filter(isNotNil)
  );
  return certTypes.includes(lastRegOrDereg?.__typename as Cardano.RegAndDeregCertificateTypes);
};

export const transactionsWithCertificates = (
  transactions$: Observable<Cardano.HydratedTx[]>,
  rewardAccounts$: Observable<Cardano.RewardAccount[]>,
  certificateTypes: Cardano.CertificateType[]
) =>
  combineLatest([transactions$, rewardAccounts$]).pipe(
    map(([transactions, rewardAccounts]) =>
      transactions.filter((tx) => getCertificatesByType(tx, rewardAccounts, certificateTypes).length > 0)
    ),
    distinctUntilChanged(transactionsEquals)
  );
