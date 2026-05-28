#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VALUES_TEMPLATE="$ROOT_DIR/helm/wger/values-local.yaml"
RELEASE="wger"
NAMESPACE="fitness"
REPO_NAME="wger"
REPO_URL="https://wger-project.github.io/helm-charts"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

detect_storage_class() {
  local candidates selected
  candidates="$(kubectl get storageclass -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.provisioner}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}')"

  selected="$(printf '%s\n' "$candidates" | awk -F '\t' '
    tolower($1) ~ /nfs/ && $3 == "true" { print $1; exit }
  ')"
  if [[ -z "$selected" ]]; then
    selected="$(printf '%s\n' "$candidates" | awk -F '\t' '
      tolower($2) ~ /nfs|subdir/ { print $1; exit }
    ')"
  fi
  if [[ -z "$selected" ]]; then
    selected="$(printf '%s\n' "$candidates" | awk -F '\t' '
      $3 == "true" { print $1; exit }
    ')"
  fi
  if [[ -z "$selected" ]]; then
    echo "Unable to detect a usable storageClass. Check kubectl get storageclass." >&2
    exit 1
  fi

  printf '%s\n' "$selected"
}

ensure_pvc() {
  local name="$1"
  local size="$2"
  if kubectl get pvc -n "$NAMESPACE" "$name" >/dev/null 2>&1; then
    return 0
  fi

  cat <<EOF | kubectl apply -n "$NAMESPACE" -f - >/dev/null
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $name
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: $storage_class
  resources:
    requests:
      storage: $size
EOF
}

require_cmd kubectl
require_cmd helm
require_cmd awk
require_cmd sed

if ! helm repo list | awk -v repo="$REPO_NAME" '$1 == repo { found = 1 } END { exit found ? 0 : 1 }'; then
  helm repo add "$REPO_NAME" "$REPO_URL"
fi
helm repo update >/dev/null

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

storage_class="$(detect_storage_class)"
tmp_values="$(mktemp)"
trap 'rm -f "$tmp_values"' EXIT
sed "s/__NFS_STORAGE_CLASS__/${storage_class}/g" "$VALUES_TEMPLATE" > "$tmp_values"

ensure_pvc "wger-media" "10Gi"
ensure_pvc "wger-static" "2Gi"
ensure_pvc "wger-celery-beat" "1Gi"

echo "Using storageClass: $storage_class"
helm upgrade --install "$RELEASE" "$REPO_NAME/$RELEASE" \
  -n "$NAMESPACE" \
  -f "$tmp_values"
