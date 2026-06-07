use treedx::conformance::TreeDxConformanceAdapter;
use treedx::generated::openapi_types::TREEDX_OPENAPI_OPERATIONS;
use treedx::{TreeDxApiError, TreeDxClient, TreeDxConfig};

#[test]
fn public_exports_compile() {
    let _ = TREEDX_OPENAPI_OPERATIONS;
    let client = TreeDxClient::new(TreeDxConfig {
        base_url: "http://localhost:4000".to_string(),
        ..Default::default()
    });
    let _adapter = TreeDxConformanceAdapter::new(client);
    let error = TreeDxApiError::network("offline");
    assert_eq!(error.code, "network_error");
}
