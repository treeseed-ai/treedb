import { jsonRequest, segment, type TreeDbAdapterContext } from './common.js';

export class MigrationsAdapter {
  constructor(private readonly context: TreeDbAdapterContext) {}
  create(repoId: string, input: unknown): Promise<unknown> { return jsonRequest(this.context.transport, 'POST', `/api/v1/repos/${segment(repoId)}/migrations`, input); }
  get(repoId: string, migrationId: string): Promise<unknown> { return jsonRequest(this.context.transport, 'GET', `/api/v1/repos/${segment(repoId)}/migrations/${segment(migrationId)}`); }
}
