#!/usr/bin/env bash
set -euo pipefail

./scripts/test-stage0-fast.sh
./scripts/mvp-smoke.sh
