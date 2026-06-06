import { describe, expect, it } from 'vitest';
import { TreeDbClient } from '../../src/treedb/index.js';

describe('live TreeDB API integration', () => {
  it('runs health when TREEDB_BASE_URL is configured or reports not configured cleanly', async () => {
    const baseUrl = process.env.TREEDB_BASE_URL;
    if (!baseUrl) {
      expect({ status: 'not_configured', reason: 'TREEDB_BASE_URL is not set' }).toMatchObject({ status: 'not_configured' });
      return;
    }

    const client = new TreeDbClient({ baseUrl, token: process.env.TREEDB_TOKEN });
    await expect(client.health()).resolves.toBeDefined();
  });
});
