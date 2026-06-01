use tempfile::tempdir;
use treedb_store::*;

#[test]
fn effective_scope_resolves_wildcard_dev_capabilities() {
    let dir = tempdir().unwrap();
    init_data_dir(
        dir.path(),
        InitOptions {
            node_id: "node_local".to_string(),
        },
    )
    .unwrap();
    seed_dev_records(dir.path(), "node_local", "http://localhost:4000").unwrap();
    let scope = resolve_effective_scope(dir.path(), "actor_demo", Some("repo_any")).unwrap();
    assert_eq!(scope.tenant_id, "tenant_demo");
    assert!(scope.repo_ids.contains(&"*".to_string()));
    assert!(scope.capabilities.contains(&"registry:write".to_string()));
}
