import type { TreeDbPage } from '../types/index.js';

export function createPage<T>(input: TreeDbPage<T>): TreeDbPage<T> {
  return {
    items: input.items,
    nextCursor: input.nextCursor,
    hasMore: input.hasMore,
    cursor: input.cursor,
    limit: input.limit
  };
}

export function isTreeDbPage(value: unknown): value is TreeDbPage<unknown> {
  return typeof value === 'object' && value !== null && Array.isArray((value as TreeDbPage<unknown>).items);
}

export function getNextCursor<T>(page: TreeDbPage<T>): string | undefined {
  return page.nextCursor;
}
