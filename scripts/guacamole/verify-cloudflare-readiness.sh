#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-guacamole}"
RELEASE="${RELEASE:-guacamole}"
SERVICE="${SERVICE:-${RELEASE}-guacamole}"
SECURITY_CHECKLIST="${SECURITY_CHECKLIST:-$PWD/docs/guacamole/GUACAMOLE_SECURITY_CHECKLIST.md}"
ACCESS_SETUP_DOC="${ACCESS_SETUP_DOC:-$PWD/docs/guacamole/CLOUDFLARE_ACCESS_SETUP.md}"
BACKUP_GUIDE="${BACKUP_GUIDE:-$PWD/docs/guacamole/GUACAMOLE_BACKUP_RESTORE.md}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

fail() {
  echo "[ERROR] $1"
  exit 1
}

echo "[1/7] Helm release deployed"
helm -n "$NAMESPACE" status "$RELEASE" >/dev/null

echo "[2/7] Service exists and is ClusterIP"
service_type="$(kubectl -n "$NAMESPACE" get svc "$SERVICE" -o jsonpath='{.spec.type}')"
echo "  - $SERVICE : $service_type"
[ "$service_type" = "ClusterIP" ] || fail "service $SERVICE is not ClusterIP"

if ! kubectl -n "$NAMESPACE" get svc "$SERVICE" >/dev/null 2>&1; then
  fail "service $SERVICE not found"
fi

echo "[3/7] Pods ready"
mapfile -t pods < <(kubectl -n "$NAMESPACE" get pods -l app.kubernetes.io/instance="$RELEASE" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
[ "${#pods[@]}" -gt 0 ] || fail "no pods found for release $RELEASE"
for pod in "${pods[@]}"; do
  ready="$(kubectl -n "$NAMESPACE" get pod "$pod" -o jsonpath='{range .status.containerStatuses[*]}{.ready}{" "}{end}')"
  echo "  - $pod : $ready"
  echo "$ready" | grep -q 'false' && fail "pod $pod is not fully ready"
  echo "$ready" | grep -q 'true' || fail "pod $pod readiness not reported"
done

echo "[4/7] PVC bound"
mapfile -t pvcs < <(kubectl -n "$NAMESPACE" get pvc -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.phase}{"\n"}{end}')
[ "${#pvcs[@]}" -gt 0 ] || fail "no PVCs found in namespace $NAMESPACE"
for pvc in "${pvcs[@]}"; do
  echo "  - $pvc"
  echo "$pvc" | grep -q 'Bound' || fail "PVC not bound: $pvc"
done

echo "[5/7] No ingress present"
ingress_count="$(kubectl -n "$NAMESPACE" get ingress -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null || true)"
ingress_count="$(printf '%s\n' "$ingress_count" | sed '/^$/d' | wc -l | tr -d ' ')"
if [ "$ingress_count" != "0" ]; then
  kubectl -n "$NAMESPACE" get ingress
  fail "ingress resources exist; keep ingress disabled"
fi

echo "[6/7] Documentation present"
[ -f "$SECURITY_CHECKLIST" ] || fail "missing security checklist: $SECURITY_CHECKLIST"
[ -f "$ACCESS_SETUP_DOC" ] || fail "missing Cloudflare Access setup doc: $ACCESS_SETUP_DOC"
[ -f "$BACKUP_GUIDE" ] || fail "missing backup/restore guide: $BACKUP_GUIDE"

echo "[7/7] Manual readiness reminders"
echo "  - Confirm the local Guacamole UI security gate is complete"
echo "  - Confirm the default guacadmin password was changed manually"
echo "  - Configure Cloudflare Access before deploying tunnel routing"
echo "  - Do not deploy cloudflared yet"

echo "Cloudflare readiness checks passed"
