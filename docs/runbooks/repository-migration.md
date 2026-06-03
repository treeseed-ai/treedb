# Repository Migration And Storage Migration Runbook

Repository placement migrations continue to use:

- `POST /api/v1/repos/:repo_id/migrations`
- `GET /api/v1/repos/:repo_id/migrations/:migration_id`

Storage format migrations use:

- `GET /api/v1/admin/storage/migrations`
- `POST /api/v1/admin/storage/migrations/plan`
- `POST /api/v1/admin/storage/migrations/apply`
- `POST /api/v1/admin/storage/migrations/rollback`

Always run `plan` first. `apply` requires `policy:write` and records a logical
migration entry. Rollback is intended for reversible migrations and returns
logical metadata only.
