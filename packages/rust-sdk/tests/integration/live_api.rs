use treedb_sdk::{TreeDbClient, TreeDbConfig};

#[tokio::test]
async fn live_health_is_optional() {
    let Ok(base_url) = std::env::var("TREEDB_BASE_URL") else {
        eprintln!("TreeDB integration not configured: TREEDB_BASE_URL is absent");
        return;
    };

    let client = TreeDbClient::new(TreeDbConfig {
        base_url,
        token: std::env::var("TREEDB_TOKEN").ok(),
        ..Default::default()
    });
    client.health().await.unwrap();
}
