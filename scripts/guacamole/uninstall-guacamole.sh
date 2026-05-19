#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-guacamole}"
RELEASE="${RELEASE:-guacamole}"
PURGE_DATA="${PURGE_DATA:-false}"
CONFIRM="${CONFIRM:-NO}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

if [ "$CONFIRM" != "YES" ]; then
  echo "[ERROR] Set CONFIRM=YES to uninstall $RELEASE from $NAMESPACE"
  exit 1
fi

helm -n "$NAMESPACE" uninstall "$RELEASE" || true

if [ "$PURGE_DATA" = "true" ]; then
  echo "[WARN] PURGE_DATA=true; deleting PVCs in $NAMESPACE for app $RELEASE"
  kubectl -n "$NAMESPACE" delete pvc -l app.kubernetes.io/instance="$RELEASE" --ignore-not-found
fi

echo "[OK] Uninstall complete"

