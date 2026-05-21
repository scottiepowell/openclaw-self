#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-cloudflare}"
RELEASE="${RELEASE:-guacamole-tunnel}"
SECRET_NAME="${SECRET_NAME:-cloudflared-guacamole-token}"
VALUES_FILE="${VALUES_FILE:-$ROOT_DIR/helm/cloudflare-tunnel/values-guacamole.yaml}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

echo "[1/5] Helm release"
helm -n "$NAMESPACE" status "$RELEASE" || true

echo "[2/5] Namespace and secret"
kubectl get namespace "$NAMESPACE" || true
kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" || true

echo "[3/5] Pods and deployment"
kubectl -n "$NAMESPACE" get pods,deploy,svc -o wide || true

echo "[4/5] Logs"
kubectl -n "$NAMESPACE" logs -l app.kubernetes.io/name=cloudflared --tail=120 || true

echo "[5/5] Render check"
helm repo add helmforge https://repo.helmforge.dev >/dev/null 2>&1 || true
helm repo update >/dev/null
helm template "$RELEASE" helmforge/cloudflared -n "$NAMESPACE" -f "$VALUES_FILE" >/tmp/${RELEASE}-rendered.yaml
grep -nE 'cloudflared-guacamole-token|cloudflared|worker-01' /tmp/${RELEASE}-rendered.yaml || true
