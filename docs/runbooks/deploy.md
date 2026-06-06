# TreeDB Deploy Runbook

TreeDB publishes two Docker Hub images:

- `treeseed/treedb`: the stripped production API service image.
- `treeseed/treedb-profiler`: the Debian-based profiling and acceptance
  utility image.

- `treeseed/treedb:latest` and `treeseed/treedb-profiler:latest` are published
  from verified `main` branch updates.
- `treeseed/treedb:<semver>` and `treeseed/treedb-profiler:<semver>` are
  published from verified semantic-version git tags, for example `0.1.0` or
  `1.2.3-alpha.1`.
- Published tags are multi-architecture images for `linux/amd64` and
  `linux/arm64`.
- Release images are built on native GitHub-hosted AMD64 and ARM64 runners,
  verified and profiled independently on each architecture, then assembled into
  one Docker manifest.
- Architecture-specific tags are published alongside the manifest using the
  final tag as the prefix, for example `latest-amd64`, `latest-arm64`,
  `0.1.0-amd64`, and `0.1.0-arm64`.
- Versioned Docker tags come directly from git tags. There is no separate
  version file. Tags with build metadata such as `1.2.3+build.5` are not used
  because Docker tags cannot preserve `+` while keeping the image tag identical
  to the git tag.

1. Configure required runtime variables:
   - `TREEDB_DATA_DIR`
   - `TREEDB_AUTH_MODE`
   - connected auth verifier variables when using connected auth
   - storage and exec backend variables appropriate for the environment
2. Start the service.
3. Probe liveness:

```bash
curl "$TREEDB_URL/api/v1/health"
```

4. Gate traffic on readiness:

```bash
curl "$TREEDB_URL/api/v1/ready"
```

5. Configure metrics scraping:

```text
GET /metrics
```

6. Confirm production logs are JSON and do not contain raw secrets or local
   filesystem paths.

The published `treeseed/treedb` service image uses
`gcr.io/distroless/cc-debian12:nonroot`. It intentionally has no package
manager, shell entrypoint, `git`, `curl`, profiler binary, profiler source, or
operational test tooling. Native repository operations and local/file push paths
do not require the shell `git` binary. If authenticated external Git transport
is enabled, provide `git` through a derived image or a controlled worker
environment with the documented credential-provider settings.

The service image runs as UID/GID `65532:65532` and does not perform runtime
`chown`. Docker named volumes generally inherit `/var/lib/treedb` ownership from
the image on first initialization. Kubernetes and other mounted-volume
deployments should configure:

```yaml
securityContext:
  runAsUser: 65532
  runAsGroup: 65532
  fsGroup: 65532
```

The `treeseed/treedb-profiler` image is Debian-based and includes the
`treedb_profiler` executable plus profiler scenario, fixture, reliability
budget, and OpenAPI files. Use it for profile and acceptance workloads rather
than as the production API service runtime.
