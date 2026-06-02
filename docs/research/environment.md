# MVP Environment Research

## Repository Layout

The top-level TreeDB repository is only a plan plus a copied SDK at this capability. The root currently contains `PLAN`, `LICENSE`, `.gitignore`, and `packages/ts-sdk`; no root application skeleton is present yet.

No root `package.json`, `Cargo.toml`, `mix.exs`, `Dockerfile`, `compose.yaml`, or `docker-compose.yml` was found. MVP needs to introduce the root Elixir/Phoenix service, Rust crates, Dockerfile, and Compose manifests described in `PLAN`.

`packages/ts-sdk` is its own Git checkout/submodule-style directory and is the only runnable package found during MVP. It is the current compatibility target for TreeSeed market, core, and agent behavior.

## Tooling

Detected local host tools during the MVP audit:

| Tool | Version |
| --- | --- |
| Node | `v24.15.0` |
| npm | `11.12.1` |
| Git | `2.43.0` |
| Rust | `rustc 1.95.0 (59807616e 2026-04-14)` |
| Cargo | `cargo 1.95.0 (f2d3ce0bd 2026-03-21)` |
| Erlang/OTP | `27` |
| Elixir | `1.17.3` |

These host versions are useful for MVP research only. They must not become prerequisites for contributors. MVP should make Docker the canonical way to run the service and should containerize Elixir, Erlang/OTP, Rust, Node, Git, ripgrep, and native build tooling.

## Package Manager And Scripts

The root TreeDB repository has no package manager configuration yet.

`packages/ts-sdk` uses npm, evidenced by `packages/ts-sdk/package-lock.json`. Its package metadata is:

| Field | Value |
| --- | --- |
| Package name | `@treeseed/sdk` |
| Version | `0.10.22` |
| Module type | `module` |
| Node engine | `>=22` |
| Test framework | Vitest |
| Build target | `npm run build` -> `npm run build:dist` |
| Typecheck script | none |

SDK scripts recorded for compatibility:

| Script | Command |
| --- | --- |
| `setup` | `npm install` |
| `setup:ci` | `npm ci` |
| `build` | `npm run build:dist` |
| `build:dist` | `node ./scripts/run-ts.mjs ./scripts/build-dist.ts` |
| `test` | `npm run test:unit` |
| `test:unit` | `vitest run --config ./vitest.config.ts` |
| `test:unit:fast` | `vitest run --config ./vitest.fast.config.ts` |
| `lint` | `npm run fixtures:check && npm run build:dist` |
| `verify` | `node ./scripts/verify-driver.mjs` |
| `release:verify` | `node ./scripts/run-ts.mjs ./scripts/release-verify.ts` |

## Runtime Assumptions

Per `PLAN`, host contributors should ultimately need Docker only. The canonical runtime path should be `docker compose up treedb-api`, with the container owning language runtime and native dependency complexity.

Current direct host execution of npm commands in `packages/ts-sdk` is appropriate only for MVP audit and baseline capture. It should not define the long-term TreeDB developer experience.

## Open Environment Risks

1. No root project skeleton exists yet.
2. The SDK fixture submodule is not initialized.
3. The SDK has no `typecheck` script even though MVP suggested one.
4. Existing host Elixir and Rust versions must not become required; MVP should containerize them.
5. `packages/ts-sdk` is a separate Git checkout, so root-level automation must be careful not to assume a single worktree.
