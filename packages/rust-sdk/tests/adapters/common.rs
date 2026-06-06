#![allow(dead_code)]
use std::collections::BTreeMap;
use std::sync::{Arc, Mutex};

use async_trait::async_trait;
use serde_json::json;
use treedb_sdk::{
    Transport, TreeDbClient, TreeDbConfig, TreeDbRequest, TreeDbResponse, TreeDbResult,
};

#[derive(Default)]
pub struct MockTransport {
    pub requests: Mutex<Vec<TreeDbRequest>>,
}

#[async_trait]
impl Transport for MockTransport {
    async fn request(&self, request: TreeDbRequest) -> TreeDbResult<TreeDbResponse> {
        self.requests.lock().unwrap().push(request);
        Ok(TreeDbResponse {
            status: 200,
            headers: BTreeMap::new(),
            data: json!({ "ok": true }),
        })
    }
}

pub fn client_with_mock(mock: Arc<MockTransport>) -> TreeDbClient {
    TreeDbClient::with_transport(
        TreeDbConfig {
            base_url: "http://localhost:4000".to_string(),
            ..Default::default()
        },
        mock,
    )
}

pub fn request_keys(mock: &MockTransport) -> Vec<String> {
    mock.requests
        .lock()
        .unwrap()
        .iter()
        .map(|request| format!("{} {}", request.method.as_str(), request.path))
        .collect()
}
