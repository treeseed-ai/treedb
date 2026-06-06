#!/usr/bin/env bash
set -euo pipefail

require_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required security tool missing: $1" >&2
    exit 127
  }
}

require_tool cargo
require_tool cargo-audit
require_tool syft
require_tool trivy
require_tool docker

CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-/tmp/treedb-target}" cargo audit

mkdir -p target
syft dir:. -o spdx-json=target/treedb-sbom.spdx.json

docker build -t treedb-security-scan:local -f Dockerfile --target prod .
syft treedb-security-scan:local -o spdx-json=target/treedb-image-sbom.spdx.json
trivy image --exit-code 1 --ignore-unfixed --severity HIGH,CRITICAL treedb-security-scan:local

docker build -t treedb-profiler-security-scan:local -f Dockerfile.profiler --target profiler .
syft treedb-profiler-security-scan:local -o spdx-json=target/treedb-profiler-image-sbom.spdx.json
trivy image --exit-code 0 --ignore-unfixed --severity HIGH,CRITICAL treedb-profiler-security-scan:local
