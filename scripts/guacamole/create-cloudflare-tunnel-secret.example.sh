#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-cloudflare-tunnel}"
SECRET_NAME="${SECRET_NAME:-cloudflare-tunnel-token}"
TOKEN_FILE="${TOKEN_FILE:-}"
TOKEN="${TUNNEL_TOKEN:-}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }

if [ -z "$TOKEN" ] && [ -n "$TOKEN_FILE" ] && [ -f "$TOKEN_FILE" ]; then
  TOKEN="$(cat "$TOKEN_FILE")"
fi

if [ -z "$TOKEN" ]; then
  echo "Enter Cloudflare tunnel token (hidden):"
  read -r -s TOKEN
  echo
fi

if [ -z "$TOKEN" ]; then
  echo "[ERROR] no tunnel token provided"
  exit 1
fi

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE" >/dev/null

if kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" >/dev/null 2>&1; then
  kubectl -n "$NAMESPACE" delete secret "$SECRET_NAME" >/dev/null
fi

kubectl -n "$NAMESPACE" create secret generic "$SECRET_NAME" \
  --from-literal=TUNNEL_TOKEN="$TOKEN" >/dev/null

echo "[OK] namespace ready: $NAMESPACE"
echo "[OK] secret ready: $NAMESPACE/$SECRET_NAME"
echo "[OK] token was not printed"
