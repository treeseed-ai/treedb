from __future__ import annotations

from typing import Any

from .common import json_request, segment
from treedb_sdk.transport import Transport


class GraphAdapter:
    def __init__(self, transport: Transport) -> None:
        self.transport = transport

    def refresh(self, repo_id: str, body: Any | None = None) -> Any:
        return json_request(self.transport, "POST", f"/api/v1/repos/{segment(repo_id)}/graph/refresh", body)

    def query(self, repo_id: str, body: Any) -> Any:
        return json_request(self.transport, "POST", f"/api/v1/repos/{segment(repo_id)}/graph/query", body)
