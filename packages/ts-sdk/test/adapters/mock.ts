import type { Transport, TreeDbRequest, TreeDbResponse } from '../../src/treedb/index.js';

export class MockTransport implements Transport {
  readonly requests: TreeDbRequest[] = [];

  async request<T = unknown>(request: TreeDbRequest): Promise<TreeDbResponse<T>> {
    this.requests.push(request);
    return { status: 200, headers: {}, data: { ok: true } as T };
  }

  last(): TreeDbRequest {
    const request = this.requests.at(-1);
    if (!request) {
      throw new Error('No request recorded');
    }
    return request;
  }
}
