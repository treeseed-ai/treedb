from treedb_sdk import TreeDbClient
from treedb_sdk.adapters import (
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
from treedb_sdk.transport import TreeDbRequest, TreeDbResponse


class MockTransport:
    def __init__(self) -> None:
        self.requests: list[TreeDbRequest] = []

    def request(self, request: TreeDbRequest) -> TreeDbResponse[object]:
        self.requests.append(request)
        return TreeDbResponse(status=200, headers={}, data={"ok": True})

    def last(self) -> TreeDbRequest:
        return self.requests[-1]


def test_client_creates_module_adapters() -> None:
    client = TreeDbClient(base_url="http://treedb.test", transport=MockTransport())
    assert isinstance(client.repositories, RepositoriesAdapter)
    assert isinstance(client.workspaces, WorkspacesAdapter)
    assert isinstance(client.files, FilesAdapter)
    assert isinstance(client.blobs, BlobsAdapter)
    assert isinstance(client.query, QueryAdapter)
    assert isinstance(client.graph, GraphAdapter)
    assert isinstance(client.context, ContextAdapter)
    assert isinstance(client.federation, FederationAdapter)
    assert isinstance(client.registry, RegistryAdapter)
    assert isinstance(client.snapshots, SnapshotsAdapter)
    assert isinstance(client.artifacts, ArtifactsAdapter)
    assert isinstance(client.mirrors, MirrorsAdapter)
    assert isinstance(client.migrations, MigrationsAdapter)
    assert isinstance(client.exec, ExecAdapter)
    assert isinstance(client.observability, ObservabilityAdapter)


def test_client_uses_custom_transport() -> None:
    transport = MockTransport()
    client = TreeDbClient(base_url="http://treedb.test", transport=transport)
    client.health()
    assert transport.last().path == "/api/v1/health"
