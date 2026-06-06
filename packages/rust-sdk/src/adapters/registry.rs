use std::sync::Arc;

use serde_json::Value;

use crate::adapters::common::{json_request, segment};
use crate::error::TreeDbResult;
use crate::transport::{Transport, TreeDbHttpMethod};

#[derive(Clone)]
pub struct RegistryAdapter {
    transport: Arc<dyn Transport>,
}

impl RegistryAdapter {
    pub fn new(transport: Arc<dyn Transport>) -> Self {
        Self { transport }
    }

    pub async fn local_node(&self) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            "/api/v1/node",
            None,
            None,
        )
        .await
    }

    pub async fn nodes(&self) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            "/api/v1/registry/nodes",
            None,
            None,
        )
        .await
    }

    pub async fn get_placement(&self, repo_id: &str) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            format!("/api/v1/registry/repos/{}/placement", segment(repo_id)),
            None,
            None,
        )
        .await
    }

    pub async fn set_placement(&self, repo_id: &str, body: Value) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Post,
            format!("/api/v1/registry/repos/{}/placement", segment(repo_id)),
            Some(body),
            None,
        )
        .await
    }
}
