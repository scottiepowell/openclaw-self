#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-config/openclaw.example.json5}"

echo "Validating: $CONFIG"

if [ ! -f "$CONFIG" ]; then
  echo "[ERROR] Config file not found: $CONFIG"
  exit 1
fi

if command -v node >/dev/null 2>&1; then
  node -e '
    const fs = require("fs");
    const path = process.argv[1];
    const txt = fs.readFileSync(path, "utf8");
    if (!txt.trim()) throw new Error("empty config");
    console.log("[OK] readable config file:", path);
  ' "$CONFIG"
else
  echo "[WARN] node not found; doing basic file check only"
  test -s "$CONFIG"
fi

echo "[OK] validation complete"
