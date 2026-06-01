use crate::catalog::{get_record, list_records, put_record};
use crate::error::StoreError;
use crate::ids::mirror_id;
use crate::types::{MirrorRecord, RepositoryPlacementRecord};
use std::path::Path;

pub fn put_repository_placement(
    data_dir: &Path,
    record: RepositoryPlacementRecord,
) -> Result<RepositoryPlacementRecord, StoreError> {
    put_record(
        data_dir,
        "federation/repository_placements.tdb",
        "repository_placement",
        &record.repository_id,
        &record,
    )?;
    Ok(record)
}

pub fn get_repository_placement(
    data_dir: &Path,
    repo_id: &str,
) -> Result<Option<RepositoryPlacementRecord>, StoreError> {
    get_record(
        data_dir,
        "federation/repository_placements.tdb",
        "repository_placement",
        repo_id,
    )
}

pub fn put_mirror(data_dir: &Path, mut record: MirrorRecord) -> Result<MirrorRecord, StoreError> {
    if record.id.is_empty() {
        record.id = mirror_id(
            &record.repository_id,
            &record.source_node_id,
            &record.target_node_id,
            &record.mode,
        );
    }
    put_record(
        data_dir,
        "federation/mirrors.tdb",
        "mirror",
        &record.id,
        &record,
    )?;
    Ok(record)
}

pub fn list_mirrors(data_dir: &Path, repo_id: &str) -> Result<Vec<MirrorRecord>, StoreError> {
    Ok(
        list_records::<MirrorRecord>(data_dir, "federation/mirrors.tdb", "mirror")?
            .into_iter()
            .filter(|record| record.repository_id == repo_id)
            .collect(),
    )
}
