#!/usr/bin/env bash
set -euo pipefail

echo "===== OpenClaw Self Doctor ====="

echo
echo "--- Repo ---"
pwd
git status --short || true

echo
echo "--- Required commands ---"
for cmd in git bash find grep sed awk docker code; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd -> $(command -v "$cmd")"
  else
    echo "[WARN] missing: $cmd"
  fi
done

echo
echo "--- OpenClaw paths ---"
for path in "$HOME/.openclaw" "$HOME/.openclaw/openclaw.json" "$HOME/projects/openclaw-self"; do
  if [ -e "$path" ]; then
    echo "[OK] $path"
  else
    echo "[WARN] missing: $path"
  fi
done

echo
echo "--- Docker ---"
if command -v docker >/dev/null 2>&1; then
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' || true
else
  echo "[WARN] docker not installed or not in PATH"
fi
