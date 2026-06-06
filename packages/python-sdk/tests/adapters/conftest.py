from __future__ import annotations

from typing import Any

import pytest

from treedb_sdk.transport import TreeDbRequest, TreeDbResponse


class _MockTransport:
    def __init__(self) -> None:
        self.requests: list[TreeDbRequest] = []

    def request(self, request: TreeDbRequest) -> TreeDbResponse[Any]:
        self.requests.append(request)
        return TreeDbResponse(status=200, headers={}, data={"ok": True})

    def last(self) -> TreeDbRequest:
        if not self.requests:
            raise AssertionError("No request recorded")
        return self.requests[-1]


@pytest.fixture
def MockTransport() -> type[_MockTransport]:
    return _MockTransport
