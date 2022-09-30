import { Cardano } from '@cardano-sdk/core';
import {
  ConfirmedTx,
  TransactionReemitErrorCode,
  TransactionReemitterProps,
  TxInFlight,
  createTransactionReemitter
} from '../../src';
import { InMemoryInFlightTransactionsStore, InMemoryVolatileTransactionsStore } from '../../src/persistence';
import { Logger, dummyLogger } from 'ts-log';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { genesisParameters } from '../mocks';

describe('TransactionReemiter', () => {
  const maxInterval = 2000;
  let stores: TransactionReemitterProps['stores'];
  let volatileTransactions: ConfirmedTx[];
  let logger: Logger;

  beforeEach(() => {
    logger = dummyLogger;
    stores = {
      inFlightTransactions: new InMemoryInFlightTransactionsStore(),
      volatileTransactions: new InMemoryVolatileTransactionsStore()
    };
    stores.volatileTransactions.set = jest.fn();
    stores.inFlightTransactions.set = jest.fn();
    volatileTransactions = [
      {
        confirmedAt: 100,
        tx: {
          body: { validityInterval: { invalidHereafter: 1000 } },
          id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')
        }
      },
      {
        confirmedAt: 200,
        tx: {
          body: { validityInterval: { invalidHereafter: 1000 } },
          id: Cardano.TransactionId('7804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')
        }
      },
      {
        confirmedAt: 300,
        tx: {
          body: { validityInterval: { invalidHereafter: 1000 } },
          id: Cardano.TransactionId('8804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
          slot: 300
        }
      },
      {
        confirmedAt: 400,
        tx: {
          body: { validityInterval: { invalidHereafter: 1000 } },
          id: Cardano.TransactionId('9904edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
          slot: 400
        }
      }
    ] as ConfirmedTx[];
  });

  it('Stored volatile transactions are fetched on init', () => {
    const storeTransaction = volatileTransactions[0];
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      stores.volatileTransactions.get = jest.fn(() => cold('a|', { a: [storeTransaction] }));
      const tipSlot$ = hot<Cardano.Slot>('-|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('-|');
      const confirmed$ = cold<ConfirmedTx>('-|');
      const rollback$ = cold<Cardano.TxAlonzo>('-|');
      const submitting$ = cold<Cardano.NewTxAlonzo>('-|');
      const inFlight$ = cold<TxInFlight[]>('-|');
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('-|');
    });
    expect(stores.volatileTransactions.get).toHaveBeenCalledTimes(1);
    expect(stores.volatileTransactions.set).not.toHaveBeenCalledTimes(1); // already in store
  });

  it('Merges stored transacions with confirmed transactions and adds them all to store', () => {
    const storeTransaction = volatileTransactions[0];
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      stores.volatileTransactions.get = jest.fn(() => cold('a|', { a: [storeTransaction] }));
      const tipSlot$ = hot<Cardano.Slot>('----|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a---|', { a: genesisParameters });
      const confirmed$ = cold<ConfirmedTx>('-b-c|', { b: volatileTransactions[1], c: volatileTransactions[2] });
      const rollback$ = cold<Cardano.TxAlonzo>('----|');
      const submitting$ = cold<Cardano.NewTxAlonzo>('----|');
      const inFlight$ = cold<TxInFlight[]>('-|');
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('----|');
    });
    expect(stores.volatileTransactions.set).toHaveBeenCalledTimes(2);
    expect(stores.volatileTransactions.set).toHaveBeenLastCalledWith(volatileTransactions.slice(0, 3));
  });

  it('Removes transaction from volatiles if it is reported as submitting', () => {
    const storeTransaction = volatileTransactions;
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      stores.volatileTransactions.get = jest.fn(() => cold('a|', { a: storeTransaction }));
      const tipSlot$ = hot<Cardano.Slot>('--|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a-|', { a: genesisParameters });
      const confirmed$ = cold<ConfirmedTx>('--|');
      const rollback$ = cold<Cardano.TxAlonzo>('--|');
      const submitting$ = cold<Cardano.NewTxAlonzo>('-b|', { b: volatileTransactions[0].tx });
      const inFlight$ = cold<TxInFlight[]>('-|');
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('--|');
    });
    expect(stores.volatileTransactions.set).toHaveBeenCalledTimes(1);
    expect(stores.volatileTransactions.set).toHaveBeenLastCalledWith(volatileTransactions.slice(1));
  });

  it('Uses stability window to remove transactions no longer volatile', () => {
    const [volatileSlot100, volatileSlot200, volatileSlot300] = volatileTransactions;
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      const tipSlot$ = hot<Cardano.Slot>('---|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a--|', {
        a: { ...genesisParameters, activeSlotsCoefficient: 33 }
      });
      const confirmed$ = cold<ConfirmedTx>('abc|', {
        a: volatileSlot100,
        b: volatileSlot200,
        c: volatileSlot300
      });
      const rollback$ = cold<Cardano.TxAlonzo>('---|');
      const submitting$ = cold<Cardano.NewTxAlonzo>('---|');
      const inFlight$ = cold<TxInFlight[]>('-|');
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('---|');
    });
    expect(stores.volatileTransactions.set).toHaveBeenCalledTimes(3);
    expect(stores.volatileTransactions.set).toHaveBeenLastCalledWith(volatileTransactions.slice(1, 3));
  });

  it('Emits transactions that were rolled back and still valid', () => {
    const LAST_TIP_SLOT = 400;
    const [volatileA, volatileB, volatileC, volatileD] = volatileTransactions;
    const rollbackA: Cardano.TxAlonzo = { body: volatileA.tx.body, id: volatileA.tx.id } as Cardano.TxAlonzo;
    const rollbackC: Cardano.TxAlonzo = {
      body: { validityInterval: { invalidHereafter: LAST_TIP_SLOT - 1 } },
      id: volatileC.tx.id
    } as Cardano.TxAlonzo;
    const rollbackD: Cardano.TxAlonzo = { body: volatileD.tx.body, id: volatileD.tx.id } as Cardano.TxAlonzo;

    // eslint-disable-next-line @typescript-eslint/no-shadow
    logger.error = jest.fn();

    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      const tipSlot$ = hot<Cardano.Slot>('x--------|', { x: LAST_TIP_SLOT });
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a--------|', { a: genesisParameters });
      const confirmed$ = cold<ConfirmedTx>('a-b-c-d--|', {
        a: volatileA,
        b: volatileB,
        c: volatileC,
        d: volatileD
      });
      const rollback$ = cold<Cardano.TxAlonzo>('--a--c--d|', { a: rollbackA, c: rollbackC, d: rollbackD });
      const submitting$ = cold<Cardano.NewTxAlonzo>('---------|');
      const inFlight$ = cold<TxInFlight[]>('-|');
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('--a-----d|', { a: volatileA.tx, d: volatileD.tx });
    });

    expect(logger.error).toHaveBeenCalledWith(expect.anything(), TransactionReemitErrorCode.invalidHereafter);
  });

  it('Logs error message for rolledback transactions not found in volatiles', () => {
    const [volatileA, volatileB, volatileC] = volatileTransactions;
    const rollbackC: Cardano.TxAlonzo = { body: volatileC.tx.body, id: volatileC.tx.id } as Cardano.TxAlonzo;
    // eslint-disable-next-line @typescript-eslint/no-shadow
    const logger = dummyLogger;
    logger.error = jest.fn();

    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      const tipSlot$ = hot<Cardano.Slot>('x--|', { x: 300 });
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a--|', { a: genesisParameters });
      const confirmed$ = cold<ConfirmedTx>('ab-|', {
        a: volatileA,
        b: volatileB
      });
      const rollback$ = cold<Cardano.TxAlonzo>('--c|', { c: rollbackC });
      const submitting$ = cold<Cardano.NewTxAlonzo>('---|');
      const inFlight$ = cold<TxInFlight[]>('-|');
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('---|');
    });
    expect(logger.error).toHaveBeenCalledWith(expect.anything(), TransactionReemitErrorCode.notFound);
  });

  it('Emits unconfirmed submission transactions from stores.inFlightTransactions', () => {
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      stores.inFlightTransactions.get = jest.fn(() =>
        cold<TxInFlight[]>('a|', {
          a: [
            {
              tx: volatileTransactions[0].tx
            },
            {
              submittedAt: 123,
              tx: volatileTransactions[1].tx
            }
          ]
        })
      );
      const tipSlot$ = hot<Cardano.Slot>('-|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('-|');
      const confirmed$ = cold<ConfirmedTx>('-|');
      const rollback$ = cold<Cardano.TxAlonzo>('-|');
      const submitting$ = cold<Cardano.NewTxAlonzo>('-|');
      const inFlight$ = cold<TxInFlight[]>('-|');
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('a|', { a: volatileTransactions[0].tx });
    });
    expect(stores.inFlightTransactions.get).toHaveBeenCalledTimes(1);
  });

  // eslint-disable-next-line max-len
  it('Emits inFlight transactions that were unconfirmed for longer than maxInterval since submittedAt', () => {
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      const tip = 123;
      const tipSlot$ = hot<Cardano.Slot>('-a|', { a: tip });
      const genesisParameters$ = hot('a|', { a: genesisParameters });
      const confirmed$ = cold<ConfirmedTx>('-|');
      const rollback$ = cold<Cardano.TxAlonzo>('-|');
      const submitting$ = cold<Cardano.NewTxAlonzo>('-|');
      const inFlight$ = cold<TxInFlight[]>('a|', {
        a: [
          { submittedAt: tip - 1, tx: volatileTransactions[0].tx },
          {
            submittedAt: tip - maxInterval / 1000 - 1,
            tx: volatileTransactions[1].tx
          }
        ]
      });
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('-a|', { a: volatileTransactions[1].tx });
    });
  });

  it('Does not re-emit already emitted transactions due to new genesisParameters$', () => {
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      const tip = 123;
      const tipSlot$ = hot<Cardano.Slot>('-a--|', { a: tip });
      const genesisParameters$ = cold('a-b|', { a: genesisParameters, b: genesisParameters });
      const confirmed$ = cold<ConfirmedTx>('-|');
      const rollback$ = cold<Cardano.TxAlonzo>('-|');
      const submitting$ = cold<Cardano.NewTxAlonzo>('-|');
      const inFlight$ = cold<TxInFlight[]>('a|', {
        a: [
          { submittedAt: tip - 1, tx: volatileTransactions[0].tx },
          {
            submittedAt: tip - maxInterval / 1000 - 1,
            tx: volatileTransactions[1].tx
          }
        ]
      });
      const transactionReemiter = createTransactionReemitter({
        genesisParameters$,
        logger,
        maxInterval,
        stores,
        tipSlot$,
        transactions: {
          outgoing: {
            confirmed$,
            inFlight$,
            submitting$
          },
          rollback$
        }
      });
      expectObservable(transactionReemiter).toBe('-a--|', { a: volatileTransactions[1].tx });
    });
  });
});
