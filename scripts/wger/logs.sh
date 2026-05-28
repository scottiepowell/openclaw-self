#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="fitness"

pod_by_pattern() {
  local pattern="$1"
  kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=NAME:.metadata.name | grep -E "$pattern" | head -n1 || true
}

log_pod() {
  local title="$1"
  local pod="$2"
  local container="${3:-}"
  echo "== $title =="
  if [[ -z "$pod" ]]; then
    echo "No matching pod found"
    echo
    return 0
  fi
  if [[ -n "$container" ]]; then
    kubectl logs -n "$NAMESPACE" "$pod" -c "$container" --tail=200 || true
  else
    kubectl logs -n "$NAMESPACE" "$pod" --tail=200 || true
  fi
  echo
}

app_pod="$(pod_by_pattern 'wger-app')"
celery_pod="$(pod_by_pattern 'wger-celery')"
postgres_pod="$(pod_by_pattern 'wger-postgres')"
redis_pod="$(pod_by_pattern 'wger-redis')"

log_pod "wger app init-container" "$app_pod" "init-container"
log_pod "wger app" "$app_pod" "wger"
log_pod "wger celery" "$celery_pod"
log_pod "wger postgres" "$postgres_pod"
log_pod "wger redis" "$redis_pod"
