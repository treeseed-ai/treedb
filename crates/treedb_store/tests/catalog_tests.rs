use chrono::{Duration, Utc};
use tempfile::tempdir;
use treedb_store::*;

#[test]
fn init_data_dir_creates_directories_and_manifest() {
    let dir = tempdir().unwrap();
    let report = init_data_dir(
        dir.path(),
        InitOptions {
            node_id: "node_local".to_string(),
        },
    )
    .unwrap();
    assert!(dir.path().join("catalog/manifest.tdb").exists());
    assert!(dir.path().join("repos/bare").is_dir());
    assert!(report
        .directories
        .contains(&"workspaces/active".to_string()));
}

#[test]
fn seed_dev_records_is_idempotent() {
    let dir = tempdir().unwrap();
    init_data_dir(
        dir.path(),
        InitOptions {
            node_id: "node_local".to_string(),
        },
    )
    .unwrap();
    seed_dev_records(dir.path(), "node_local", "http://localhost:4000").unwrap();
    seed_dev_records(dir.path(), "node_local", "http://localhost:4000").unwrap();
    assert_eq!(list_nodes(dir.path()).unwrap().len(), 1);
    let scope = resolve_effective_scope(dir.path(), "actor_demo", None).unwrap();
    assert!(scope.capabilities.contains(&"repos:write".to_string()));
}

#[test]
fn repository_records_persist_and_ids_are_deterministic() {
    let dir = tempdir().unwrap();
    init_data_dir(
        dir.path(),
        InitOptions {
            node_id: "node_local".to_string(),
        },
    )
    .unwrap();
    let input = RepositoryInput {
        name: "demo".to_string(),
        local_path: "/var/lib/treedb/repos/bare/demo.git".to_string(),
        default_ref: None,
        remote_url: Some("https://example.invalid/demo.git".to_string()),
    };
    let first = put_repository(dir.path(), input.clone()).unwrap();
    let second = put_repository(dir.path(), input).unwrap();
    assert_eq!(first.id, second.id);
    assert_eq!(list_repositories(dir.path()).unwrap().len(), 1);
    assert_eq!(
        get_repository(dir.path(), &first.id).unwrap().unwrap().name,
        "demo"
    );
}

#[test]
fn placement_and_mirrors_persist() {
    let dir = tempdir().unwrap();
    init_data_dir(
        dir.path(),
        InitOptions {
            node_id: "node_local".to_string(),
        },
    )
    .unwrap();
    put_repository_placement(
        dir.path(),
        RepositoryPlacementRecord {
            repository_id: "repo_demo".to_string(),
            primary_node_id: "node_local".to_string(),
            mirror_node_ids: vec![],
            read_policy: "primary_or_mirror".to_string(),
            write_policy: "primary_only".to_string(),
            migration_state: "stable".to_string(),
        },
    )
    .unwrap();
    assert!(get_repository_placement(dir.path(), "repo_demo")
        .unwrap()
        .is_some());
    put_mirror(
        dir.path(),
        MirrorRecord {
            id: String::new(),
            repository_id: "repo_demo".to_string(),
            source_node_id: "node_local".to_string(),
            target_node_id: "node_b".to_string(),
            mode: "read_replica".to_string(),
            last_seen_commit: None,
            behind_by: None,
            status: "planned".to_string(),
        },
    )
    .unwrap();
    assert_eq!(list_mirrors(dir.path(), "repo_demo").unwrap().len(), 1);
}

#[test]
fn dev_token_records_persist() {
    let dir = tempdir().unwrap();
    init_data_dir(
        dir.path(),
        InitOptions {
            node_id: "node_local".to_string(),
        },
    )
    .unwrap();
    let token_hash = hash_token("secret");
    put_dev_token(
        dir.path(),
        DevTokenRecord {
            token_hash: token_hash.clone(),
            actor_id: "actor_demo".to_string(),
            tenant_id: "tenant_demo".to_string(),
            expires_at: Utc::now() + Duration::seconds(60),
            created_at: Utc::now(),
        },
    )
    .unwrap();
    assert_eq!(
        get_dev_token_by_hash(dir.path(), &token_hash)
            .unwrap()
            .unwrap()
            .actor_id,
        "actor_demo"
    );
}
