from __future__ import annotations

from typing import Any, Mapping

from .adapters import (
    ArtifactsAdapter,
    BlobsAdapter,
    ContextAdapter,
    ExecAdapter,
    FederationAdapter,
    FilesAdapter,
    GraphAdapter,
    MigrationsAdapter,
    MirrorsAdapter,
    ObservabilityAdapter,
    QueryAdapter,
    RegistryAdapter,
    RepositoriesAdapter,
    SnapshotsAdapter,
    WorkspacesAdapter,
)
from .auth import AuthProvider
from .config import TreeDbClientConfig
from .transport import HttpxTransport, Transport, TreeDbRequest


class TreeDbClient:
    def __init__(
        self,
        base_url: str,
        token: str | None = None,
        auth_provider: AuthProvider | None = None,
        transport: Transport | None = None,
        default_headers: Mapping[str, str] | None = None,
        timeout: float | None = None,
    ) -> None:
        self.config = TreeDbClientConfig(
            base_url=base_url,
            token=token,
            auth_provider=auth_provider,
            transport=transport,
            default_headers=default_headers,
            timeout=timeout,
        )
        self.transport = transport or HttpxTransport(self.config)
        self.repositories = RepositoriesAdapter(self.transport)
        self.workspaces = WorkspacesAdapter(self.transport)
        self.files = FilesAdapter(self.transport)
        self.blobs = BlobsAdapter(self.transport)
        self.query = QueryAdapter(self.transport)
        self.graph = GraphAdapter(self.transport)
        self.context = ContextAdapter(self.transport)
        self.federation = FederationAdapter(self.transport)
        self.registry = RegistryAdapter(self.transport)
        self.snapshots = SnapshotsAdapter(self.transport)
        self.artifacts = ArtifactsAdapter(self.transport)
        self.mirrors = MirrorsAdapter(self.transport)
        self.migrations = MigrationsAdapter(self.transport)
        self.exec = ExecAdapter(self.transport)
        self.observability = ObservabilityAdapter(self.transport)

    def health(self) -> Any:
        return self.observability.health()

    def version(self) -> Any:
        return self.transport.request(TreeDbRequest(method="GET", path="/api/v1/version")).data

    def whoami(self) -> Any:
        return self.transport.request(TreeDbRequest(method="GET", path="/api/v1/auth/whoami")).data

    def effective_scope(self) -> Any:
        return self.transport.request(TreeDbRequest(method="GET", path="/api/v1/policy/effective-scope")).data


class TreeDbRegistryClient:
    def __init__(self, client: TreeDbClient) -> None:
        self.client = client
        self.registry = client.registry


class TreeDbFederatedClient:
    def __init__(self, client: TreeDbClient) -> None:
        self.client = client
        self.federation = client.federation
