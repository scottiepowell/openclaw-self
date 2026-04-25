#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-config/openclaw.json5}"
DEST="$HOME/.openclaw/openclaw.json"

echo "Source: $SRC"
echo "Dest: $DEST"

if [ ! -f "$SRC" ]; then
  echo "[ERROR] Source config not found: $SRC"
  exit 1
fi

echo
echo "This will overwrite the live OpenClaw config."
read -r -p "Type APPLY to continue: " answer

if [ "$answer" != "APPLY" ]; then
  echo "Aborted."
  exit 0
fi

bash scripts/backup-openclaw.sh
cp "$SRC" "$DEST"
chmod 600 "$DEST"

echo "[OK] Synced config. Restart OpenClaw if required."
