import { Logger, dummyLogger } from 'ts-log';
import { Message } from './types';
import { WalletApi } from '..';
import { createMessenger } from './sendMessage';

export interface CreateUiWalletProps {
  walletExtensionId?: string;
  logger?: Logger;
}

export const createUiWallet = ({ logger = dummyLogger, walletExtensionId }: CreateUiWalletProps = {}): WalletApi => {
  const methodNames: (keyof WalletApi)[] = [
    'getNetworkId',
    'getUtxos',
    'getBalance',
    'getUsedAddresses',
    'getUnusedAddresses',
    'getChangeAddress',
    'getRewardAddresses',
    'signTx',
    'signData',
    'submitTx'
  ];
  const sendMessage = createMessenger({ extensionId: walletExtensionId, logger });
  return <WalletApi>(
    (<unknown>(
      Object.fromEntries(
        methodNames.map((method) => [
          method,
          (...args: Message['arguments']) => sendMessage({ arguments: args, method })
        ])
      )
    ))
  );
};
