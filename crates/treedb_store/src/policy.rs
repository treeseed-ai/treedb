use crate::catalog::{get_record, list_records, put_record};
use crate::error::StoreError;
use crate::types::{CapabilityGrantRecord, DevTokenRecord, EffectiveScope};
use std::path::Path;

pub fn put_dev_token(data_dir: &Path, record: DevTokenRecord) -> Result<(), StoreError> {
    put_record(
        data_dir,
        "config/dev_tokens.tdb",
        "dev_token",
        &record.token_hash,
        &record,
    )
}

pub fn get_dev_token_by_hash(
    data_dir: &Path,
    token_hash: &str,
) -> Result<Option<DevTokenRecord>, StoreError> {
    get_record(data_dir, "config/dev_tokens.tdb", "dev_token", token_hash)
}

pub fn resolve_effective_scope(
    data_dir: &Path,
    actor_id: &str,
    repo_id: Option<&str>,
) -> Result<EffectiveScope, StoreError> {
    let grants = list_records::<CapabilityGrantRecord>(
        data_dir,
        "catalog/capability_grants.tdb",
        "capability_grant",
    )?;
    let mut tenant_id = String::new();
    let mut repo_ids = Vec::new();
    let mut capabilities = Vec::new();
    let mut refs = Vec::new();
    let mut paths = Vec::new();

    for grant in grants
        .into_iter()
        .filter(|grant| grant.actor_id == actor_id)
    {
        if let Some(target_repo) = repo_id {
            if !grant
                .repo_ids
                .iter()
                .any(|id| id == "*" || id == target_repo)
            {
                continue;
            }
        }
        if tenant_id.is_empty() {
            tenant_id = grant.tenant_id.clone();
        }
        extend_unique(&mut repo_ids, grant.repo_ids);
        extend_unique(&mut capabilities, grant.capabilities);
        extend_unique(&mut refs, grant.refs);
        extend_unique(&mut paths, grant.paths);
    }

    if tenant_id.is_empty() {
        return Err(StoreError::NotFound(format!(
            "actor {actor_id} has no grants"
        )));
    }

    Ok(EffectiveScope {
        actor_id: actor_id.to_string(),
        tenant_id,
        repo_ids,
        capabilities,
        refs,
        paths,
    })
}

fn extend_unique(target: &mut Vec<String>, values: Vec<String>) {
    for value in values {
        if !target.contains(&value) {
            target.push(value);
        }
    }
}
