import { describe, expect, it } from 'vitest';
import { TREE_DB_OPENAPI_OPERATION_COUNT, TREE_DB_OPENAPI_OPERATIONS } from '../../src/treedb/index.js';

describe('generated OpenAPI metadata', () => {
  it('tracks current /api/v1 operation count', () => {
    expect(TREE_DB_OPENAPI_OPERATION_COUNT).toBe(113);
    expect(TREE_DB_OPENAPI_OPERATIONS).toHaveLength(113);
  });
});
