from pathlib import Path

import yaml

import treedb_sdk
from treedb_sdk.conformance import TreeDbConformanceAdapter
from treedb_sdk.generated import TREE_DB_OPENAPI_OPERATIONS


def test_public_exports() -> None:
    assert treedb_sdk.TreeDbClient is not None
    assert treedb_sdk.TreeDbApiError is not None
    assert TreeDbConformanceAdapter is not None


def test_generated_operations_include_sdk_spec_endpoints() -> None:
    root = Path(__file__).resolve().parents[3]
    endpoints = yaml.safe_load((root / "sdk-spec" / "spec" / "endpoints.yaml").read_text(encoding="utf8"))
    generated = {f"{operation['method']} {operation['path']}" for operation in TREE_DB_OPENAPI_OPERATIONS}
    for group_endpoints in (endpoints.get("groups") or {}).values():
        for endpoint in group_endpoints:
            assert endpoint in generated
