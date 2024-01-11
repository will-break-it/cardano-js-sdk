/* eslint-disable unicorn/consistent-function-scoping */
import { PouchDbCollectionStore, PouchDbDocumentStore, PouchDbKeyValueStore } from '../../src/persistence';
import { assertCompletesWithoutEmitting } from './util';
import { combineLatest, firstValueFrom, mergeMap, share, shareReplay, take, timer, toArray } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import PouchDB from 'pouchdb';

describe('pouchDbStores', () => {
  const dbName = 'DbTestWallet';
  const doc1 = { __unsupportedKey: '1', bigint: 1n, map: new Map([[1, 2]]) };
  const doc2 = { __unsupportedKey: '2', bigint: 2n, map: new Map([[3, 4]]) };
  type DocType = typeof doc1;

  afterAll(async () => {
    // delete files from the filesystem
    await new PouchDB(dbName, { auto_compaction: true }).destroy();
  });

  describe('PouchDbDocumentStore', () => {
    it('stores and restores a document', async () => {
      const store1 = new PouchDbDocumentStore<DocType>(dbName, 'docId', logger);
      await store1.clearDB();
      await assertCompletesWithoutEmitting(store1.get());
      await firstValueFrom(store1.set(doc1));

      const store2 = new PouchDbDocumentStore<DocType>(dbName, 'docId', logger);
      expect(await firstValueFrom(store2.get())).toEqual(doc1);
    });

    it('set updates existing document', async () => {
      const store1 = new PouchDbDocumentStore<DocType>(dbName, 'docId', logger);
      await firstValueFrom(store1.set(doc1));
      await firstValueFrom(store1.set(doc2));
      expect(await firstValueFrom(store1.get())).toEqual(doc2);
    });

    it('simultaneous set() calls are resolved in series - last value is always persisted', async () => {
      const store = new PouchDbDocumentStore<DocType>(dbName, 'docId', logger);
      await firstValueFrom(combineLatest([store.set(doc1), timer(1).pipe(mergeMap(() => store.set(doc2)))]));
      expect(await firstValueFrom(store.get())).toEqual(doc2);
    });

    // eslint-disable-next-line sonarjs/no-duplicate-string
    it('destroy() disables store functions', async () => {
      const store = new PouchDbDocumentStore<DocType>(dbName, 'docId', logger);
      await firstValueFrom(store.set(doc1));
      await firstValueFrom(store.destroy());
      await assertCompletesWithoutEmitting(store.get());
      await assertCompletesWithoutEmitting(store.set(doc2));
    });

    it.todo('set() completes without emitting on any PouchDb error');
  });

  describe('PouchDbCollectionStore', () => {
    const createStore = () =>
      new PouchDbCollectionStore<DocType>({ computeDocId: ({ __unsupportedKey }) => __unsupportedKey, dbName }, logger);
    let store1: PouchDbCollectionStore<DocType>;

    beforeEach(async () => {
      store1 = createStore();
      await store1.clearDB();
    });

    it('maps document with autogenerated key', async () => {
      const store = new PouchDbCollectionStore<DocType>({ dbName }, logger);
      await firstValueFrom(store.setAll([doc1]));
      await expect(firstValueFrom(store.getAll())).resolves.toEqual([doc1]);
    });

    it('stores and restores a collection, ordered by result of computeDocId', async () => {
      await assertCompletesWithoutEmitting(store1.getAll());
      await firstValueFrom(store1.setAll([doc2, doc1]));

      const store2 = createStore();
      expect(await firstValueFrom(store2.getAll())).toEqual([doc1, doc2]);
    });

    it('setAll overwrites the entire collection', async () => {
      await firstValueFrom(store1.setAll([doc2, doc1]));
      await firstValueFrom(store1.setAll([doc2]));
      expect(await firstValueFrom(store1.getAll())).toEqual([doc2]);
    });

    it('simultaneous setAll() calls are resolved in series - last value is always persisted', async () => {
      await firstValueFrom(
        combineLatest([store1.setAll([doc1]), timer(1).pipe(mergeMap(() => store1.setAll([doc2])))])
      );
      expect(await firstValueFrom(store1.getAll())).toEqual([doc2]);
    });

    it('destroy() disables store functions', async () => {
      await firstValueFrom(store1.setAll([doc1]));
      await firstValueFrom(store1.destroy());
      await assertCompletesWithoutEmitting(store1.getAll());
      await assertCompletesWithoutEmitting(store1.setAll([doc2]));
    });

    it.todo('setAll completes without emitting on any PouchDb error');

    describe('observeAll', () => {
      it('emits an empty array when collection is empty', async () => {
        await expect(firstValueFrom(store1.observeAll())).resolves.toEqual([]);
      });
      it('emits all items upon subscription', async () => {
        await firstValueFrom(store1.setAll([doc1, doc2]));
        await expect(firstValueFrom(store1.observeAll())).resolves.toEqual([doc1, doc2]);
      });
      it('emits updated items when setAll is called after subscription', async () => {
        await firstValueFrom(store1.setAll([doc1]));
        const observe$ = store1.observeAll().pipe(share());
        const firstEmission = firstValueFrom(observe$);
        const twoEmissions = firstValueFrom(observe$.pipe(take(2), toArray()));
        await firstEmission;
        await firstValueFrom(store1.setAll([doc1, doc2]));
        await expect(twoEmissions).resolves.toEqual([[doc1], [doc1, doc2]]);
      });
      it('observeAll followed by immediate setAll does not skip 2nd emission', async () => {
        const items$ = store1.observeAll().pipe(shareReplay(1));
        await firstValueFrom(items$.pipe(mergeMap(() => store1.setAll([doc1]))));
        await expect(firstValueFrom(items$)).resolves.toEqual([doc1]);
      });
    });
  });

  describe('PouchDbKeyValueStore', () => {
    const createStore = () => new PouchDbKeyValueStore<string, DocType>(dbName, logger);
    let store1: PouchDbKeyValueStore<string, DocType>;
    const key1 = 'key1';
    const key2 = 'key2';
    const key3 = 'key3';

    beforeEach(async () => {
      store1 = createStore();
      await store1.clearDB();
    });

    it('stores and restores key-value pair', async () => {
      await firstValueFrom(store1.setValue(key1, doc1));

      const store2 = createStore();
      expect(await firstValueFrom(store2.getValues([key1]))).toEqual([doc1]);
    });

    it('setValue updates existing document', async () => {
      await firstValueFrom(store1.setValue(key1, doc1));
      await firstValueFrom(store1.setValue(key1, doc2));
      expect(await firstValueFrom(store1.getValues([key1]))).toEqual([doc2]);
    });

    it('getValue completes without emitting when document is not present', async () => {
      await assertCompletesWithoutEmitting(store1.getValues([key2]));
      await firstValueFrom(store1.setValue(key1, doc1));
      await assertCompletesWithoutEmitting(store1.getValues([key2]));
    });

    it('setAll overwrites the entire collection', async () => {
      await firstValueFrom(store1.setValue(key1, doc1));
      await firstValueFrom(
        store1.setAll([
          { key: key1, value: doc1 },
          { key: key3, value: doc2 }
        ])
      );
      await assertCompletesWithoutEmitting(store1.getValues([key2]));
      expect(await firstValueFrom(store1.getValues([key3, key1]))).toEqual([doc2, doc1]);
    });

    it('simultaneous setValue() calls are resolved in series - last value is always persisted', async () => {
      await firstValueFrom(
        combineLatest([store1.setValue(key1, doc1), timer(1).pipe(mergeMap(() => store1.setValue(key1, doc2)))])
      );
      expect(await firstValueFrom(store1.getValues([key1]))).toEqual([doc2]);
    });

    it('destroy() disables store functions', async () => {
      await firstValueFrom(store1.setValue(key1, doc1));
      await firstValueFrom(store1.destroy());
      await assertCompletesWithoutEmitting(store1.getValues([key1]));
      await assertCompletesWithoutEmitting(store1.setValue(key1, doc1));
      await assertCompletesWithoutEmitting(store1.setAll([{ key: key2, value: doc2 }]));
    });

    it.todo('setAll and setValues completes without emitting on any PouchDb error');
  });
});
