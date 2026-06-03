# Security Incident Runbook

TreeDB production incident response should start by preserving audit logs and
revoking affected credentials or policy grants.

Immediate checks:

- review `GET /api/v1/audit/events` with `audit:read`.
- rotate any remote credential IDs involved in Git operations.
- disable `TREEDB_GIT_EXTERNAL_TRANSPORT_ENABLED` if remote transport is suspect.
- disable `TREEDB_EXEC_BACKEND=external_worker` or rotate worker token/HMAC if
  worker transport is suspect.
- quarantine affected workspaces through policy revocation and verify
  `workspace.quarantined` audit events.

Public TreeDB responses and audit payloads must not contain raw credentials,
local filesystem paths, hidden refs, hidden paths, snippets, stdout/stderr, or
binary payloads.
