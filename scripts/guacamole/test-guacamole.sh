#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-guacamole}"
RELEASE="${RELEASE:-guacamole}"
REPO_NAME="${REPO_NAME:-helmforge}"
CHART="${CHART:-${REPO_NAME}/guacamole}"
VALUES_FILE="${VALUES_FILE:-$ROOT_DIR/helm/guacamole/values-local.yaml}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

if [ ! -f "$VALUES_FILE" ]; then
  echo "[ERROR] values file not found: $VALUES_FILE"
  exit 1
fi

echo "[1/4] Helm render check"
helm template "$RELEASE" "$CHART" -n "$NAMESPACE" -f "$VALUES_FILE" >/tmp/${RELEASE}-guacamole-test-render.yaml

echo "[2/4] Cluster objects"
kubectl -n "$NAMESPACE" get deploy,sts,svc,pvc 2>/dev/null || true

echo "[3/4] Release status"
helm -n "$NAMESPACE" status "$RELEASE" || true

echo "[4/4] Port-forward test command"
echo "kubectl -n $NAMESPACE port-forward svc/$RELEASE 8080:80"
echo "Then open http://127.0.0.1:8080/"

