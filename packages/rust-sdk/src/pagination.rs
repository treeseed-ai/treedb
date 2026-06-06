use serde::{Deserialize, Serialize};

pub type TreeDbCursor = String;

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct TreeDbPage<T> {
    pub items: Vec<T>,
    #[serde(rename = "nextCursor", skip_serializing_if = "Option::is_none")]
    pub next_cursor: Option<String>,
    #[serde(rename = "hasMore", skip_serializing_if = "Option::is_none")]
    pub has_more: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cursor: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub limit: Option<u32>,
}

pub fn create_page<T>(items: Vec<T>) -> TreeDbPage<T> {
    TreeDbPage {
        items,
        next_cursor: None,
        has_more: None,
        cursor: None,
        limit: None,
    }
}

pub fn get_next_cursor<T>(page: &TreeDbPage<T>) -> Option<&str> {
    page.next_cursor.as_deref()
}
