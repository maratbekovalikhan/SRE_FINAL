#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$ROOT_DIR/.tmp/app.pid"
LOG_FILE="$ROOT_DIR/.tmp/app.log"

mkdir -p "$ROOT_DIR/.tmp"

if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "App is already running on PID $(cat "$PID_FILE")"
  echo "Open http://127.0.0.1:8000"
  exit 0
fi

cd "$ROOT_DIR"
TMPDIR="$ROOT_DIR/.tmp" PORT=8000 app/.venv/bin/python app/app.py >"$LOG_FILE" 2>&1 &
APP_PID=$!
echo "$APP_PID" >"$PID_FILE"

for _ in {1..20}; do
  if curl -fsS http://127.0.0.1:8000/health >/dev/null 2>&1; then
    echo "App started successfully on http://127.0.0.1:8000"
    echo "PID: $APP_PID"
    echo "Logs: $LOG_FILE"
    exit 0
  fi
  sleep 1
done

echo "App did not become healthy in time. Recent logs:"
tail -n 20 "$LOG_FILE" || true
exit 1
