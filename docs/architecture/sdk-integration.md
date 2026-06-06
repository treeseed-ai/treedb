# SDK Integration Architecture

TreeDB is the default adapter for the TreeSeed project content repository. The
TreeSeed SDK configures the TreeDB service, auth, optional ref/workspace
context, content path maps, and repository-selection hints. It does not
configure one global repository id.

`packages/ts-sdk` remains the generic TypeScript TreeDB SDK. `packages/trsd-sdk`
is a downstream TreeSeed consumer that uses `@treedb/ts-sdk` for TreeDB access
and keeps TreeSeed product semantics out of the generic SDK architecture.

## Runtime Shape

`AgentSdk` normalizes TreeDB options into:

- `TreeDbClient`
- optional `TreeDbRegistryClient`
- optional `TreeDbFederatedClient`
- portfolio repository discovery through `TreeDbPortfolioResolver`
- content, graph, and exec backends that call the generic TreeDB SDK

TreeDB is a portfolio of repositories. Repository ids are discovered internally
through TreeDB APIs such as repository listing, registry placement, and
portfolio search. Repo-scoped TreeDB endpoints receive repository ids only after
that discovery step.

## Local Filesystem Boundary

Local filesystem/git remains the default for:

- project site source files;
- build, watch, and deploy code;
- optional project repositories;
- embedded repositories or submodules maintained by agents;
- GitHub automation and repository operations.

`AgentSdk.createLocal()` and `contentRepository.adapter = 'local'` force local
content behavior. Local mode remains supported for fixture sites, local-only
development, and workflows that do not configure a TreeDB service.

## TreeDB Content Configuration

TreeDB-backed content uses service-level configuration:

```ts
const sdk = new AgentSdk({
  treeDb: {
    baseUrl: 'http://localhost:4000',
    token: process.env.TREESEED_TREEDB_TOKEN,
    ref: 'refs/heads/main',
    workspaceId: process.env.TREESEED_TREEDB_WORKSPACE_ID,
    contentPathMap: {
      page: 'src/content/pages/**'
    },
    repositoryHints: [
      { purpose: 'project_content', name: 'project-content' }
    ]
  }
});
```

Supported environment variables:

```text
TREESEED_TREEDB_BASE_URL
TREESEED_TREEDB_TOKEN
TREESEED_TREEDB_REF
TREESEED_TREEDB_WORKSPACE_ID
```

There is intentionally no repository-id environment variable. Content path maps
and repository hints narrow discovery when the TreeDB portfolio contains
multiple candidates.

## No-Clone And Model Registry Boundary

No-clone content behavior requires enough local TreeSeed metadata to map model
names to content paths. TreeSeed model definitions, aliases, slugs, frontmatter
normalization, filters, and product behavior remain in `packages/trsd-sdk`.
TreeDB receives generic repository, ref, path, graph, search, context, and
workspace requests.

## Local-vs-TreeDB Parity Expectations

TreeDB content reads should preserve TreeSeed model behavior after local
frontmatter parsing and model normalization. Writes require either a workspace
or unambiguous repository discovery. If multiple repositories match a write
target, TreeSeed must fail clearly and require stronger repository hints or a
workspace.

`pick()` remains local-lease backed until TreeDB exposes a generic SDK lease
capability for TreeSeed content claims.

## Contract Strategy

TreeDB wire behavior remains defined by `docs/api/openapi.yaml`. Generic SDK
architecture remains defined by `packages/sdk-spec`. Drift checks verify route
inventory, OpenAPI schema coverage, generated-like operation metadata, request
construction, SDK manifests, and conformance scenario catalog loading.

TreeDB APIs stay generic: repo, ref, path, workspace, graph, search, context,
capability, and federation. Product model names are mapping metadata in
`packages/trsd-sdk`; they are not TreeDB server concepts.
