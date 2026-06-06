use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait ExecPort: Send + Sync {
    async fn run(&self, workspace_id: &str, body: Value) -> TreeDbResult<Value>;
}
