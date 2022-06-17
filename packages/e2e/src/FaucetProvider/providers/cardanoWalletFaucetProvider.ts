// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import { Provider, HealthCheckResponse } from '../../../core';
import { WalletServer, ApiNetworkInformationSyncProgressStatusEnum,
         AddressWallet, TransactionWallet, ApiTransactionStatusEnum } from 'cardano-wallet-js'
import { FaucetProvider, FaucetRequestResult, FaucetRequestTransactionStatus, } from '../types'
import { Stopwatch } from "ts-stopwatch";

// Constnats
const FAUCET_PASSPHRASE:           string = "passphrase";
const FAUCET_WALLET_NAME:          string = "faucet";
const HTTP_ERROR_CODE_IN_CONFLICT: number = 409;
const DEFAULT_TIMEOUT:             number = 10000;
const DEFAULT_CONFIRMATIONS:       number = 0;

/**
 * Cardano Wallet implementation of the faucet provider. This provider utlizes the Cardano Wallet HTTP service
 * to construct, sign, submit and track the transaction generated by the faucet.
 */
export class CardanoWalletFaucetService implements FaucetProvider {

  _serviceUrl:     string  = "";
  _seedPhrases:    string  = "";
  _faucetWalletId: string  = "";
  _walletServer:   WalletServer;
 
  /**
   * Initializes a new instance of the CardanoWalletFaucetService class.
   * 
   * @param url The cardano wallet server REST endpoint.
   * @param seedPhrases The seedphrases of the faucet wallet.
   */
  constructor(url: string, seedPhrases: string) {

    this._serviceUrl  = url;
    this._seedPhrases = seedPhrases;
  }

  /**
   * Request tAda to be transferred to the given address.
   * 
   * @param addresses The addresses where the tAda must be deposited.
   * @param amounts  The amounts of tAda to be deposited at each address (in lovelace).
   * @param timeout The time we are willing to wait (in milliseconds) for the faucet request transaction to be confirmed.
   * @param confirmations The number of blocks that has passed since our transaction was added to the blockchain.
   */
  public async request(addresses: string[], amounts: number[], confirmations: number = DEFAULT_CONFIRMATIONS, timeout: number = DEFAULT_TIMEOUT): Promise<FaucetRequestResult> {
 
    let faucetWallet = await this._walletServer.getShelleyWallet(this._faucetWalletId);
    
    let receiverAddress = addresses.map((strAddress) => new AddressWallet(strAddress));

    const stopwatch = new Stopwatch();
    stopwatch.start();

    let transaction: TransactionWallet = await faucetWallet.sendPayment(FAUCET_PASSPHRASE, receiverAddress, amounts);

    let isTransactionConfirmed: boolean = false;
    while ((transaction.status === ApiTransactionStatusEnum.Pending || !isTransactionConfirmed) && stopwatch.getTime() < timeout)
    {
      transaction = await faucetWallet.getTransaction(transaction.id);
      isTransactionConfirmed = transaction.depth !== undefined && transaction.depth.quantity >= confirmations;
    }

    stopwatch.stop();

    if (stopwatch.getTime() >= timeout)
      throw `The transaction ${transaction.id} was not confirmed on time`;

    return {
      txId: transaction.id,
      status: this.mapStatus(transaction.status),
      time: transaction.inserted_at?.time,
      confirmations: transaction.depth?.quantity
    }
  }

  /**
   * Starts the provider.
   */
  public async start(): Promise<void> {

    const walletInfo = {
      name: FAUCET_WALLET_NAME,
      mnemonic_sentence: this._seedPhrases.split(' '),
      passphrase: FAUCET_PASSPHRASE };

      this._walletServer = WalletServer.init(this._serviceUrl);

      let axiosResponse = await this._walletServer.walletsApi.postWallet(walletInfo).catch(e => {

        if (e.response === undefined)
          throw e;
          
        // This seed phrases already exists on the cardano wallet service.
        if (e.response.status === HTTP_ERROR_CODE_IN_CONFLICT)
        {
          // TODO: If the seedphrases were already added to Cardano Wallet, the id of the wallet
          // will be returned in an error message, we can then extract the id from the message, however
          // this extremely brittle. We must find a better way to get the wallet id given a set of seed phrases.
          this._faucetWalletId = e.response.data.message.match(/(?<=\: ).*(?=\ H)/g)[0];
        }
        else
        {
          throw e.response.data;
        }
      });

      if (axiosResponse)
        this._faucetWalletId = axiosResponse.data.id;

      return;
  }
 
  /**
   * Closes the provider.
   */
  public async close(): Promise<void> {

    this._faucetWalletId = "";
    return;
  }

  /**
   * Performs a health check on the provider.
   * 
   * @return A promise with the healthcheck reponse.
   */
  public async healthCheck(): Promise<HealthCheckResponse> {

    const networkInfo = await this._walletServer.getNetworkInformation();

    return { ok: networkInfo.sync_progress.status === ApiNetworkInformationSyncProgressStatusEnum.Ready 
      && this._faucetWalletId !== "" };
  }

  /**
   * Converts the cardano wallet transaction result enum to our FaucetRequestTransactionStatus enum.
   * @param status The cardano wallet enum to be converted.
   * 
   * @returns The FaucetRequestTransactionStatus equivalent enum value.
   */
  private mapStatus(status: ApiTransactionStatusEnum) : FaucetRequestTransactionStatus {
    let mappedStatus: FaucetRequestTransactionStatus = FaucetRequestTransactionStatus.Expired;
    switch (status) {
      case ApiTransactionStatusEnum.Expired:
        mappedStatus = FaucetRequestTransactionStatus.Expired;
        break;
      case ApiTransactionStatusEnum.InLedger:
        mappedStatus = FaucetRequestTransactionStatus.InLedger;
        break;
      case ApiTransactionStatusEnum.Pending:
        mappedStatus = FaucetRequestTransactionStatus.Pending;
        break;
    }

    return mappedStatus;
  }
}