use crate::catalog::put_record;
use crate::error::StoreError;
use crate::ids::audit_event_id;
use crate::types::{AuditEventInput, AuditEventRecord};
use chrono::Utc;
use std::path::Path;

pub fn append_audit_event(
    data_dir: &Path,
    input: AuditEventInput,
) -> Result<AuditEventRecord, StoreError> {
    let recorded_at = Utc::now();
    let id = audit_event_id(
        &input.event_type,
        &recorded_at.to_rfc3339(),
        input.request_id.as_deref(),
    );
    let record = AuditEventRecord {
        id: id.clone(),
        event_type: input.event_type,
        actor_id: input.actor_id,
        tenant_id: input.tenant_id,
        repo_id: input.repo_id,
        node_id: input.node_id,
        request_id: input.request_id,
        data: input.data,
        recorded_at,
    };
    put_record(data_dir, "audit/events.tdb", "audit_event", &id, &record)?;
    Ok(record)
}
