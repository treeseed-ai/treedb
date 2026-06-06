use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait RepositoryPort: Send + Sync {
    async fn register(&self, body: Value) -> TreeDbResult<Value>;
    async fn list(&self) -> TreeDbResult<Value>;
    async fn create(&self, body: Value) -> TreeDbResult<Value>;
    async fn get(&self, repo_id: &str) -> TreeDbResult<Value>;
}
