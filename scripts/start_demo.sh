#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Starting full demo stack with Docker Compose..."
docker compose up --build -d

for _ in {1..60}; do
  if curl -fsS http://127.0.0.1:8000/health >/dev/null 2>&1 \
    && curl -fsS http://127.0.0.1:8000/ready >/dev/null 2>&1 \
    && curl -fsS http://127.0.0.1:9090/-/healthy >/dev/null 2>&1 \
    && curl -fsS http://127.0.0.1:3000/api/health >/dev/null 2>&1; then
    echo "Demo stack is ready."
    echo "App:          http://127.0.0.1:8000/docs"
    echo "Prometheus:   http://127.0.0.1:9090"
    echo "Grafana:      http://127.0.0.1:3000  (admin/admin)"
    echo "Alertmanager: http://127.0.0.1:9093"
    exit 0
  fi
  sleep 2
done

echo "Demo stack did not become ready in time. Recent container status:"
docker compose ps
exit 1
