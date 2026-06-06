use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait WorkspacePort: Send + Sync {
    async fn create(&self, repo_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn get(&self, workspace_id: &str) -> TreeDbResult<Value>;
    async fn close(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value>;
}
