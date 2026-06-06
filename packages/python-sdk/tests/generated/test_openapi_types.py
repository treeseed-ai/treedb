from treedb_sdk.generated import TREE_DB_OPENAPI_OPERATION_COUNT, TREE_DB_OPENAPI_OPERATIONS


def test_openapi_operation_count() -> None:
    assert TREE_DB_OPENAPI_OPERATION_COUNT == 113
    assert len(TREE_DB_OPENAPI_OPERATIONS) == 113
