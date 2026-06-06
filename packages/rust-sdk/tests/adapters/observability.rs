mod common;
use common::{MockTransport, client_with_mock, request_keys};
use std::sync::Arc;

#[tokio::test]
async fn all_constructs_expected_request() {
    let mock = Arc::new(MockTransport::default());
    let client = client_with_mock(mock.clone());
    client.observability().health().await.unwrap();
    client.observability().ready().await.unwrap();
    client.observability().deep_health().await.unwrap();
    client.observability().metrics().await.unwrap();
    assert!(request_keys(&mock).contains(&"GET /api/v1/metrics".to_string()));
}
