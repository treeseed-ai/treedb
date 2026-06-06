import { jsonRequest, segment, type TreeDbAdapterContext } from './common.js';

export class SnapshotsAdapter {
  constructor(private readonly context: TreeDbAdapterContext) {}
  build(repoId: string, input: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', `/api/v1/repos/${segment(repoId)}/snapshots/build`, input); }
  get(repoId: string, snapshotId: string): Promise<unknown> { return jsonRequest(this.context.transport, 'GET', `/api/v1/repos/${segment(repoId)}/snapshots/${segment(snapshotId)}`); }
}
