import { jsonRequest, segment, type TreeDbAdapterContext } from './common.js';

export class GraphAdapter {
  constructor(private readonly context: TreeDbAdapterContext) {}
  refresh(repoId: string, input?: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', `/api/v1/repos/${segment(repoId)}/graph/refresh`, input); }
  query(repoId: string, input: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', `/api/v1/repos/${segment(repoId)}/graph/query`, input); }
}
