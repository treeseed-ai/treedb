# TreeDB API Compatibility Notes

## Current Contract

- TreeDB API path prefix: `/api/v1`
- SDK package subpaths: `@treeseed/sdk/treedb`, `/client`, `/types`, `/adapters`
- Generated type source: `docs/api/openapi.yaml`
- Public compatibility gate: `scripts/test-treedb-fast.sh`
- Error envelopes and error codes are stable public contract surfaces.
- Operational health and metrics routes are covered by the same OpenAPI and SDK
  generation contract.
- Managed repository creation uses canonical `repositoryName` values and
  repository-relative file paths. Absolute `localPath` input is
  compatibility-only and not part of normal public repository access.
- Federation catalogs and route responses expose logical node, repository,
  route, capacity, and mirror metadata only. They must not expose storage paths,
  credentials, user tokens, node tokens, delegated tokens, hidden paths,
  snippets, stdout/stderr, request bodies, or binary payloads.
- Additive route metadata such as `route.source`, `route.primaryNodeId`,
  `route.servedByNodeId`, and `route.proxied` is compatible when documented and
  optional.
