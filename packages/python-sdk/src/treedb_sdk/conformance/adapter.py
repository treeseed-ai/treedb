from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

from treedb_sdk.client import TreeDbClient


@dataclass(frozen=True)
class TreeDbConformanceScenario:
    id: str
    capability_id: str
    title: str
    required: bool
    endpoint_refs: list[str]
    steps: list[dict[str, str]]
    assertions: list[str]


@dataclass(frozen=True)
class TreeDbConformanceResult:
    scenario_id: str
    status: Literal["passed", "failed", "not_configured"]
    message: str | None = None


class TreeDbConformanceAdapter:
    def __init__(self, client: TreeDbClient, server_configured: bool = False) -> None:
        self.client = client
        self.server_configured = server_configured

    def run_scenario(self, scenario: TreeDbConformanceScenario) -> TreeDbConformanceResult:
        if not self.server_configured:
            return TreeDbConformanceResult(
                scenario_id=scenario.id,
                status="not_configured",
                message="TreeDB conformance server is not configured.",
            )
        return TreeDbConformanceResult(
            scenario_id=scenario.id,
            status="not_configured",
            message="Executable Python conformance dispatch is deferred to a later phase.",
        )
