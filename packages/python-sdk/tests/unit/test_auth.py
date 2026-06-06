from treedb_sdk.auth import StaticBearerTokenAuthProvider, resolve_authorization_header
from treedb_sdk.config import TreeDbClientConfig


def test_static_bearer_token_provider_returns_token() -> None:
    assert StaticBearerTokenAuthProvider("abc").get_token() == "abc"


def test_authorization_header_format() -> None:
    config = TreeDbClientConfig(base_url="http://treedb.test", token="abc")
    assert resolve_authorization_header(config) == {"Authorization": "Bearer abc"}
