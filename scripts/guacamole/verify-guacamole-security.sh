#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-guacamole}"
RELEASE="${RELEASE:-guacamole}"
SERVICE="${SERVICE:-${RELEASE}-guacamole}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

fail() {
  echo "[ERROR] $1"
  exit 1
}

echo "[1/6] Helm release status"
helm -n "$NAMESPACE" status "$RELEASE" >/dev/null

echo "[2/6] Pod readiness"
mapfile -t pods < <(kubectl -n "$NAMESPACE" get pods -l app.kubernetes.io/instance="$RELEASE" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
[ "${#pods[@]}" -gt 0 ] || fail "no pods found for release $RELEASE"
for pod in "${pods[@]}"; do
  ready="$(kubectl -n "$NAMESPACE" get pod "$pod" -o jsonpath='{range .status.containerStatuses[*]}{.ready}{" "}{end}')"
  echo "  - $pod : $ready"
  echo "$ready" | grep -q 'false' && fail "pod $pod is not fully ready"
  echo "$ready" | grep -q 'true' || fail "pod $pod readiness not reported"
done

echo "[3/6] PVC bound"
mapfile -t pvcs < <(kubectl -n "$NAMESPACE" get pvc -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.phase}{"\n"}{end}')
[ "${#pvcs[@]}" -gt 0 ] || fail "no PVCs found in namespace $NAMESPACE"
for pvc in "${pvcs[@]}"; do
  echo "  - $pvc"
  echo "$pvc" | grep -q 'Bound' || fail "PVC not bound: $pvc"
done

echo "[4/6] Service type"
service_type="$(kubectl -n "$NAMESPACE" get svc "$SERVICE" -o jsonpath='{.spec.type}')"
echo "  - $SERVICE : $service_type"
[ "$service_type" = "ClusterIP" ] || fail "service $SERVICE is not ClusterIP"

echo "[5/6] Ingress absent"
ingress_count="$(kubectl -n "$NAMESPACE" get ingress -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null || true)"
ingress_count="$(printf '%s\n' "$ingress_count" | sed '/^$/d' | wc -l | tr -d ' ')"
if [ "$ingress_count" != "0" ]; then
  kubectl -n "$NAMESPACE" get ingress
  fail "ingress resources exist; keep ingress disabled for this phase"
fi

echo "[6/6] Manual security reminder"
echo "  - Confirm the default guacadmin password was changed manually"
echo "  - Do not proceed to Cloudflare until Access is configured in front of the app"
echo "  - Keep the temporary worker-01 pin until the cluster routing issue is fixed"

echo "Security checks passed"
