#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-cloudflare}"
RELEASE="${RELEASE:-guacamole-tunnel}"
CHART="${CHART:-helmforge/cloudflared}"
VALUES_FILE="${VALUES_FILE:-$ROOT_DIR/helm/cloudflare-tunnel/values-guacamole.yaml}"
SECRET_NAME="${SECRET_NAME:-cloudflared-guacamole-token}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

if [ ! -f "$VALUES_FILE" ]; then
  echo "[ERROR] values file missing: $VALUES_FILE"
  exit 1
fi

helm repo add cloudflare https://cloudflare.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE" >/dev/null

if ! kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" >/dev/null 2>&1; then
  echo "[ERROR] secret not found: $NAMESPACE/$SECRET_NAME"
  echo "[ERROR] create it first with: kubectl -n $NAMESPACE create secret generic $SECRET_NAME --from-literal=token='<CLOUDFLARE_TUNNEL_TOKEN>'"
  exit 1
fi

echo "[INFO] Installing Cloudflare Tunnel"
echo "[INFO] Release: $RELEASE"
echo "[INFO] Namespace: $NAMESPACE"
echo "[INFO] Chart: $CHART"
echo "[INFO] Values: $VALUES_FILE"

helm upgrade --install "$RELEASE" "$CHART" \
  -n "$NAMESPACE" \
  -f "$VALUES_FILE" \
  --wait \
  --atomic
