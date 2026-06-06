use bytes::Bytes;
use serde::{Deserialize, Serialize};
use serde_json::Value;

pub type BinaryBody = Bytes;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct MultipartUpload {
    #[serde(rename = "uploadId")]
    pub upload_id: String,
    #[serde(rename = "completedParts", default)]
    pub completed_parts: Vec<Value>,
}

pub fn is_binary_body(_: &BinaryBody) -> bool {
    true
}

pub fn to_bytes(body: impl Into<Bytes>) -> Bytes {
    body.into()
}
