#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8000}"

echo "Checking ${BASE_URL}/health"
curl -fsS "${BASE_URL}/health"
echo

echo "Checking ${BASE_URL}/products"
curl -fsS "${BASE_URL}/products" >/dev/null
echo "products ok"

echo "Checking ${BASE_URL}/metrics"
curl -fsS "${BASE_URL}/metrics" | grep -q "http_requests_total"
echo "metrics ok"
