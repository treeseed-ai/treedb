use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RepositoryInspection {
    pub path: String,
    pub exists: bool,
    pub is_git_repository: bool,
    pub is_bare: Option<bool>,
    pub head: Option<String>,
    pub refs: Vec<GitRefSummary>,
    pub remotes: Vec<GitRemoteSummary>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GitRefSummary {
    pub name: String,
    pub target: Option<String>,
    pub kind: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GitRemoteSummary {
    pub name: String,
    pub url: Option<String>,
}
