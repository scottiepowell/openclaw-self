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

if (cfg.agents?.defaults?.repoRoot !== '/home/scott/projects/openclaw-self') {
  warnings.push('agents.defaults.repoRoot does not point at the repo root.');
}

if (cfg.agents?.defaults?.subagents?.requireAgentId !== true) {
  warnings.push('agents.defaults.subagents.requireAgentId should usually be true in this repo to keep delegation explicit.');
}

const architect = cfg.agents?.list?.find((agent) => agent?.id === 'openclaw-architect');
const architectAllow = architect?.subagents?.allowAgents;
if (!Array.isArray(architectAllow) || architectAllow.length === 0) {
  warnings.push('openclaw-architect should usually have an explicit subagent allowlist.');
}

if (architect?.name !== 'Wright') {
  warnings.push('openclaw-architect should usually use the display name "Wright" in this repo.');
}

for (const warning of warnings) {
  console.log('[WARN]', warning);
}
console.log('[OK] repo policy checks complete');
EOF

echo "[4/4] Required agent role docs"

required_agent_docs=(
  "agents/openclaw-architect.md"
  "agents/python-dev.md"
  "agents/devops.md"
  "agents/reviewer.md"
  "agents/docs.md"
  "agents/security.md"
)

missing_agent_docs=0
for doc in "${required_agent_docs[@]}"; do
  if [ -f "$doc" ]; then
    echo "[OK] $doc"
  else
    echo "[ERROR] Missing required agent doc: $doc"
    missing_agent_docs=1
  fi
done

if [ "$missing_agent_docs" -ne 0 ]; then
  exit 1
fi

echo "[OK] required agent docs complete"

echo "[OK] validation complete"
