#!/usr/bin/env bash
set -euo pipefail

cd "${1:-$(pwd)}"

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "[ERROR] Not inside a git repository"
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

echo "===== OpenClaw Diff Review ====="
echo

echo "--- Repo ---"
pwd

echo
printf '%s\n' "--- Git status --short ---"
git status --short || true

echo
printf '%s\n' "--- Diff stat (working tree) ---"
git diff --stat || true

echo
printf '%s\n' "--- Diff stat (staged) ---"
git diff --cached --stat || true

echo
printf '%s\n' "--- Changed files ---"
changed_files="$({ git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard; } | sed '/^$/d' | sort -u)"
if [ -z "$changed_files" ]; then
  echo "[OK] No unstaged, staged, or untracked changes"
else
  printf '%s\n' "$changed_files"
fi

echo
printf '%s\n' "--- Risk hints ---"
risk_found=0
for pattern in \
  '^config/' \
  '^scripts/' \
  '^agents/' \
  '^skills/' \
  '^docs/' \
  '^\.vscode/' \
  '^Makefile$'
do
  if printf '%s\n' "$changed_files" | grep -Eq "$pattern"; then
    case "$pattern" in
      '^config/') echo "[WARN] Config files changed, re-run schema and policy validation." ;;
      '^scripts/') echo "[WARN] Scripts changed, run bash -n scripts/*.sh and targeted script tests." ;;
      '^agents/') echo "[WARN] Agent docs changed, check role/config alignment." ;;
      '^skills/') echo "[WARN] Skills changed, verify skill names and guidance still match config/docs." ;;
      '^docs/') echo "[WARN] Docs changed, confirm they match actual workflow and config behavior." ;;
      '^\.vscode/') echo "[WARN] VS Code workflow files changed, confirm tasks and recommendations still work." ;;
      '^Makefile$') echo "[WARN] Makefile changed, re-run make validate and make doctor." ;;
    esac
    risk_found=1
  fi
done
if [ "$risk_found" -eq 0 ]; then
  echo "[OK] No obvious high-risk file classes changed"
fi

echo
printf '%s\n' "--- Suggested checks ---"
echo "bash scripts/validate-config.sh"
echo "git diff --stat"
if printf '%s\n' "$changed_files" | grep -Eq '^scripts/|^Makefile$'; then
  echo "bash -n scripts/*.sh"
fi
if printf '%s\n' "$changed_files" | grep -Eq '^Makefile$'; then
  echo "make validate"
  echo "make doctor"
fi

echo
printf '%s\n' "--- Recent commits ---"
git log --oneline -n 5 || true

echo
printf '%s\n' "[OK] review summary complete"
