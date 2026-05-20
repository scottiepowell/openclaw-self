#!/usr/bin/env bash
set -euo pipefail

CONFIRM_DEPLOY_CLOUDFLARE_TUNNEL="${CONFIRM_DEPLOY_CLOUDFLARE_TUNNEL:-no}"
HELM_CHART="${HELM_CHART:-cloudflare-tunnel/cloudflare-tunnel}"
VALUES_FILE="${VALUES_FILE:-$PWD/helm/cloudflare-tunnel/values-guacamole.example.yaml}"
NAMESPACE="${NAMESPACE:-cloudflare-tunnel}"
RELEASE="${RELEASE:-openclaw-guacamole-tunnel}"
SECRET_NAME="${SECRET_NAME:-cloudflare-tunnel-token}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

if [ ! -f "$VALUES_FILE" ]; then
  echo "[ERROR] example values file missing: $VALUES_FILE"
  exit 1
fi

if ! kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" >/dev/null 2>&1; then
  echo "[ERROR] secret not found: $NAMESPACE/$SECRET_NAME"
  exit 1
fi

echo "[INFO] Example-only deploy wrapper"
echo "[INFO] Chart: $HELM_CHART"
echo "[INFO] Values: $VALUES_FILE"
echo "[INFO] Command preview:"
echo "helm upgrade --install $RELEASE $HELM_CHART -n $NAMESPACE -f $VALUES_FILE --wait --atomic"

if [ "$CONFIRM_DEPLOY_CLOUDFLARE_TUNNEL" != "yes" ]; then
  echo "[INFO] Dry-run only. Set CONFIRM_DEPLOY_CLOUDFLARE_TUNNEL=yes to allow a real deploy in a future task."
  exit 0
fi

echo "[ERROR] Real deploy is intentionally blocked in this example script"
exit 1
