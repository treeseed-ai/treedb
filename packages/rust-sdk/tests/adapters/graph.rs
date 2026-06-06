mod common;
use common::{MockTransport, client_with_mock, request_keys};
use serde_json::json;
use std::sync::Arc;

#[tokio::test]
async fn all_constructs_expected_request() {
    let mock = Arc::new(MockTransport::default());
    let client = client_with_mock(mock.clone());
    client.graph().refresh("repo/a", json!({})).await.unwrap();
    client.graph().query("repo/a", json!({})).await.unwrap();
    assert!(request_keys(&mock).contains(&"POST /api/v1/repos/repo%2Fa/graph/query".to_string()));
}
