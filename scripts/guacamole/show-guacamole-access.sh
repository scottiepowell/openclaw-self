#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-guacamole}"
RELEASE="${RELEASE:-guacamole}"
INTERNAL_SERVICE="${INTERNAL_SERVICE:-${RELEASE}-guacamole}"
LAN_SERVICE="${LAN_SERVICE:-${RELEASE}-guacamole-nodeport}"
PORT_FORWARD="${PORT_FORWARD:-kubectl -n ${NAMESPACE} port-forward svc/${INTERNAL_SERVICE} 8080:80}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

printf 'Helm status:\n'
helm -n "$NAMESPACE" status "$RELEASE" | sed -n '1,12p'

printf '\nServices:\n'
kubectl -n "$NAMESPACE" get svc "$INTERNAL_SERVICE" "$LAN_SERVICE" -o wide

node_port="$(kubectl -n "$NAMESPACE" get svc "$LAN_SERVICE" -o jsonpath='{.spec.ports[0].nodePort}')"

printf '\nWorker nodes:\n'
kubectl get nodes -o wide | awk 'NR==1 || $2=="Ready" {print}'

printf '\nSuggested LAN URL:\n'
worker_ip="$(kubectl get nodes -o jsonpath='{range .items[?(@.metadata.name=="worker-01")]}{.status.addresses[?(@.type=="InternalIP")].address}{end}')"
if [ -n "$worker_ip" ]; then
  printf 'http://%s:%s/\n' "$worker_ip" "$node_port"
else
  printf 'http://<worker-01-LAN-IP>:%s/\n' "$node_port"
fi

printf '\nPort-forward fallback:\n%s\n' "$PORT_FORWARD"
