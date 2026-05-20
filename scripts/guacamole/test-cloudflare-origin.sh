#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-guacamole}"
POD_NAMESPACE="${POD_NAMESPACE:-guacamole}"
POD_NODE="${POD_NODE:-worker-01}"
IMAGE="${IMAGE:-curlimages/curl:8.10.1}"
URL="${URL:-http://guacamole-guacamole.guacamole.svc.cluster.local:80/}"
POD_NAME="${POD_NAME:-cloudflare-origin-check}"
SERVICE_IP="${SERVICE_IP:-$(kubectl -n "$NAMESPACE" get svc guacamole-guacamole -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }

cleanup() {
  kubectl -n "$POD_NAMESPACE" delete pod "$POD_NAME" --ignore-not-found >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "[1/3] Launching temporary curl pod in namespace $POD_NAMESPACE"
kubectl -n "$POD_NAMESPACE" run "$POD_NAME" \
  --restart=Never \
  --rm -i \
  --image="$IMAGE" \
  --env="URL=$URL" \
  --env="SERVICE_IP=$SERVICE_IP" \
  --overrides="{\"spec\":{\"nodeSelector\":{\"kubernetes.io/hostname\":\"$POD_NODE\"}}}" \
  --command -- sh -lc '
    set -eu
    if curl -I -sS --max-time 10 "$URL"; then
      exit 0
    fi
    if [ -n "$SERVICE_IP" ]; then
      echo "[WARN] DNS failed; trying ClusterIP http://$SERVICE_IP:80/"
      curl -I -sS --max-time 10 "http://$SERVICE_IP:80/"
      exit 0
    fi
    exit 1
  '

echo "[2/3] Origin check completed"
echo "[3/3] Temporary pod cleaned up"
