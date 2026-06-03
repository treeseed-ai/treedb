# Storage Recovery Runbook

1. Run protected health and check:

```bash
curl -H "authorization: Bearer $TOKEN" "$TREEDB_URL/api/v1/admin/storage/health"
curl -X POST -H "authorization: Bearer $TOKEN" "$TREEDB_URL/api/v1/admin/storage/check"
```

2. Create and verify a backup:

```bash
curl -X POST -H "authorization: Bearer $TOKEN" \
  -H "content-type: application/json" \
  -d '{"verify":true}' \
  "$TREEDB_URL/api/v1/admin/storage/backup"
```

3. Verify restore before applying:

```bash
curl -X POST -H "authorization: Bearer $TOKEN" \
  -H "content-type: application/json" \
  -d '{"backupId":"backup_..."}' \
  "$TREEDB_URL/api/v1/admin/storage/restore/verify"
```

4. Apply restore only in recovery mode or with explicit force and
   `TREEDB_STORAGE_RESTORE_ENABLED=true`.

Public responses must contain logical IDs and `treedb://backup/...` URIs only.
