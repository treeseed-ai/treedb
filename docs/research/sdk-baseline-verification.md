# SDK Baseline Verification

## Summary

Baseline verification was run against `packages/ts-sdk` before TreeDB integration changes. The SDK is currently a standalone npm package named `@treeseed/sdk` at version `0.10.22`.

## Initial Command Results

| Command | Result | Notes |
| --- | --- | --- |
| `npm ci` | pass | Created dependencies; reported 18 audit vulnerabilities, including 13 moderate and 5 high. |
| `npm run build` | pass | Build completed through `npm run build:dist`. |
| `npm run typecheck --if-present` | pass/no-op | No `typecheck` script exists in `packages/ts-sdk/package.json`. |
| `npm test` | fail | Missing fixture submodule plus package graph self-reference assertion. |

## Initial Failure Details

The first `npm test` run failed because `.fixtures/treeseed-fixtures` was not initialized. The SDK expects the fixture submodule at commit `33bac888a055d6e8b649b5ba0a1eb3c2bbd80b71`.

The missing fixture caused these suites to fail during import:

- `test/utils/operations.test.ts`
- `test/utils/remote.test.ts`
- `test/utils/sdk.test.ts`

`test/utils/package-graph.test.ts` also failed because it found deprecated SDK path text inside the test file itself:

```text
@treeseed/sdk/platform/tenant/config
```

Observed Vitest summary:

```text
Test Files  4 failed | 61 passed | 1 skipped (66)
Tests       1 failed | 441 passed | 7 skipped (449)
```

## Final MVP Rerun

After writing the MVP docs, the requested documentation-safe verification commands were rerun.

| Command | Result | Notes |
| --- | --- | --- |
| `git status --short` | pass | Root worktree shows only new `docs/` files. |
| `git -C packages/ts-sdk status --short` | pass | SDK checkout is clean. |
| `npm run build` | pass | Build completed through `npm run build:dist`. |
| `npm test` | historical issue | Only the package graph assertion tripped on this historical rerun; this was corrected later. |

Final rerun Vitest summary:

```text
Test Files  1 failed | 64 passed | 1 skipped (66)
Tests       1 failed | 479 passed | 7 skipped (487)
```

The final failing assertion was unchanged:

```text
test/utils/package-graph.test.ts contains deprecated sdk path @treeseed/sdk/platform/tenant/config
```

At the time of the final rerun, the fixture submodule was present at the expected commit:

```text
33bac888a055d6e8b649b5ba0a1eb3c2bbd80b71 .fixtures/treeseed-fixtures (0.5.0-2-g33bac88)
```

## MVP Cleanup Update

The package graph self-reference was corrected during MVP cleanup by excluding the actual `packages/ts-sdk/test/utils/package-graph.test.ts` path from its deprecated-alias scan. The focused test now passes:

```text
npx vitest run --config ./vitest.config.ts test/utils/package-graph.test.ts
Test Files  1 passed (1)
Tests       9 passed (9)
```

The full SDK suite was also rerun after MVP targeted tests. It completed with only that same package graph assertion before the cleanup:

```text
Test Files  1 failed | 70 passed | 1 skipped (72)
Tests       1 failed | 499 passed | 7 skipped (507)
```

## MVP Baseline Update

The full SDK suite now passes after the package graph cleanup and MVP SDK contract additions:

```text
Test Files  72 passed | 2 skipped (74)
Tests       504 passed | 8 skipped (512)
```

The remaining baseline note is that `packages/ts-sdk` still has no explicit `typecheck` script; `npm run build` remains the package build/type-emission gate.

## Suggested Next Verification

For SDK-facing TreeDB changes, run:

```bash
cd packages/ts-sdk
npm run build
npx vitest run --config ./vitest.config.ts test/utils/package-graph.test.ts test/utils/treedb-e2e-contract.test.ts
npm test
```
