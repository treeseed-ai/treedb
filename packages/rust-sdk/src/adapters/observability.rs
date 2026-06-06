use std::sync::Arc;

use serde_json::Value;

use crate::adapters::common::json_request;
use crate::error::TreeDbResult;
use crate::transport::{Transport, TreeDbHttpMethod};

#[derive(Clone)]
pub struct ObservabilityAdapter {
    transport: Arc<dyn Transport>,
}

impl ObservabilityAdapter {
    pub fn new(transport: Arc<dyn Transport>) -> Self {
        Self { transport }
    }

    pub async fn health(&self) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            "/api/v1/health",
            None,
            None,
        )
        .await
    }

    pub async fn ready(&self) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            "/api/v1/ready",
            None,
            None,
        )
        .await
    }

    pub async fn deep_health(&self) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            "/api/v1/health/deep",
            None,
            None,
        )
        .await
    }

    pub async fn metrics(&self) -> TreeDbResult<Value> {
        json_request(
            &self.transport,
            TreeDbHttpMethod::Get,
            "/api/v1/metrics",
            None,
            None,
        )
        .await
    }
}
