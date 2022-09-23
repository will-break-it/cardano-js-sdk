import { EpochNo } from '../Block';
import { Lovelace } from '../Value';
import { PoolIdHex } from './primitives';
import { PoolParameters } from './PoolParameters';
import { TransactionId } from '../Transaction';

/**
 * Within range [0; 1]
 */
export type Percent = number;

/**
 * Stake quantities for a Stake Pool.
 */
export interface StakePoolMetricsStake {
  /**
   * The total amount of stake currently delegated to the pool. This will be snapshotted at the end of the epoch.
   */
  live: Lovelace;

  /**
   * A snapshot from 2 epochs ago, used in the current epoch as part of the block leadership schedule.
   */
  active: Lovelace;
}

/**
 * Stake percentages for a Stake Pool.
 */
export interface StakePoolMetricsSize {
  /**
   * The percentage of stake currently delegated to the pool. This will be snapshotted at the end of the epoch.
   */
  live: Percent;

  /**
   * Percentage of stake as a snapshot from 2 epochs ago, used in the current epoch as part of the
   * block leadership schedule.
   */
  active: Percent;
}

/**
 * Stake pool performance metrics.
 */
export interface StakePoolMetrics {
  /**
   * Total blocks created by the pool.
   */
  blocksCreated: number;

  /**
   * This can be used to determine the likelihood of the poo meeting it.s pledge at the next snapshot.
   */
  livePledge: Lovelace;

  /**
   * Quantity of stake being controlled by the pool.
   */
  stake: StakePoolMetricsStake;

  /**
   * Percentage of stake being controlled by the pool.
   */
  size: StakePoolMetricsSize;

  /**
   * The current saturation of the pool. The amount of rewards generated by the pool gets capped at a pool saturation
   * of 100%; This is part of the protocol to promote decentralization of the stake.
   */
  saturation: Percent;

  /**
   * Number of stakeholders, represented by a stake key, delegating to this pool.
   */
  delegators: number;

  /**
   * Rewards Annual Percentage Yield (APY).
   */
  apy?: Percent;
}

/**
 * The list of transaction regarding this pool registration or retirement.
 */
export interface StakePoolTransactions {
  /**
   * List of pool registration transactions.
   */
  registration: TransactionId[];

  /**
   * List of pool retirement transactions.
   */
  retirement: TransactionId[];
}

/**
 * Pool status.
 */
export enum StakePoolStatus {
  Activating = 'activating',
  Active = 'active',
  Retired = 'retired',
  Retiring = 'retiring'
}

/**
 * Stake pool epoch stats.
 */
export class StakePoolEpochRewards {
  /**
   * Epoch length in milliseconds.
   */
  epochLength: number;

  /**
   * The epoch number at which these rewards were calculated.
   */
  epoch: EpochNo;

  /**
   * Active stake is a stake snapshot from 2 epochs ago and is used in the current era
   * as part of the block leadership schedule.
   */
  activeStake: Lovelace;

  /**
   * The total rewards generated by the pool that members have access to up to the current epoch.
   */
  totalRewards: Lovelace;

  /**
   * A fixed amount of lovelace the stake pool will earn.
   */
  operatorFees: Lovelace;

  /**
   * (rewards-operatorFees)/activeStake, not annualized.
   */
  memberROI: Percent;
}

/**
 * Stake pool information about the performance, status, transaction, rewards and pool parameters.
 */
export interface StakePool extends PoolParameters {
  /**
   * Stake pool ID as a hex string
   */
  hexId: PoolIdHex;

  /**
   * Stake pool metrics
   */
  metrics: StakePoolMetrics;

  /**
   * Stake pool status
   */
  status: StakePoolStatus;

  /**
   * Transactions provisioning the stake pool
   */
  transactions: StakePoolTransactions;

  /**
   * Stake pool rewards history per epoch.
   * Sorted by epoch in ascending order.
   */
  epochRewards: StakePoolEpochRewards[];
}
