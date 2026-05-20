#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="$ROOT_DIR/evidence"

mkdir -p "$EVIDENCE_DIR"

cd "$ROOT_DIR"

echo "[1/6] Starting demo app"
scripts/start_demo.sh | tee "$EVIDENCE_DIR/start-demo.txt"

echo "[2/6] Running unit tests"
docker cp tests/. sre-taskmanager-app:/app/tests
docker cp pytest.ini sre-taskmanager-app:/app/pytest.ini
docker compose exec -T app sh -lc 'pip install -q -r requirements-dev.txt && pytest /app/tests -q' \
  | tee "$EVIDENCE_DIR/test-output.txt"

echo "[3/6] Running smoke test"
scripts/smoke_test.sh http://127.0.0.1:8000 | tee "$EVIDENCE_DIR/smoke-test.txt"

echo "[4/6] Running built-in load test"
python3 scripts/load_test.py \
  --url http://127.0.0.1:8000 \
  --requests 300 \
  --concurrency 30 | tee "$EVIDENCE_DIR/load-test-summary.json"

echo "[5/6] Exporting compose config"
docker compose config > "$EVIDENCE_DIR/docker-compose-config.txt"

echo "[6/6] Capturing Kubernetes evidence when available"
if command -v kubectl >/dev/null 2>&1 && kubectl get namespace task-api >/dev/null 2>&1; then
  scripts/collect_k8s_evidence.sh "$EVIDENCE_DIR"
else
  echo "Skipping Kubernetes evidence: local cluster not available" \
    | tee "$EVIDENCE_DIR/k8s-status.txt"
fi

scripts/stop_demo.sh > "$EVIDENCE_DIR/stop-demo.txt" || true

echo "Evidence collected in $EVIDENCE_DIR"
