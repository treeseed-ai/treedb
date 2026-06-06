use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait BlobPort: Send + Sync {
    async fn read(&self, repo_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn write(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn delete(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value>;
}
