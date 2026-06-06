use treedb_sdk::transport::{TreeDbHttpMethod, TreeDbRequest};

#[test]
fn request_defaults_are_empty() {
    let request = TreeDbRequest::new(TreeDbHttpMethod::Get, "/api/v1/health");
    assert_eq!(request.method.as_str(), "GET");
    assert_eq!(request.path, "/api/v1/health");
    assert!(request.query.is_empty());
}
