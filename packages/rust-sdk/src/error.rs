use serde_json::Value;
use thiserror::Error;

#[derive(Debug, Error)]
#[error("{message}")]
pub struct TreeDbApiError {
    pub status: u16,
    pub code: String,
    pub message: String,
    pub details: Option<Value>,
    pub payload: Option<Value>,
}

pub type TreeDbResult<T> = Result<T, TreeDbApiError>;

impl TreeDbApiError {
    pub fn from_response(status: u16, payload: Value) -> Self {
        let error = payload.get("error").unwrap_or(&payload);
        let code = error
            .get("code")
            .and_then(Value::as_str)
            .unwrap_or("service_unavailable")
            .to_string();
        let message = error
            .get("message")
            .and_then(Value::as_str)
            .unwrap_or("TreeDB request failed")
            .to_string();
        let details = error.get("details").cloned();

        Self {
            status,
            code,
            message,
            details,
            payload: Some(payload),
        }
    }

    pub fn network(message: impl Into<String>) -> Self {
        Self {
            status: 0,
            code: "network_error".to_string(),
            message: message.into(),
            details: None,
            payload: None,
        }
    }
}
