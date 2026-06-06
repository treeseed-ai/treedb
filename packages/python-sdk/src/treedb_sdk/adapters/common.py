from __future__ import annotations

from typing import Any, Mapping
from urllib.parse import quote

from treedb_sdk.binary import BinaryBody
from treedb_sdk.transport import Transport, TreeDbHttpMethod, TreeDbRequest


def segment(value: str) -> str:
    return quote(str(value), safe="")


def json_request(
    transport: Transport,
    method: TreeDbHttpMethod,
    path: str,
    body: Any | None = None,
    query: Mapping[str, str | int | float | bool | None] | None = None,
) -> Any:
    return transport.request(TreeDbRequest(method=method, path=path, body=body, query=query)).data


def binary_request(
    transport: Transport,
    method: TreeDbHttpMethod,
    path: str,
    body: BinaryBody,
    query: Mapping[str, str | int | float | bool | None] | None = None,
) -> Any:
    return transport.request(TreeDbRequest(method=method, path=path, binary_body=body, query=query)).data
