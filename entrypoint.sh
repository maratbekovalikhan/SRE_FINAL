#!/bin/sh
set -e

echo "Running database migrations..."
alembic upgrade head

echo "Ensuring application schema exists..."
python scripts/ensure_schema.py

echo "Starting application..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
