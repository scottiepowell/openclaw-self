#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME/.openclaw/openclaw.json"
DEST_DIR="$HOME/projects/openclaw-self/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$DEST_DIR"

if [ ! -f "$SRC" ]; then
  echo "[ERROR] Live config not found: $SRC"
  exit 1
fi

cp "$SRC" "$DEST_DIR/openclaw-$STAMP.json"
chmod 600 "$DEST_DIR/openclaw-$STAMP.json"

echo "[OK] Backed up live config to:"
echo "$DEST_DIR/openclaw-$STAMP.json"
