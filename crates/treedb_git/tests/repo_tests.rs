use std::process::Command;
use tempfile::tempdir;
use treedb_git::*;

#[test]
fn missing_path_returns_exists_false() {
    let dir = tempdir().unwrap();
    let result = inspect_repository(&dir.path().join("missing")).unwrap();
    assert!(!result.exists);
    assert!(!result.is_git_repository);
}

#[test]
fn non_git_directory_returns_not_git() {
    let dir = tempdir().unwrap();
    let result = inspect_repository(dir.path()).unwrap();
    assert!(result.exists);
    assert!(!result.is_git_repository);
}

#[test]
fn non_bare_repo_can_be_inspected() {
    let dir = tempdir().unwrap();
    git(dir.path(), &["init", "-b", "main"]);
    git(dir.path(), &["config", "user.name", "TreeDB Test"]);
    git(
        dir.path(),
        &["config", "user.email", "test@example.invalid"],
    );
    std::fs::write(dir.path().join("README.md"), "hello").unwrap();
    git(dir.path(), &["add", "README.md"]);
    git(dir.path(), &["commit", "-m", "init"]);
    git(
        dir.path(),
        &[
            "remote",
            "add",
            "origin",
            "https://example.invalid/demo.git",
        ],
    );

    let result = inspect_repository(dir.path()).unwrap();
    assert!(result.exists);
    assert!(result.is_git_repository);
    assert_eq!(result.is_bare, Some(false));
    assert!(result.refs.iter().any(|r| r.name == "refs/heads/main"));
    assert!(result.remotes.iter().any(|r| r.name == "origin"));
}

#[test]
fn bare_repo_can_be_inspected() {
    let dir = tempdir().unwrap();
    git(dir.path(), &["init", "--bare"]);
    let result = inspect_repository(dir.path()).unwrap();
    assert!(result.is_git_repository);
    assert_eq!(result.is_bare, Some(true));
}

fn git(cwd: &std::path::Path, args: &[&str]) {
    let output = Command::new("git")
        .args(args)
        .current_dir(cwd)
        .output()
        .unwrap();
    assert!(
        output.status.success(),
        "git {:?} failed: {}\n{}",
        args,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}
