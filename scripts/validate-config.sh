#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-config/openclaw.example.json5}"
BUNDLED_JSON5="/home/scott/.npm-global/lib/node_modules/openclaw/node_modules/json5"

if [ ! -f "$CONFIG" ]; then
  echo "[ERROR] Config file not found: $CONFIG"
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "[ERROR] node not found"
  exit 1
fi

if ! command -v openclaw >/dev/null 2>&1; then
  echo "[ERROR] openclaw CLI not found"
  exit 1
fi

if [ ! -d "$BUNDLED_JSON5" ]; then
  echo "[ERROR] bundled json5 parser not found at: $BUNDLED_JSON5"
  exit 1
fi

CONFIG_ABS="$(realpath "$CONFIG")"
echo "Validating: $CONFIG_ABS"

echo "[1/3] JSON5 parse"
node - <<'EOF' "$CONFIG_ABS" "$BUNDLED_JSON5"
const fs = require('fs');
const path = process.argv[2];
const json5Path = process.argv[3];
const JSON5 = require(json5Path);

const txt = fs.readFileSync(path, 'utf8');
if (!txt.trim()) throw new Error('empty config');

const cfg = JSON5.parse(txt);
if (!cfg || typeof cfg !== 'object' || Array.isArray(cfg)) {
  throw new Error('config root must be an object');
}

console.log('[OK] parsed JSON5 config:', path);
EOF

echo "[2/3] OpenClaw schema validation"
SCHEMA_OUTPUT="$(OPENCLAW_CONFIG_PATH="$CONFIG_ABS" openclaw config validate --json 2>&1)" || SCHEMA_STATUS=$?
SCHEMA_STATUS="${SCHEMA_STATUS:-0}"
printf '%s\n' "$SCHEMA_OUTPUT"
if [ "$SCHEMA_STATUS" -ne 0 ]; then
  echo "[ERROR] schema validation failed"
  exit "$SCHEMA_STATUS"
fi

echo "[3/3] Repo policy checks"
node - <<'EOF' "$CONFIG_ABS" "$BUNDLED_JSON5"
const fs = require('fs');
const path = process.argv[2];
const json5Path = process.argv[3];
const JSON5 = require(json5Path);

const txt = fs.readFileSync(path, 'utf8');
const cfg = JSON5.parse(txt);
const warnings = [];

if (cfg.channels?.discord?.threadBindings?.spawnAcpSessions === true) {
  warnings.push('channels.discord.threadBindings.spawnAcpSessions is for ACP harness threads. For normal subagent threads, prefer spawnSubagentSessions.');
}

if (cfg.channels?.discord?.token && cfg.channels.discord.token !== 'USE_ENV_OR_LOCAL_SECRET') {
  warnings.push('channels.discord.token is set to a non-placeholder value. Do not commit real secrets.');
}

if (!['on-miss', 'always'].includes(cfg.tools?.exec?.ask)) {
  warnings.push('tools.exec.ask should usually be "on-miss" or "always" for day-to-day safety.');
}

if (cfg.channels?.discord?.groupPolicy !== 'allowlist') {
  warnings.push('channels.discord.groupPolicy is not "allowlist". That is broader than the repo security model.');
}

if (cfg.agents?.defaults?.workspace !== '/home/scott/projects/openclaw-self') {
  warnings.push('agents.defaults.workspace does not point at the repo workspace.');
}

for (const warning of warnings) {
  console.log('[WARN]', warning);
}
console.log('[OK] repo policy checks complete');
EOF

echo "[OK] validation complete"
