use std::io::Write;
use tempfile::tempdir;
use treedb_store::*;

#[test]
fn corrupt_payload_checksum_returns_recovery_error() {
    let dir = tempdir().unwrap();
    init_data_dir(
        dir.path(),
        InitOptions {
            node_id: "node_local".to_string(),
        },
    )
    .unwrap();
    put_repository(
        dir.path(),
        RepositoryInput {
            name: "demo".to_string(),
            local_path: "/var/lib/treedb/repos/bare/demo.git".to_string(),
            default_ref: None,
            remote_url: None,
        },
    )
    .unwrap();
    let path = dir.path().join("catalog/repositories.tdb");
    let mut raw = std::fs::read_to_string(&path).unwrap();
    raw = raw.replace("\"name\":\"demo\"", "\"name\":\"tampered\"");
    let mut file = std::fs::File::create(&path).unwrap();
    file.write_all(raw.as_bytes()).unwrap();
    let err = list_repositories(dir.path()).unwrap_err();
    assert_eq!(err.code(), "checksum_mismatch");
}
