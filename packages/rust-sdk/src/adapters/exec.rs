use std::sync::Arc;

use serde_json::Value;

use crate::adapters::common::{json_request, segment};
use crate::error::TreeDbResult;
use crate::transport::{Transport, TreeDbHttpMethod};

#[derive(Clone)]
pub struct ExecAdapter {
    transport: Arc<dyn Transport>,
}

impl ExecAdapter {
    pub fn new(transport: Arc<dyn Transport>) -> Self {
        Self { transport }
    }

    pub async fn run(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Post,
            format!("/api/v1/workspaces/{}/exec", segment(workspace_id)),
            Some(body),
            None,
        )
        .await
    }
}
