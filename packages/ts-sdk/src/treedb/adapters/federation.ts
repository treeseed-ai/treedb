import { jsonRequest, segment, type TreeDbAdapterContext } from './common.js';

export class FederationAdapter {
  constructor(private readonly context: TreeDbAdapterContext) {}
  plan(input: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', '/api/v1/federation/query/plan', input); }
  search(input: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', '/api/v1/search', input); }
  query(input: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', '/api/v1/query', input); }
  contextBuild(input: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', '/api/v1/context/build', input); }
  graphQuery(input: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', '/api/v1/graph/query', input); }
}

export { segment };
