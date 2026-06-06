# TreeDB Elixir SDK

`tree_db_sdk` is the generic Elixir SDK for TreeDB. The public namespace is
`TreeDbSdk`. It implements the shared `packages/sdk-spec` architecture, follows
`docs/api/openapi.yaml`, and does not encode TreeSeed product semantics.
`packages/trsd-sdk` is a downstream TreeSeed consumer/reference only.

The current `sdk-manifest.yaml` intentionally reports modules, capabilities, and
test roots as `partial` because live executable conformance dispatch is deferred
to a later phase.

## Install

This package is private to the current repository baseline:

```bash
cd packages/elixir-sdk
mix deps.get
```

## Configure Client

```elixir
client =
  TreeDbSdk.Client.new(
    base_url: "http://localhost:4000",
    token: System.get_env("TREEDB_TOKEN")
  )
```

The client also accepts an auth provider, injected transport, default headers,
and timeout settings.

## Authenticate

Bearer authentication uses the `Authorization: Bearer <token>` header. Tokens
may come from `:token` or an auth provider. The SDK must not place production
identity in request JSON and must not log bearer tokens.

## Basic Health Call

```elixir
{:ok, health} = TreeDbSdk.health(client)
{:ok, version} = TreeDbSdk.version(client)
```

## Repository Query

Repository-scoped query helpers live under `TreeDbSdk.Query`:

```elixir
{:ok, results} =
  TreeDbSdk.Query.search_files(client, "repo_demo", %{
    query: "release provenance",
    paths: ["docs/**"]
  })

{:ok, file} =
  TreeDbSdk.Query.read_file(client, "repo_demo", %{
    ref: "refs/heads/main",
    path: "docs/index.md"
  })
```

## Workspace File Lifecycle

Workspace-scoped file helpers live under `TreeDbSdk.Workspaces` and
`TreeDbSdk.Files`:

```elixir
{:ok, workspace} = TreeDbSdk.Workspaces.create(client, "repo_demo", %{ref: "refs/heads/main"})

{:ok, _} = TreeDbSdk.Files.write(client, "workspace_123", %{path: "docs/new.md", content: "# New"})
{:ok, _} = TreeDbSdk.Files.patch(client, "workspace_123", %{path: "docs/new.md", patch: "..."})
{:ok, _} = TreeDbSdk.Files.commit(client, "workspace_123", %{message: "Update docs"})
{:ok, _} = TreeDbSdk.Workspaces.close(client, "workspace_123")
```

## Blob Upload And Download

Binary helpers accept binaries and iodata and do not treat JSON strings as
upload bodies.

```elixir
{:ok, _} = TreeDbSdk.Blobs.upload(client, "workspace_123", <<1, 2, 3>>)
{:ok, blob} = TreeDbSdk.Blobs.download(client, "workspace_123", %{path: "asset.bin"})
```

Multipart helpers expose create, part upload, complete, and abort.

## Graph And Context Query

```elixir
{:ok, _} = TreeDbSdk.Graph.refresh(client, "repo_demo")
{:ok, graph} = TreeDbSdk.Graph.query(client, "repo_demo", %{query: "MATCH ..."})
{:ok, context} = TreeDbSdk.Context.build(client, "repo_demo", %{query: "ctx docs"})
{:ok, parsed} = TreeDbSdk.Context.parse(client, "repo_demo", %{source: "ctx docs"})
```

## Federated Query

Federation helpers use portfolio/global TreeDB routes rather than a single
configured repository:

```elixir
{:ok, plan} = TreeDbSdk.Federation.plan(client, %{query: "release provenance"})
{:ok, results} = TreeDbSdk.Federation.search(client, %{query: "release provenance"})
```

## Error Handling

Calls return `{:ok, value}` or `{:error, %TreeDbSdk.Error{}}`. The error keeps
`status`, `code`, `message`, `details`, and `payload`. Network failures use
`status: 0` and `code: "network_error"`.

## Pagination

`TreeDbSdk.Pagination` preserves opaque server-owned cursor values and accepts
server camelCase keys such as `nextCursor` and `hasMore`.

## Binary And Multipart

Binary helpers accept Elixir binaries and iodata. Multipart upload maps use
`upload_id` and `completed_parts` while preserving TreeDB part numbers.

## Conformance

The package loads Phase 7 black-box scenario records and reports
`:not_configured` until live scenario dispatch is implemented. It must not fake
conformance success.

```bash
mix test test/conformance
```

## Integration

Integration tests call a live TreeDB server only when `TREEDB_BASE_URL` is set.
Without that environment variable, they pass cleanly by reporting
not-configured behavior.

```bash
mix test test/integration
```

## Development Commands

```bash
mix deps.get
mix run scripts/check_treedb_generated_types.exs
mix format --check-formatted
mix test test/conformance
mix test test/integration
mix test
```
