use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait MirrorPort: Send + Sync {
    async fn list(&self, repo_id: &str) -> TreeDbResult<Value>;
    async fn upsert(&self, repo_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn sync(&self, repo_id: &str, mirror_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn health(&self, repo_id: &str, mirror_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn promote(&self, repo_id: &str, mirror_id: &str, body: Value) -> TreeDbResult<Value>;
}
