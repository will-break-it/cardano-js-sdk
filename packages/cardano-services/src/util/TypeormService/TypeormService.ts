import { BehaviorSubject, Observable, Subscription, filter, firstValueFrom } from 'rxjs';
import { DataSource, QueryRunner } from 'typeorm';
import { Logger } from 'ts-log';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { RunnableModule, isNotNil } from '@cardano-sdk/util';
import { createTypeormDataSource } from '../createTypeormDataSource';

interface TypeormServiceDependencies {
  logger: Logger;
  entities: Function[];
  connectionConfig$: Observable<PgConnectionConfig>;
}

export abstract class TypeormService extends RunnableModule {
  #entities: Function[];
  #connectionConfig$: Observable<PgConnectionConfig>;
  protected dataSource$ = new BehaviorSubject<DataSource | null>(null);
  #subscription: Subscription | undefined;

  constructor(name: string, { connectionConfig$, logger, entities }: TypeormServiceDependencies) {
    super(name, logger);
    this.#entities = entities;
    this.#connectionConfig$ = connectionConfig$;
  }

  #subscribeToDataSource() {
    this.#subscription = createTypeormDataSource(this.#connectionConfig$, this.#entities, this.logger).subscribe(
      (dataSource) => this.dataSource$.next(dataSource)
    );
  }

  #reset() {
    this.#subscription?.unsubscribe();
    this.#subscription = undefined;
    this.dataSource$.value !== null && this.dataSource$.next(null);
  }

  onError(_: unknown) {
    this.#reset();
    this.#subscribeToDataSource();
  }

  async withDataSource<T>(callback: (dataSource: DataSource) => Promise<T>): Promise<T> {
    try {
      return await callback(await firstValueFrom(this.dataSource$.pipe(filter(isNotNil))));
    } catch (error) {
      this.onError(error);
      throw error;
    }
  }

  async withQueryRunner<T>(callback: (queryRunner: QueryRunner) => Promise<T>): Promise<T> {
    return this.withDataSource(async (dataSource) => {
      const queryRunner = dataSource.createQueryRunner();
      try {
        const result = await callback(queryRunner);
        await queryRunner.release();
        return result;
      } catch (error) {
        try {
          await queryRunner.release();
        } catch (releaseError) {
          this.logger.warn(releaseError);
        }
        throw error;
      }
    });
  }

  async initializeImpl() {
    return Promise.resolve();
  }

  async startImpl() {
    this.#subscribeToDataSource();
  }

  async shutdownImpl() {
    this.#reset();
    this.dataSource$.complete();
  }
}
