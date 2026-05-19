#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-guacamole}"
RELEASE="${RELEASE:-guacamole}"
REPO_NAME="${REPO_NAME:-helmforge}"
REPO_URL="${REPO_URL:-https://repo.helmforge.dev}"
CHART="${CHART:-${REPO_NAME}/guacamole}"
VALUES_FILE="${VALUES_FILE:-$ROOT_DIR/helm/guacamole/values-local.yaml}"
DB_SECRET="${DB_SECRET:-guacamole-postgresql-auth}"
DB_PASSWORD="${DB_PASSWORD:-}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

if [ ! -f "$VALUES_FILE" ]; then
  echo "[ERROR] values file not found: $VALUES_FILE"
  exit 1
fi

if [ -z "$DB_PASSWORD" ]; then
  if command -v openssl >/dev/null 2>&1; then
    DB_PASSWORD="$(openssl rand -base64 24 | tr -d '\n')"
  else
    DB_PASSWORD="$(date +%s | sha256sum | cut -c1-32)"
  fi
fi

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

helm repo add "$REPO_NAME" "$REPO_URL" >/dev/null 2>&1 || true
helm repo update >/dev/null

if ! kubectl -n "$NAMESPACE" get secret "$DB_SECRET" >/dev/null 2>&1; then
  kubectl -n "$NAMESPACE" create secret generic "$DB_SECRET" \
    --from-literal=postgres-password="$DB_PASSWORD" \
    --from-literal=user-password="$DB_PASSWORD" \
    --from-literal=replication-password="$DB_PASSWORD"
fi

echo "[1/3] Helm template validation"
helm template "$RELEASE" "$CHART" -n "$NAMESPACE" -f "$VALUES_FILE" >/tmp/${RELEASE}-guacamole-rendered.yaml

echo "[2/3] Installing or upgrading $RELEASE in namespace $NAMESPACE"
helm upgrade --install "$RELEASE" "$CHART" \
  -n "$NAMESPACE" \
  --create-namespace \
  --wait \
  --timeout 10m \
  --atomic \
  -f "$VALUES_FILE"

echo "[3/3] Done"
echo "Port-forward test: kubectl -n $NAMESPACE port-forward svc/$RELEASE 8080:80"

