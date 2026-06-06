import httpx
import pytest

from treedb_sdk.config import TreeDbClientConfig
from treedb_sdk.errors import TreeDbApiError
from treedb_sdk.transport import HttpxTransport, TreeDbRequest


def test_transport_wraps_network_errors() -> None:
    transport = HttpxTransport(TreeDbClientConfig(base_url="http://127.0.0.1:1", timeout=0.001))
    with pytest.raises(TreeDbApiError) as exc:
        transport.request(TreeDbRequest(method="GET", path="/api/v1/health"))
    assert exc.value.code == "network_error"


def test_transport_class_is_importable() -> None:
    assert httpx.Client is not None
