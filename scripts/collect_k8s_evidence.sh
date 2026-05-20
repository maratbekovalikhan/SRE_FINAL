#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="${1:-$ROOT_DIR/evidence}"
NAMESPACE="${NAMESPACE:-task-api}"

mkdir -p "$EVIDENCE_DIR"

kubectl get deploy,pods,svc -n "$NAMESPACE" > "$EVIDENCE_DIR/k8s-status.txt"
kubectl get hpa -n "$NAMESPACE" > "$EVIDENCE_DIR/hpa-status.txt"
kubectl top pods -n "$NAMESPACE" > "$EVIDENCE_DIR/k8s-top-pods.txt" 2>&1 || true

if kubectl get namespace monitoring >/dev/null 2>&1; then
  kubectl get pods -n monitoring > "$EVIDENCE_DIR/monitoring-pods.txt"
fi

echo "Saved Kubernetes evidence in $EVIDENCE_DIR"
