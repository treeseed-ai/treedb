export type TreeDbJson =
  | null
  | boolean
  | number
  | string
  | TreeDbJson[]
  | { [key: string]: TreeDbJson };

export interface TreeDbClientConfig {
  baseUrl: string;
  token?: string;
  authProvider?: AuthProvider;
  transport?: Transport;
  defaultHeaders?: Record<string, string>;
}

export interface TreeDbRequest {
  method: TreeDbHttpMethod;
  path: string;
  query?: Record<string, string | number | boolean | undefined>;
  headers?: Record<string, string>;
  body?: unknown;
  binaryBody?: BinaryBody;
}

export interface TreeDbResponse<T = unknown> {
  status: number;
  headers: Record<string, string>;
  data: T;
}

export type TreeDbHttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';

export interface TreeDbPage<T> {
  items: T[];
  nextCursor?: string;
  hasMore?: boolean;
  cursor?: string;
  limit?: number;
}

export type TreeDbCursor = string;

export type BinaryBody =
  | Uint8Array
  | ArrayBuffer
  | Buffer
  | ReadableStream<Uint8Array>;

export interface MultipartUpload {
  uploadId: string;
  completedParts?: Array<{ partNumber: number; etag?: string }>;
}

export interface TreeDbApiErrorPayload {
  error?: {
    code?: string;
    message?: string;
    details?: unknown;
  };
  [key: string]: unknown;
}

export interface AuthProvider {
  getToken(): string | Promise<string>;
}

export interface Transport {
  request<T = unknown>(request: TreeDbRequest): Promise<TreeDbResponse<T>>;
}

export type TreeDbRecord = Record<string, unknown>;
