use treedb_sdk::generated::openapi_types::{
    TREE_DB_OPENAPI_OPERATION_COUNT, TREE_DB_OPENAPI_OPERATIONS,
};

#[test]
fn generated_operation_count_matches_openapi_baseline() {
    assert_eq!(TREE_DB_OPENAPI_OPERATION_COUNT, 113);
    assert_eq!(TREE_DB_OPENAPI_OPERATIONS.len(), 113);
}
