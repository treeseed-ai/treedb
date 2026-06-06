import { ArtifactsAdapter, BlobsAdapter, ContextAdapter, ExecAdapter, FederationAdapter, FilesAdapter, GraphAdapter, MigrationsAdapter, MirrorsAdapter, ObservabilityAdapter, QueryAdapter, RegistryAdapter, RepositoriesAdapter, SnapshotsAdapter, WorkspacesAdapter } from '../adapters/index.js';
import type { TreeDbClientConfig, Transport } from '../types/index.js';
import { FetchTransport } from './transport.js';

export class TreeDbClient {
  readonly transport: Transport;
  readonly repositories: RepositoriesAdapter;
  readonly workspaces: WorkspacesAdapter;
  readonly files: FilesAdapter;
  readonly blobs: BlobsAdapter;
  readonly query: QueryAdapter;
  readonly graph: GraphAdapter;
  readonly context: ContextAdapter;
  readonly federation: FederationAdapter;
  readonly registry: RegistryAdapter;
  readonly snapshots: SnapshotsAdapter;
  readonly artifacts: ArtifactsAdapter;
  readonly mirrors: MirrorsAdapter;
  readonly migrations: MigrationsAdapter;
  readonly exec: ExecAdapter;
  readonly observability: ObservabilityAdapter;

  constructor(readonly config: TreeDbClientConfig) {
    this.transport = config.transport ?? new FetchTransport(config);
    const adapterContext = { transport: this.transport };
    this.repositories = new RepositoriesAdapter(adapterContext);
    this.workspaces = new WorkspacesAdapter(adapterContext);
    this.files = new FilesAdapter(adapterContext);
    this.blobs = new BlobsAdapter(adapterContext);
    this.query = new QueryAdapter(adapterContext);
    this.graph = new GraphAdapter(adapterContext);
    this.context = new ContextAdapter(adapterContext);
    this.federation = new FederationAdapter(adapterContext);
    this.registry = new RegistryAdapter(adapterContext);
    this.snapshots = new SnapshotsAdapter(adapterContext);
    this.artifacts = new ArtifactsAdapter(adapterContext);
    this.mirrors = new MirrorsAdapter(adapterContext);
    this.migrations = new MigrationsAdapter(adapterContext);
    this.exec = new ExecAdapter(adapterContext);
    this.observability = new ObservabilityAdapter(adapterContext);
  }

  health(): Promise<unknown> {
    return this.observability.health();
  }

  version(): Promise<unknown> {
    return this.transport.request({ method: 'GET', path: '/api/v1/version' }).then((response) => response.data);
  }

  whoami(): Promise<unknown> {
    return this.transport.request({ method: 'GET', path: '/api/v1/auth/whoami' }).then((response) => response.data);
  }

  effectiveScope(): Promise<unknown> {
    return this.transport.request({ method: 'GET', path: '/api/v1/policy/effective-scope' }).then((response) => response.data);
  }
}
