import { RegistryAdapter } from '../adapters/index.js';
import type { TreeDbClientConfig, Transport } from '../types/index.js';
import { FetchTransport } from './transport.js';

export class TreeDbRegistryClient {
  readonly transport: Transport;
  readonly registry: RegistryAdapter;

  constructor(config: TreeDbClientConfig) {
    this.transport = config.transport ?? new FetchTransport(config);
    this.registry = new RegistryAdapter({ transport: this.transport });
  }
}
