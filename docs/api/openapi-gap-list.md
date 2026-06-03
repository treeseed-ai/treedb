# TreeDB OpenAPI Gap List

Status: Route and schema gap inventory

`docs/api/openapi.yaml` is currently a human-maintained route inventory with
generic envelopes. It is complete enough to prevent missing-route drift, but it
is not yet a schema-complete contract.

## Routes With Generic `OkEnvelope`

Many routes still use the generic `OkEnvelope` response. The route inventory
keeps this explicit to avoid pretending the contract is stricter than the
implementation.

Priority routes for typed response schemas:

1. Auth and policy:
   - `/api/v1/auth/whoami`
   - `/api/v1/auth/mode`
   - `/api/v1/policy/effective-scope`
2. Repository and workspace:
   - `/api/v1/repos/register`
   - `/api/v1/repos/{repo_id}`
   - `/api/v1/repos/{repo_id}/workspaces`
   - `/api/v1/workspaces/{workspace_id}`
3. File/query:
   - `/api/v1/workspaces/{workspace_id}/files`
   - `/api/v1/workspaces/{workspace_id}/blobs/write`
   - `/api/v1/workspaces/{workspace_id}/blobs/download`
   - `/api/v1/repos/{repo_id}/files/read`
   - `/api/v1/repos/{repo_id}/blobs/read`
   - `/api/v1/repos/{repo_id}/query`
4. Graph/context:
   - `/api/v1/repos/{repo_id}/graph/refresh`
   - `/api/v1/repos/{repo_id}/graph/refresh-jobs/{job_id}`
   - `/api/v1/repos/{repo_id}/graph/query`
   - `/api/v1/repos/{repo_id}/context/build`
   - `/api/v1/repos/{repo_id}/search/index/refresh`
   - `/api/v1/repos/{repo_id}/search/index/status`
   - `/api/v1/repos/{repo_id}/search/index/compact`
5. Snapshot/mirror/migration:
   - `/api/v1/repos/{repo_id}/snapshots/build`
   - `/api/v1/repos/{repo_id}/artifacts/export`
   - `/api/v1/repos/{repo_id}/mirrors/{mirror_id}/sync`
   - `/api/v1/repos/{repo_id}/migrations`

## Missing Request Schemas

Request bodies are not yet schema-complete for:

- repository registration
- policy refresh and grant updates
- federation planning
- repository file read/search/path/query
- repository blob read
- graph refresh/query/search/traversal
- graph refresh job status
- search index refresh/status/compact
- context build and parse
- snapshot build and artifact export
- workspace create/write/patch/search/commit/exec
- workspace blob write/delete/upload/download
- repository push and fetch remote bodies
- mirror health and promotion bodies
- admin storage compact and backup bodies
- mirror sync and migration creation
- federated global search, query, context, and graph bodies

## Missing Response Schemas

Response schemas are not yet complete for:

- principal/auth mode
- effective scope
- capability grants
- audit events
- node/placement/mirror/migration records
- repository/ref/remote/status records
- workspace and file mutation results
- blob read, mutation, upload, and download metadata
- git push/fetch, mirror health/promotion, and storage compact/backup records
- graph/context results
- graph refresh job records and search index records
- federated diagnostics, partial errors, and cross-repo graph results
- snapshot/artifact records

## Missing Error Examples

Add examples for:

- `authentication_required`
- `invalid_token`
- `permission_denied`
- `workspace_revoked`
- `not_found`
- `conflict`
- `validation_error`
- `unsupported_media_type`
- `payload_too_large`
- `graph_not_ready`
- `unsupported_transport`
- `sandbox_unavailable`
- `sandbox_policy_denied`
- `backup_failed`
- `storage_compaction_failed`

## Binary Blob Follow-Ups

Implemented blob routes are binary-safe but still use generic OpenAPI
envelopes. Schema work should add typed contracts for:

- base64 blob read/write request and response bodies
- raw upload headers (`x-treedb-expected-sha`,
  `x-treedb-expected-content-hash`, `x-treedb-allow-protected`)
- raw download metadata headers (`x-treedb-content-hash`,
  `x-treedb-object-id`, `x-treedb-source`)
- `payload_too_large`, malformed base64, hash mismatch, and
  `workspace_revoked` examples

Production hardening routes now cover resumable multipart blob uploads,
artifact lifecycle metadata, retention cleanup, storage migration metadata, and
guarded restore verification. These routes still use generic envelopes until
OpenAPI schema generation adds fully typed request/response schemas.

## Transport, Sandbox, and Storage Follow-Ups

Transport, sandbox, and storage routes are documented with operation metadata
but still use generic `OkEnvelope`/`ErrorEnvelope` schemas. Schema work should add typed
contracts for:

- explicit push/fetch refspec request bodies and sanitized remote response
  payloads
- mirror health and promotion result payloads
- exec sandbox metadata, resource limits, and sandbox error envelopes
- storage compaction per-file statistics and logical backup records

Credential-ID based Git remotes, constrained external transport, external
worker and microVM-profile exec, storage migration metadata, guarded restore
verification, and artifact retention cleanup are now documented as
production-hardening route/API surfaces. Fully generated schemas and external
infrastructure conformance tests remain later API contract/release work.

## Hand-Maintained SDK Types

TreeDB SDK types are currently hand-maintained in:

```text
packages/ts-sdk/src/treedb/types.ts
```

Export tests lock public TreeDB SDK surfaces. Future contract work should
decide whether to generate these types from OpenAPI or keep hand-maintained
types with explicit drift checks.

The SDK keeps the types hand-maintained and uses SDK/OpenAPI drift tests for
critical TreeDB routes and package export subpaths. Full schema-generated SDK
types remain deferred until route schemas are more complete.

## Recommended Closure Order

1. Keep route inventory and `operationId` metadata complete in every PR.
2. Add typed schemas for auth, error, effective scope, repository, workspace,
   and file APIs.
3. Add contract tests validating Phoenix responses against OpenAPI.
4. Add SDK request construction tests against OpenAPI.
5. Evaluate OpenAPI-generated SDK types once schema coverage is stable.
