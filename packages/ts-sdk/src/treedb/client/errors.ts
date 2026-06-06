import type { TreeDbApiErrorPayload } from '../types/index.js';

export class TreeDbApiError extends Error {
  readonly status: number;
  readonly code: string;
  readonly details?: unknown;
  readonly payload?: unknown;
  readonly cause?: unknown;

  constructor(input: { status: number; code: string; message: string; details?: unknown; payload?: unknown; cause?: unknown }) {
    super(input.message);
    this.name = 'TreeDbApiError';
    this.status = input.status;
    this.code = input.code;
    this.details = input.details;
    this.payload = input.payload;
    this.cause = input.cause;
  }

  static fromResponse(status: number, payload: unknown): TreeDbApiError {
    const envelope = payload as TreeDbApiErrorPayload | undefined;
    const error = envelope?.error;
    return new TreeDbApiError({
      status,
      code: error?.code ?? 'internal_error',
      message: error?.message ?? `TreeDB request failed with status ${status}`,
      details: error?.details,
      payload
    });
  }

  static network(message: string, cause?: unknown): TreeDbApiError {
    return new TreeDbApiError({
      status: 0,
      code: 'network_error',
      message,
      cause
    });
  }
}
