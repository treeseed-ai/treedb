# TreeDB OpenAPI Gap List

Status: Stage 0 baseline

`docs/api/openapi.yaml` is currently a human-maintained route inventory with
generic envelopes. It is complete enough to prevent missing-route drift, but it
is not yet a schema-complete contract.

## Routes With Generic `OkEnvelope`

All current MVP routes still use the generic `OkEnvelope` response. Stage 0
keeps this intentionally to avoid pretending the contract is stricter than the
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
   - `/api/v1/repos/{repo_id}/files/read`
   - `/api/v1/repos/{repo_id}/query`
4. Graph/context:
   - `/api/v1/repos/{repo_id}/graph/query`
   - `/api/v1/repos/{repo_id}/context/build`
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
- graph refresh/query/search/traversal
- context build and parse
- snapshot build and artifact export
- workspace create/write/patch/search/commit/exec
- mirror sync and migration creation

## Missing Response Schemas

Response schemas are not yet complete for:

- principal/auth mode
- effective scope
- capability grants
- audit events
- node/placement/mirror/migration records
- repository/ref/remote/status records
- workspace and file mutation results
- graph/context results
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

## Hand-Maintained SDK Types

TreeDB SDK types are currently hand-maintained in:

```text
packages/ts-sdk/src/treedb/types.ts
```

Stage 0 locks public exports with tests. Later stages should decide whether to
generate these types from OpenAPI or keep hand-maintained types with explicit
drift checks.

## Recommended Closure Order

1. Keep route inventory and `operationId` metadata complete in every PR.
2. Add typed schemas for auth, error, effective scope, repository, workspace,
   and file APIs.
3. Add contract tests validating Phoenix responses against OpenAPI.
4. Add SDK request construction tests against OpenAPI.
5. Evaluate OpenAPI-generated SDK types once schema coverage is stable.
