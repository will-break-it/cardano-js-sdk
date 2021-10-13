import { CustomError } from 'ts-custom-error';

export enum ProviderFailure {
  NotFound = 'NOT_FOUND',
  Unknown = 'UNKNOWN'
}

export class ProviderError extends CustomError {
  constructor(public reason: ProviderFailure, public innerError?: unknown, public detail?: string) {
    super(reason + (detail ? ` (${detail})` : ''));
  }
}
