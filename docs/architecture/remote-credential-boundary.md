# Remote Credential Boundary

TreeDB remote Git APIs never accept raw credentials in request bodies or remote
URLs. Operators configure a credential provider and callers pass only a logical
`credentialId`.

Supported providers:

- `TREEDB_REMOTE_CREDENTIAL_PROVIDER=none`
- `TREEDB_REMOTE_CREDENTIAL_PROVIDER=env_file`
- `TREEDB_REMOTE_CREDENTIAL_PROVIDER=external_command`

Authenticated HTTPS and SSH transports use the constrained external transport
path only when `TREEDB_GIT_EXTERNAL_TRANSPORT_ENABLED=true`. SSH also requires
`TREEDB_GIT_SSH_ENABLED=true` and `TREEDB_GIT_SSH_KNOWN_HOSTS`.

Public responses and audit payloads include sanitized remote URL metadata,
backend, refspec count, dry-run flag, and status. They do not include
credential material, askpass paths, private key paths, stdout/stderr, hidden
refs, or local filesystem paths.
