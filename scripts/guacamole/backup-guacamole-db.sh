#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-guacamole}"
RELEASE="${RELEASE:-guacamole}"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups/guacamole}"
POSTGRES_POD_SELECTOR="${POSTGRES_POD_SELECTOR:-app.kubernetes.io/instance=${RELEASE},app.kubernetes.io/name=postgresql}"
POSTGRES_SECRET="${POSTGRES_SECRET:-${RELEASE}-postgresql-auth}"
POSTGRES_DB="${POSTGRES_DB:-guacamole_db}"
POSTGRES_USER="${POSTGRES_USER:-guacamole_user}"
PASSWORD_KEY="${PASSWORD_KEY:-user-password}"

command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found"; exit 1; }
command -v gzip >/dev/null 2>&1 || { echo "[ERROR] gzip not found"; exit 1; }

mkdir -p "$BACKUP_DIR"

POD="$(kubectl -n "$NAMESPACE" get pod -l "$POSTGRES_POD_SELECTOR" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$POD" ]; then
  echo "[ERROR] could not find a PostgreSQL pod in namespace $NAMESPACE"
  exit 1
fi

if ! kubectl -n "$NAMESPACE" get secret "$POSTGRES_SECRET" >/dev/null 2>&1; then
  echo "[ERROR] missing secret: $POSTGRES_SECRET"
  exit 1
fi

PASSWORD_B64="$(kubectl -n "$NAMESPACE" get secret "$POSTGRES_SECRET" -o "jsonpath={.data['${PASSWORD_KEY}']}" )"
if [ -z "$PASSWORD_B64" ]; then
  echo "[ERROR] secret key $PASSWORD_KEY is empty or missing"
  exit 1
fi
PASSWORD="$(printf '%s' "$PASSWORD_B64" | base64 --decode)"

if ! kubectl -n "$NAMESPACE" exec "$POD" -- sh -lc 'command -v pg_dump >/dev/null 2>&1'; then
  echo "[ERROR] pg_dump is not available in pod $POD"
  exit 1
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
outfile="$BACKUP_DIR/${RELEASE}-${POSTGRES_DB}-${timestamp}.sql.gz"

echo "[1/4] PostgreSQL pod: $POD"
echo "[2/4] Writing backup to: $outfile"

echo "[3/4] Running pg_dump"
kubectl -n "$NAMESPACE" exec -i "$POD" -- env \
  PGPASSWORD="$PASSWORD" \
  pg_dump -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" --no-owner --no-acl | gzip > "$outfile"

echo "[4/4] Backup complete"
ls -lh "$outfile"
