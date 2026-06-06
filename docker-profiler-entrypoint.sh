#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == -* || "$#" -eq 0 ]]; then
  umask 000

  args=(
    --base-url "${TREEDB_PROFILE_BASE_URL:-http://treedb-api:4000}"
    --auth-mode dev
    --load-mode "${TREEDB_PROFILE_LOAD_MODE:-portfolio}"
    --fixture "${TREEDB_PROFILE_FIXTURE:-small-docs}"
    --size "${TREEDB_PROFILE_SIZE:-small}"
    --scenario "${TREEDB_PROFILE_SCENARIO:-all}"
    --concurrency "${TREEDB_PROFILE_CONCURRENCY:-100}"
    --timeout-ms "${TREEDB_PROFILE_TIMEOUT_MS:-120000}"
    --fixture-root "${TREEDB_PROFILE_FIXTURE_ROOT:-/var/lib/treedb/profiler}"
    --repo-prefix "${TREEDB_PROFILE_REPO_PREFIX:-profile-}"
    --portfolio-repo-prefix "${TREEDB_PROFILE_REPO_PREFIX:-profile-}"
    --portfolio-initial-repos "${TREEDB_PROFILE_PORTFOLIO_INITIAL_REPOS:-1}"
    --portfolio-max-repos "${TREEDB_PROFILE_PORTFOLIO_MAX_REPOS:-1000}"
    --portfolio-growth-target "${TREEDB_PROFILE_PORTFOLIO_GROWTH_TARGET:-steady}"
    --portfolio-min-repo-age-before-delete "${TREEDB_PROFILE_PORTFOLIO_MIN_REPO_AGE_BEFORE_DELETE:-30m}"
    --report-format "${TREEDB_PROFILE_REPORT_FORMAT:-both}"
    --markdown-output "${TREEDB_PROFILE_MARKDOWN_OUTPUT:-target/profiles/compose-profile.md}"
    --include-admin "${TREEDB_PROFILE_INCLUDE_ADMIN:-true}"
    --include-destructive "${TREEDB_PROFILE_INCLUDE_DESTRUCTIVE:-true}"
    --include-exec "${TREEDB_PROFILE_INCLUDE_EXEC:-true}"
    --include-federation "${TREEDB_PROFILE_INCLUDE_FEDERATION:-true}"
    --federation-mode "${TREEDB_PROFILE_FEDERATION_MODE:-single_node}"
    --federation-exercise-promotion "${TREEDB_PROFILE_FEDERATION_EXERCISE_PROMOTION:-false}"
    --federation-exercise-write-proxy "${TREEDB_PROFILE_FEDERATION_EXERCISE_WRITE_PROXY:-false}"
    --federation-exercise-connected-denials "${TREEDB_PROFILE_FEDERATION_EXERCISE_CONNECTED_DENIALS:-true}"
    --reliability-verifier "${TREEDB_PROFILE_RELIABILITY_VERIFIER:-true}"
    --openapi-response-validation "${TREEDB_PROFILE_OPENAPI_RESPONSE_VALIDATION:-true}"
    --model-reconciliation "${TREEDB_PROFILE_MODEL_RECONCILIATION:-true}"
    --reconciliation-interval "${TREEDB_PROFILE_RECONCILIATION_INTERVAL:-30s}"
    --reconciliation-sample-size "${TREEDB_PROFILE_RECONCILIATION_SAMPLE_SIZE:-100}"
    --operation-chains "${TREEDB_PROFILE_OPERATION_CHAINS:-true}"
    --negative-tests "${TREEDB_PROFILE_NEGATIVE_TESTS:-true}"
    --metamorphic-checks "${TREEDB_PROFILE_METAMORPHIC_CHECKS:-true}"
    --delayed-consistency-checks "${TREEDB_PROFILE_DELAYED_CONSISTENCY_CHECKS:-true}"
    --delayed-check-intervals "${TREEDB_PROFILE_DELAYED_CHECK_INTERVALS:-5s,30s}"
    --restart-durability-check "${TREEDB_PROFILE_RESTART_DURABILITY_CHECK:-false}"
    --fault-injection "${TREEDB_PROFILE_FAULT_INJECTION:-false}"
    --permission-matrix "${TREEDB_PROFILE_PERMISSION_MATRIX:-true}"
    --replay-log "${TREEDB_PROFILE_REPLAY_LOG:-target/profiles/compose-profile-replay.jsonl}"
    --failure-replay-log "${TREEDB_PROFILE_FAILURE_REPLAY_LOG:-target/profiles/compose-profile-failures.jsonl}"
    --output "${TREEDB_PROFILE_OUTPUT:-target/profiles/compose-profile.yaml}"
    --profile-purpose "${TREEDB_PROFILE_PROFILE_PURPOSE:-reliability}"
    --include-probe-samples "${TREEDB_PROFILE_INCLUDE_PROBE_SAMPLES:-false}"
    --include-total-throughput "${TREEDB_PROFILE_INCLUDE_TOTAL_THROUGHPUT:-true}"
    --performance-workload "${TREEDB_PROFILE_PERFORMANCE_WORKLOAD:-balanced}"
    --heavy-operation-rate "${TREEDB_PROFILE_HEAVY_OPERATION_RATE:-0.05}"
    --repo-growth-rate "${TREEDB_PROFILE_REPO_GROWTH_RATE:-0.02}"
    --snapshot-rate "${TREEDB_PROFILE_SNAPSHOT_RATE:-0.02}"
    --graph-refresh-rate "${TREEDB_PROFILE_GRAPH_REFRESH_RATE:-0.03}"
    --import-rate "${TREEDB_PROFILE_IMPORT_RATE:-0.01}"
  )

  optional_arg() {
    local value="$1"
    local flag="$2"
    if [[ -n "$value" ]]; then
      args+=("$flag" "$value")
    fi
  }

  optional_arg "${TREEDB_PROFILE_FEDERATION_NODE_A_URL:-}" --federation-node-a-url
  optional_arg "${TREEDB_PROFILE_FEDERATION_NODE_B_URL:-}" --federation-node-b-url
  optional_arg "${TREEDB_PROFILE_FEDERATION_NODE_C_URL:-}" --federation-node-c-url
  optional_arg "${TREEDB_PROFILE_TARGET_PRIMARY_RPS:-}" --target-primary-rps
  optional_arg "${TREEDB_PROFILE_PROBE_SAMPLING_RATE:-}" --probe-sampling-rate
  optional_arg "${TREEDB_PROFILE_VALIDATION_PROBE_MODE:-}" --validation-probe-mode
  optional_arg "${TREEDB_PROFILE_FAIL_BELOW_PRIMARY_RPS:-}" --fail-below-primary-rps
  optional_arg "${TREEDB_PROFILE_RELIABILITY_BUDGET:-}" --reliability-budget
  optional_arg "${TREEDB_PROFILE_ITERATIONS:-}" --iterations

  duration="${TREEDB_PROFILE_DURATION-10m}"
  if [[ -n "$duration" ]]; then
    args+=(
      --duration "$duration"
      --duration-is-controlling "${TREEDB_PROFILE_DURATION_IS_CONTROLLING:-true}"
      --minimum-measured-duration "${TREEDB_PROFILE_MINIMUM_MEASURED_DURATION:-10m}"
    )
  fi

  set +e
  /usr/local/bin/treedb_profiler "${args[@]}" "$@"
  status="$?"
  set -e

  chown -R "${TREEDB_PROFILE_HOST_UID:-1000}:${TREEDB_PROFILE_HOST_GID:-1000}" \
    /workspace/treedb/target/profiles 2>/dev/null || true

  exit "$status"
fi

exec "$@"
