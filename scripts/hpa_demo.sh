#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="${EVIDENCE_DIR:-$ROOT_DIR/evidence}"
NAMESPACE="${NAMESPACE:-task-api}"
SERVICE_NAME="${SERVICE_NAME:-task-api-service}"
LOCAL_PORT="${LOCAL_PORT:-18080}"
LOAD_ROUNDS="${LOAD_ROUNDS:-6}"
LOAD_REQUESTS="${LOAD_REQUESTS:-300}"
LOAD_CONCURRENCY="${LOAD_CONCURRENCY:-40}"
LOAD_PATH="${LOAD_PATH:-/work?delay=40&cpu_iterations=500000}"
SAMPLE_COUNT="${SAMPLE_COUNT:-18}"
SAMPLE_INTERVAL="${SAMPLE_INTERVAL:-5}"

mkdir -p "$EVIDENCE_DIR"

cleanup() {
  if [[ -n "${PORT_FORWARD_PID:-}" ]] && kill -0 "$PORT_FORWARD_PID" >/dev/null 2>&1; then
    kill "$PORT_FORWARD_PID" >/dev/null 2>&1 || true
    wait "$PORT_FORWARD_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT

kubectl port-forward -n "$NAMESPACE" "service/$SERVICE_NAME" "$LOCAL_PORT:80" \
  > "$EVIDENCE_DIR/hpa-port-forward.log" 2>&1 &
PORT_FORWARD_PID=$!

for _ in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:$LOCAL_PORT/health" >/dev/null; then
    break
  fi
  sleep 1
done

curl -sf "http://127.0.0.1:$LOCAL_PORT/health" >/dev/null

kubectl get hpa -n "$NAMESPACE" > "$EVIDENCE_DIR/hpa-before.txt"

(
  for _ in $(seq 1 "$SAMPLE_COUNT"); do
    printf '=== %s ===\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    kubectl get hpa task-api-hpa -n "$NAMESPACE"
    echo
    kubectl top pods -n "$NAMESPACE" || true
    echo
    sleep "$SAMPLE_INTERVAL"
  done
) > "$EVIDENCE_DIR/hpa-scaling.txt" &
SAMPLER_PID=$!

: > "$EVIDENCE_DIR/hpa-load-rounds.txt"
for round in $(seq 1 "$LOAD_ROUNDS"); do
  printf 'Round %s\n' "$round" | tee -a "$EVIDENCE_DIR/hpa-load-rounds.txt"
  python3 "$ROOT_DIR/scripts/load_test.py" \
    --url "http://127.0.0.1:$LOCAL_PORT" \
    --path "$LOAD_PATH" \
    --requests "$LOAD_REQUESTS" \
    --concurrency "$LOAD_CONCURRENCY" \
    --timeout 60 | tee -a "$EVIDENCE_DIR/hpa-load-rounds.txt"
  echo | tee -a "$EVIDENCE_DIR/hpa-load-rounds.txt"
done

wait "$SAMPLER_PID"

kubectl get hpa -n "$NAMESPACE" > "$EVIDENCE_DIR/hpa-after.txt"
kubectl top pods -n "$NAMESPACE" > "$EVIDENCE_DIR/k8s-top-pods.txt" 2>&1 || true

echo "HPA demo evidence saved in $EVIDENCE_DIR"
