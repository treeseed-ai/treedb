import { describe, expect, it } from 'vitest';
import { TreeDbClient } from '../../src/treedb/index.js';
import { MockTransport } from '../adapters/mock.js';

describe('TreeDbClient', () => {
  it('creates all generic module adapters', () => {
    const client = new TreeDbClient({ baseUrl: 'http://treedb.test', transport: new MockTransport() });
    expect(client.repositories).toBeDefined();
    expect(client.workspaces).toBeDefined();
    expect(client.files).toBeDefined();
    expect(client.blobs).toBeDefined();
    expect(client.query).toBeDefined();
    expect(client.graph).toBeDefined();
    expect(client.context).toBeDefined();
    expect(client.federation).toBeDefined();
    expect(client.registry).toBeDefined();
    expect(client.snapshots).toBeDefined();
    expect(client.artifacts).toBeDefined();
    expect(client.mirrors).toBeDefined();
    expect(client.migrations).toBeDefined();
    expect(client.exec).toBeDefined();
    expect(client.observability).toBeDefined();
  });

  it('uses custom transport for convenience methods', async () => {
    const transport = new MockTransport();
    const client = new TreeDbClient({ baseUrl: 'http://treedb.test', transport });
    await client.version();
    expect(transport.last()).toMatchObject({ method: 'GET', path: '/api/v1/version' });
  });
});
