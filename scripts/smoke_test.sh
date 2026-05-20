#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8000}"

echo "Checking ${BASE_URL}/health"
curl -fsS "${BASE_URL}/health"
echo

echo "Checking ${BASE_URL}/ready"
curl -fsS "${BASE_URL}/ready"
echo

echo "Creating a demo task"
TASK_ID=$(
  curl -fsS -X POST "${BASE_URL}/tasks" \
    -H "Content-Type: application/json" \
    -d '{"title":"Smoke test task","description":"Created by smoke test"}' \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])'
)
echo "task created: ${TASK_ID}"

echo "Checking ${BASE_URL}/tasks/${TASK_ID}"
curl -fsS "${BASE_URL}/tasks/${TASK_ID}" >/dev/null
echo "task fetch ok"

echo "Checking ${BASE_URL}/work"
curl -fsS "${BASE_URL}/work?delay=25&cpu_iterations=50000" >/dev/null
echo "work endpoint ok"

echo "Checking ${BASE_URL}/metrics"
curl -fsS "${BASE_URL}/metrics" | grep -q "task_operations_total"
echo "metrics ok"
