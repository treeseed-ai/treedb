import os

import pytest

from treedb_sdk import TreeDbClient


def test_live_health_or_clean_skip() -> None:
    base_url = os.environ.get("TREEDB_BASE_URL")
    if not base_url:
        pytest.skip("TREEDB_BASE_URL is not configured")
    client = TreeDbClient(base_url=base_url, token=os.environ.get("TREEDB_TOKEN"))
    assert client.health() is not None
