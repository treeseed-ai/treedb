import { resolveAuthorizationHeader } from './auth.js';
import { TreeDbApiError } from './errors.js';
import type { BinaryBody, TreeDbClientConfig, TreeDbRequest, TreeDbResponse, Transport } from '../types/index.js';

export type TreeDbFetch = typeof fetch;

export interface FetchTransportOptions {
  baseUrl: string;
  defaultHeaders?: Record<string, string>;
  token?: string;
  authProvider?: TreeDbClientConfig['authProvider'];
  fetchImpl?: TreeDbFetch;
}

export class FetchTransport implements Transport {
  private readonly fetchImpl: TreeDbFetch;

  constructor(private readonly options: FetchTransportOptions) {
    this.fetchImpl = options.fetchImpl ?? fetch;
  }

  async request<T = unknown>(request: TreeDbRequest): Promise<TreeDbResponse<T>> {
    const url = new URL(request.path, this.options.baseUrl);
    for (const [key, value] of Object.entries(request.query ?? {})) {
      if (value !== undefined) {
        url.searchParams.set(key, String(value));
      }
    }

    const authHeaders = await resolveAuthorizationHeader(this.options);
    const headers: Record<string, string> = {
      ...this.options.defaultHeaders,
      ...authHeaders,
      ...request.headers
    };

    let body: BodyInit | undefined;
    if (request.binaryBody) {
      body = request.binaryBody as BinaryBody as BodyInit;
    } else if (request.body !== undefined) {
      headers['Content-Type'] ??= 'application/json';
      body = JSON.stringify(request.body);
    }

    let response: Response;
    try {
      response = await this.fetchImpl(url, { method: request.method, headers, body });
    } catch (error) {
      throw TreeDbApiError.network('TreeDB network request failed', error);
    }

    const data = await parseResponseBody(response);
    if (!response.ok) {
      throw TreeDbApiError.fromResponse(response.status, data);
    }

    return {
      status: response.status,
      headers: Object.fromEntries(response.headers.entries()),
      data: data as T
    };
  }
}

async function parseResponseBody(response: Response): Promise<unknown> {
  if (response.status === 204) {
    return undefined;
  }

  const contentType = response.headers.get('content-type') ?? '';
  if (contentType.includes('application/json')) {
    return response.json();
  }
  if (contentType.startsWith('text/')) {
    return response.text();
  }
  return response.arrayBuffer();
}
