from __future__ import annotations

from typing import Any

from .common import json_request
from treedb_sdk.transport import Transport


class FederationAdapter:
    def __init__(self, transport: Transport) -> None:
        self.transport = transport

    def plan(self, body: Any) -> Any:
        return json_request(self.transport, "POST", "/api/v1/federation/query/plan", body)

    def search(self, body: Any) -> Any:
        return json_request(self.transport, "POST", "/api/v1/search", body)

    def query(self, body: Any) -> Any:
        return json_request(self.transport, "POST", "/api/v1/query", body)

    def context_build(self, body: Any) -> Any:
        return json_request(self.transport, "POST", "/api/v1/context/build", body)

    def graph_query(self, body: Any) -> Any:
        return json_request(self.transport, "POST", "/api/v1/graph/query", body)
