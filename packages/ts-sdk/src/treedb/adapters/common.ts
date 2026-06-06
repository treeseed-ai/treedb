import type { BinaryBody, Transport, TreeDbHttpMethod } from '../types/index.js';

export interface TreeDbAdapterContext {
  transport: Transport;
}

export function segment(value: string): string {
  return encodeURIComponent(value);
}

export async function jsonRequest<T>(
  transport: Transport,
  method: TreeDbHttpMethod,
  path: string,
  body?: unknown,
  query?: Record<string, string | number | boolean | undefined>
): Promise<T> {
  const response = await transport.request<T>({ method, path, body, query });
  return response.data;
}

export async function binaryRequest<T>(
  transport: Transport,
  method: TreeDbHttpMethod,
  path: string,
  binaryBody: BinaryBody,
  query?: Record<string, string | number | boolean | undefined>
): Promise<T> {
  const response = await transport.request<T>({ method, path, binaryBody, query });
  return response.data;
}
