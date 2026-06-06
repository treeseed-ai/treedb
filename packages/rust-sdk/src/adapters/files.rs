use std::collections::BTreeMap;
use std::sync::Arc;

use serde_json::Value;

use crate::adapters::common::{json_request, segment};
use crate::error::TreeDbResult;
use crate::transport::{Transport, TreeDbHttpMethod};

#[derive(Clone)]
pub struct FilesAdapter {
    transport: Arc<dyn Transport>,
}

impl FilesAdapter {
    pub fn new(transport: Arc<dyn Transport>) -> Self {
        Self { transport }
    }

    pub async fn tree(
        &self,
        workspace_id: &str,
        query: BTreeMap<String, String>,
    ) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            format!("/api/v1/workspaces/{}/tree", segment(workspace_id)),
            None,
            Some(query),
        )
        .await
    }

    pub async fn read(
        &self,
        workspace_id: &str,
        query: BTreeMap<String, String>,
    ) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            format!("/api/v1/workspaces/{}/files", segment(workspace_id)),
            None,
            Some(query),
        )
        .await
    }

    pub async fn write(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Put,
            format!("/api/v1/workspaces/{}/files", segment(workspace_id)),
            Some(body),
            None,
        )
        .await
    }

    pub async fn patch(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Patch,
            format!("/api/v1/workspaces/{}/files", segment(workspace_id)),
            Some(body),
            None,
        )
        .await
    }

    pub async fn delete(
        &self,
        workspace_id: &str,
        query: BTreeMap<String, String>,
    ) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Delete,
            format!("/api/v1/workspaces/{}/files", segment(workspace_id)),
            None,
            Some(query),
        )
        .await
    }

    pub async fn search(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Post,
            format!("/api/v1/workspaces/{}/search", segment(workspace_id)),
            Some(body),
            None,
        )
        .await
    }

    pub async fn status(&self, workspace_id: &str) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            format!("/api/v1/workspaces/{}/status", segment(workspace_id)),
            None,
            None,
        )
        .await
    }

    pub async fn diff(
        &self,
        workspace_id: &str,
        query: BTreeMap<String, String>,
    ) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            format!("/api/v1/workspaces/{}/diff", segment(workspace_id)),
            None,
            Some(query),
        )
        .await
    }

    pub async fn commit(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Post,
            format!("/api/v1/workspaces/{}/commit", segment(workspace_id)),
            Some(body),
            None,
        )
        .await
    }
}
