use crate::error::GitError;
use crate::repo::git_dir;
use crate::types::GitRefSummary;
use std::path::Path;

pub fn list_refs(path: &Path) -> Result<Vec<GitRefSummary>, GitError> {
    let git_dir = git_dir(path);
    let mut refs = Vec::new();
    collect_refs(
        &git_dir.join("refs/heads"),
        "refs/heads",
        "branch",
        &mut refs,
    )?;
    collect_refs(&git_dir.join("refs/tags"), "refs/tags", "tag", &mut refs)?;
    refs.sort_by(|a, b| a.name.cmp(&b.name));
    Ok(refs)
}

fn collect_refs(
    dir: &Path,
    prefix: &str,
    kind: &str,
    refs: &mut Vec<GitRefSummary>,
) -> Result<(), GitError> {
    if !dir.exists() {
        return Ok(());
    }
    for entry in std::fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_dir() {
            let name = entry.file_name().to_string_lossy().to_string();
            collect_refs(&path, &format!("{prefix}/{name}"), kind, refs)?;
        } else if path.is_file() {
            let name = entry.file_name().to_string_lossy().to_string();
            let target = std::fs::read_to_string(&path)
                .ok()
                .map(|value| value.trim().to_string());
            refs.push(GitRefSummary {
                name: format!("{prefix}/{name}"),
                target,
                kind: kind.to_string(),
            });
        }
    }
    Ok(())
}
