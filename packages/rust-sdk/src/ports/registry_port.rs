use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait RegistryPort: Send + Sync {
    async fn local_node(&self) -> TreeDbResult<Value>;
    async fn nodes(&self) -> TreeDbResult<Value>;
    async fn get_placement(&self, repo_id: &str) -> TreeDbResult<Value>;
    async fn set_placement(&self, repo_id: &str, body: Value) -> TreeDbResult<Value>;
}
