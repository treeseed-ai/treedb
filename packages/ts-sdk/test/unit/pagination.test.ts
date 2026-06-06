import { describe, expect, it } from 'vitest';
import { createPage, getNextCursor, isTreeDbPage } from '../../src/treedb/index.js';

describe('pagination helpers', () => {
  it('preserves page metadata', () => {
    const page = createPage({ items: [1], nextCursor: 'next', hasMore: true });
    expect(isTreeDbPage(page)).toBe(true);
    expect(getNextCursor(page)).toBe('next');
    expect(page.hasMore).toBe(true);
  });
});
