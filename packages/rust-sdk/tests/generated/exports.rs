use treedb_sdk::conformance::TreeDbConformanceAdapter;
use treedb_sdk::generated::openapi_types::TREE_DB_OPENAPI_OPERATIONS;
use treedb_sdk::{TreeDbApiError, TreeDbClient, TreeDbConfig};

#[test]
fn public_exports_compile() {
    let _ = TREE_DB_OPENAPI_OPERATIONS;
    let client = TreeDbClient::new(TreeDbConfig {
        base_url: "http://localhost:4000".to_string(),
        ..Default::default()
    });
    let _adapter = TreeDbConformanceAdapter::new(client);
    let error = TreeDbApiError::network("offline");
    assert_eq!(error.code, "network_error");
}
