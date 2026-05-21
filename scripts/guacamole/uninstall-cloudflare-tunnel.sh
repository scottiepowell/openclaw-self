#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-cloudflare}"
RELEASE="${RELEASE:-guacamole-tunnel}"

command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found"; exit 1; }

helm -n "$NAMESPACE" uninstall "$RELEASE"
