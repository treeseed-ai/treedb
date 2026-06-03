#!/usr/bin/env bash
set -euo pipefail

./scripts/test-treedb-fast.sh
./scripts/mvp-smoke.sh
