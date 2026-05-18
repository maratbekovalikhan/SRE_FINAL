#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="$ROOT_DIR/evidence"

mkdir -p "$EVIDENCE_DIR"

cd "$ROOT_DIR"

echo "[1/5] Running unit tests"
make test | tee "$EVIDENCE_DIR/test-output.txt"

echo "[2/5] Starting demo app"
scripts/start_demo.sh | tee "$EVIDENCE_DIR/start-demo.txt"

echo "[3/5] Running smoke test"
scripts/smoke_test.sh http://127.0.0.1:8000 | tee "$EVIDENCE_DIR/smoke-test.txt"

echo "[4/5] Running built-in load test"
app/.venv/bin/python scripts/load_test.py \
  --url http://127.0.0.1:8000 \
  --requests 300 \
  --concurrency 30 | tee "$EVIDENCE_DIR/load-test-summary.json"

echo "[5/5] Exporting compose config"
docker compose config > "$EVIDENCE_DIR/docker-compose-config.txt"

scripts/stop_demo.sh > "$EVIDENCE_DIR/stop-demo.txt" || true

echo "Evidence collected in $EVIDENCE_DIR"
