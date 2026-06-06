use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait ArtifactPort: Send + Sync {
    async fn export(&self, repo_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn list(&self, repo_id: &str) -> TreeDbResult<Value>;
    async fn get(&self, repo_id: &str, artifact_id: &str) -> TreeDbResult<Value>;
    async fn delete(&self, repo_id: &str, artifact_id: &str) -> TreeDbResult<Value>;
}
