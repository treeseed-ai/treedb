use crate::error::TreeDbResult;
use async_trait::async_trait;
use serde_json::Value;

#[async_trait]
pub trait SnapshotPort: Send + Sync {
    async fn build(&self, repo_id: &str, body: Value) -> TreeDbResult<Value>;
    async fn get(&self, repo_id: &str, snapshot_id: &str) -> TreeDbResult<Value>;
}
