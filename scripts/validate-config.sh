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

echo "[4/7] Required agent role docs"

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

echo "[5/7] Agent and skill reference checks"
node - <<'EOF' "$CONFIG_ABS" "$BUNDLED_JSON5"
const fs = require('fs');
const path = require('path');
const configPath = process.argv[2];
const json5Path = process.argv[3];
const JSON5 = require(json5Path);

const repoRoot = path.dirname(path.dirname(configPath));
const cfg = JSON5.parse(fs.readFileSync(configPath, 'utf8'));
const errors = [];
const ok = [];

const configuredAgents = Array.isArray(cfg.agents?.list) ? cfg.agents.list : [];
const configuredAgentIds = new Set(configuredAgents.map((agent) => agent?.id).filter(Boolean));
const expectedAgentDocs = new Map([
  ['openclaw-architect', 'agents/openclaw-architect.md'],
  ['python-dev', 'agents/python-dev.md'],
  ['devops', 'agents/devops.md'],
  ['reviewer', 'agents/reviewer.md'],
  ['docs', 'agents/docs.md'],
  ['security', 'agents/security.md'],
]);

for (const [agentId, relPath] of expectedAgentDocs.entries()) {
  const absPath = path.join(repoRoot, relPath);
  if (!configuredAgentIds.has(agentId)) {
    errors.push(`required agent id missing from config: ${agentId}`);
  } else if (!fs.existsSync(absPath)) {
    errors.push(`required agent doc missing for ${agentId}: ${relPath}`);
  } else {
    ok.push(`${agentId} -> ${relPath}`);
  }
}

const referencedSkills = new Set();
for (const skill of cfg.agents?.defaults?.skills || []) referencedSkills.add(skill);
for (const agent of configuredAgents) {
  for (const skill of agent?.skills || []) referencedSkills.add(skill);
}

for (const skill of [...referencedSkills].sort()) {
  const relPath = `skills/${skill}/SKILL.md`;
  const absPath = path.join(repoRoot, relPath);
  if (!fs.existsSync(absPath)) {
    errors.push(`referenced skill missing: ${relPath}`);
  } else {
    ok.push(`skill -> ${relPath}`);
  }
}

for (const agent of configuredAgents) {
  const allowAgents = agent?.subagents?.allowAgents;
  if (!Array.isArray(allowAgents)) continue;
  for (const target of allowAgents) {
    if (!configuredAgentIds.has(target)) {
      errors.push(`agent ${agent.id} allows unknown subagent id: ${target}`);
    }
  }
}

for (const target of cfg.agents?.defaults?.subagents?.allowAgents || []) {
  if (!configuredAgentIds.has(target)) {
    errors.push(`agents.defaults.subagents.allowAgents contains unknown id: ${target}`);
  }
}

for (const line of ok) {
  console.log('[OK]', line);
}
for (const line of errors) {
  console.log('[ERROR]', line);
}
if (errors.length > 0) process.exit(1);
console.log('[OK] agent and skill reference checks complete');
EOF

echo "[6/7] Role doc and config alignment checks"
node - <<'EOF' "$CONFIG_ABS" "$BUNDLED_JSON5"
const fs = require('fs');
const path = require('path');
const configPath = process.argv[2];
const json5Path = process.argv[3];
const JSON5 = require(json5Path);

const repoRoot = path.dirname(path.dirname(configPath));
const cfg = JSON5.parse(fs.readFileSync(configPath, 'utf8'));
const errors = [];
const ok = [];

const architect = (cfg.agents?.list || []).find((agent) => agent?.id === 'openclaw-architect');
const architectDocPath = path.join(repoRoot, 'agents/openclaw-architect.md');
const architectDoc = fs.existsSync(architectDocPath) ? fs.readFileSync(architectDocPath, 'utf8') : '';

if (!architect) {
  errors.push('openclaw-architect config entry is missing.');
} else {
  if (architect.name !== 'Wright') {
    errors.push('openclaw-architect must use display name "Wright" in config.');
  } else {
    ok.push('openclaw-architect display name matches Wright');
  }

  const architectSkills = new Set(architect.skills || []);
  for (const skill of ['repo-triage', 'openclaw-config-dev', 'vscode-workflow']) {
    if (!architectSkills.has(skill)) {
      errors.push(`openclaw-architect is missing expected skill: ${skill}`);
    }
  }
  if (architectSkills.has('repo-triage') && architectSkills.has('openclaw-config-dev') && architectSkills.has('vscode-workflow')) {
    ok.push('openclaw-architect skills align with the repo contract');
  }
}

if (!architectDoc.includes('# Wright')) {
  errors.push('agents/openclaw-architect.md should start with the Wright role heading.');
} else {
  ok.push('architect doc uses Wright heading');
}

if (!architectDoc.includes('stable agent id is `openclaw-architect`')) {
  errors.push('agents/openclaw-architect.md should mention the stable agent id `openclaw-architect`.');
} else {
  ok.push('architect doc mentions stable agent id');
}

if (!architectDoc.includes('Commit completed repo changes when they are validated and reviewable.')) {
  errors.push('agents/openclaw-architect.md still appears out of sync with the repo commit policy.');
} else {
  ok.push('architect doc matches commit policy');
}

const configSkillPath = path.join(repoRoot, 'skills/openclaw-config-dev/SKILL.md');
const configSkillDoc = fs.existsSync(configSkillPath) ? fs.readFileSync(configSkillPath, 'utf8') : '';
if (configSkillDoc.includes('`exec.ask` on')) {
  errors.push('skills/openclaw-config-dev/SKILL.md contains obsolete `exec.ask` on guidance.');
}
if (!configSkillDoc.includes('`exec.ask` at `on-miss` or `always`')) {
  errors.push('skills/openclaw-config-dev/SKILL.md should document `exec.ask` as `on-miss` or `always`.');
} else {
  ok.push('openclaw-config-dev skill matches exec.ask guidance');
}

for (const line of ok) {
  console.log('[OK]', line);
}
for (const line of errors) {
  console.log('[ERROR]', line);
}
if (errors.length > 0) process.exit(1);
console.log('[OK] role doc and config alignment checks complete');
EOF

echo "[7/7] Repo asset contract checks"
node - <<'EOF' "$CONFIG_ABS"
const fs = require('fs');
const path = require('path');
const configPath = process.argv[2];
const repoRoot = path.dirname(path.dirname(configPath));
const errors = [];
const ok = [];

const requiredDocs = [
  'AGENTS.md',
  'README.md',
  'CHANGELOG.md',
  'docs/architecture.md',
  'docs/discord-ttp.md',
  'docs/runbook.md',
  'docs/security-model.md',
  'docs/vscode-ttp.md',
  'tests/README.md',
];
const requiredScripts = [
  'scripts/doctor.sh',
  'scripts/validate-config.sh',
  'scripts/backup-openclaw.sh',
  'scripts/sync-openclaw-config.sh',
  'scripts/review-diff.sh',
];
const requiredVsCodeFiles = [
  '.vscode/tasks.json',
  '.vscode/extensions.json',
];

for (const relPath of [...requiredDocs, ...requiredScripts, ...requiredVsCodeFiles, 'Makefile']) {
  const absPath = path.join(repoRoot, relPath);
  if (!fs.existsSync(absPath)) {
    errors.push(`required repo asset missing: ${relPath}`);
  } else {
    ok.push(`asset -> ${relPath}`);
  }
}

const makefilePath = path.join(repoRoot, 'Makefile');
if (fs.existsSync(makefilePath)) {
  const makefile = fs.readFileSync(makefilePath, 'utf8');
  for (const target of ['doctor:', 'validate:', 'diff:', 'review:', 'backup:', 'sync:']) {
    if (!makefile.includes(`\n${target}`) && !makefile.startsWith(target)) {
      errors.push(`Makefile missing expected target: ${target.replace(':', '')}`);
    }
  }
  if (makefile.includes('validate:')) ok.push('Makefile contains expected core targets');
}

const tasksPath = path.join(repoRoot, '.vscode/tasks.json');
if (fs.existsSync(tasksPath)) {
  const tasks = JSON.parse(fs.readFileSync(tasksPath, 'utf8'));
  const labels = new Set((tasks.tasks || []).map((task) => task.label));
  for (const label of ['OpenClaw: Doctor', 'OpenClaw: Validate Config', 'OpenClaw: Git Diff', 'OpenClaw: Review Diff', 'OpenClaw: Backup Live Config']) {
    if (!labels.has(label)) {
      errors.push(`.vscode/tasks.json missing expected task: ${label}`);
    }
  }
  if (labels.has('OpenClaw: Doctor') && labels.has('OpenClaw: Validate Config')) {
    ok.push('VS Code tasks contain expected OpenClaw workflow entries');
  }
}

const extensionsPath = path.join(repoRoot, '.vscode/extensions.json');
if (fs.existsSync(extensionsPath)) {
  const extensions = JSON.parse(fs.readFileSync(extensionsPath, 'utf8'));
  const recs = new Set(extensions.recommendations || []);
  for (const ext of ['ms-python.python', 'ms-azuretools.vscode-docker']) {
    if (!recs.has(ext)) {
      errors.push(`.vscode/extensions.json missing expected recommendation: ${ext}`);
    }
  }
  if (recs.has('ms-python.python') && recs.has('ms-azuretools.vscode-docker')) {
    ok.push('VS Code extension recommendations contain core entries');
  }
}

for (const line of ok) {
  console.log('[OK]', line);
}
for (const line of errors) {
  console.log('[ERROR]', line);
}
if (errors.length > 0) process.exit(1);
console.log('[OK] repo asset contract checks complete');
EOF

echo "[OK] validation complete"
