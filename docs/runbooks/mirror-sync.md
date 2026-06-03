# Mirror Sync Runbook

Mirror sync and remote workflows use sanitized remote metadata and credential
IDs only.

Endpoints:

- `GET /api/v1/repos/:repo_id/mirrors`
- `POST /api/v1/repos/:repo_id/mirrors`
- `POST /api/v1/repos/:repo_id/mirrors/:mirror_id/sync`
- `POST /api/v1/repos/:repo_id/mirrors/:mirror_id/health`
- `POST /api/v1/repos/:repo_id/mirrors/:mirror_id/promote`

Authenticated remote access requires an operator-configured credential provider.
Do not put credentials in `remoteUrl`.
