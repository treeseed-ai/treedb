import { FederationAdapter } from '../adapters/index.js';
import type { TreeDbClientConfig, Transport } from '../types/index.js';
import { FetchTransport } from './transport.js';

export class TreeDbFederatedClient {
  readonly transport: Transport;
  readonly federation: FederationAdapter;

  constructor(config: TreeDbClientConfig) {
    this.transport = config.transport ?? new FetchTransport(config);
    this.federation = new FederationAdapter({ transport: this.transport });
  }
}
