from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Generic, TypeAlias, TypeVar


T = TypeVar("T")
TreeDbCursor: TypeAlias = str


@dataclass(frozen=True)
class TreeDbPage(Generic[T]):
    items: list[T]
    next_cursor: str | None = None
    has_more: bool | None = None
    cursor: str | None = None
    limit: int | None = None


def create_page(
    items: list[T],
    *,
    next_cursor: str | None = None,
    has_more: bool | None = None,
    cursor: str | None = None,
    limit: int | None = None,
) -> TreeDbPage[T]:
    return TreeDbPage(items=items, next_cursor=next_cursor, has_more=has_more, cursor=cursor, limit=limit)


def is_treedb_page(value: Any) -> bool:
    return isinstance(value, TreeDbPage) or (isinstance(value, dict) and isinstance(value.get("items"), list))


def get_next_cursor(page: TreeDbPage[Any]) -> str | None:
    return page.next_cursor
