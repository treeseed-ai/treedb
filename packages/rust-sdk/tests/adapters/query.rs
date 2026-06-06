mod common;
use common::{MockTransport, client_with_mock, request_keys};
use serde_json::json;
use std::sync::Arc;

#[tokio::test]
async fn all_constructs_expected_request() {
    let mock = Arc::new(MockTransport::default());
    let client = client_with_mock(mock.clone());
    client.query().read_file("repo/a", json!({})).await.unwrap();
    client
        .query()
        .list_paths("repo/a", json!({}))
        .await
        .unwrap();
    client
        .query()
        .search_files("repo/a", json!({}))
        .await
        .unwrap();
    client
        .query()
        .repository("repo/a", json!({}))
        .await
        .unwrap();
    assert!(request_keys(&mock).contains(&"POST /api/v1/repos/repo%2Fa/query".to_string()));
}
