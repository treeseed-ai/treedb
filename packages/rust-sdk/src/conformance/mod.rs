use serde::Deserialize;

use crate::client::TreeDbClient;

#[derive(Clone, Debug, Deserialize)]
pub struct TreeDbConformanceScenario {
    pub id: String,
    #[serde(rename = "capabilityId")]
    pub capability_id: String,
    pub title: String,
    pub required: bool,
    #[serde(rename = "endpointRefs")]
    pub endpoint_refs: Vec<String>,
    pub steps: Vec<serde_json::Value>,
    pub assertions: Vec<String>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum TreeDbConformanceStatus {
    Passed,
    Failed,
    NotConfigured,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TreeDbConformanceResult {
    pub scenario_id: String,
    pub status: TreeDbConformanceStatus,
    pub message: Option<String>,
}

pub struct TreeDbConformanceAdapter {
    client: TreeDbClient,
    server_configured: bool,
}

impl TreeDbConformanceAdapter {
    pub fn new(client: TreeDbClient) -> Self {
        Self {
            client,
            server_configured: false,
        }
    }

    pub fn with_server_configured(client: TreeDbClient, server_configured: bool) -> Self {
        Self {
            client,
            server_configured,
        }
    }

    pub async fn run_scenario(
        &self,
        scenario: &TreeDbConformanceScenario,
    ) -> TreeDbConformanceResult {
        let _ = &self.client;
        let message = if self.server_configured {
            "executable scenario dispatch is deferred to a later phase"
        } else {
            "TreeDB server is not configured"
        };
        TreeDbConformanceResult {
            scenario_id: scenario.id.clone(),
            status: TreeDbConformanceStatus::NotConfigured,
            message: Some(message.to_string()),
        }
    }
}
