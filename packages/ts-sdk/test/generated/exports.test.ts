import { describe, expect, it } from 'vitest';
import { TreeDbApiError, TreeDbClient, TreeDbConformanceAdapter, TREE_DB_OPENAPI_OPERATION_COUNT } from '../../src/treedb/index.js';

describe('public exports', () => {
  it('exports client, errors, generated metadata, and conformance adapter', () => {
    expect(TreeDbClient).toBeDefined();
    expect(TreeDbApiError).toBeDefined();
    expect(TreeDbConformanceAdapter).toBeDefined();
    expect(TREE_DB_OPENAPI_OPERATION_COUNT).toBe(113);
  });
});
