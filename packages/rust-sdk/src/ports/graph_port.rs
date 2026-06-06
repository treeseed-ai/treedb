use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait GraphPort: Send + Sync {
    async fn refresh(&self, repo_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn query(&self, repo_id: &str, body: Value) -> TreeDbResult<Value>;
}
