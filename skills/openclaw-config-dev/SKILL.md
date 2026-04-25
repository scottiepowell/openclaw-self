---
name: openclaw-config-dev
description: Edit OpenClaw configuration, agent definitions, skills, channels, tools, web providers, or gateway settings. Use when changing config templates, routing, safety posture, or repo-managed OpenClaw architecture.
---

# OpenClaw Config Dev

Treat OpenClaw configuration as production infrastructure.

Rules:
- Never commit real secrets.
- Prefer env vars or local secret files.
- Keep example config separate from live config.
- Validate before proposing apply or sync.
- Keep Discord access allowlisted.
- Prefer Firecrawl as the active web provider for now.
- Keep `exec.ask` on unless Scott explicitly wants a lab-only exception.
- Explain exposure risk before changing loopback or access controls.

Before editing:

```bash
git status --short
find config agents skills docs scripts -maxdepth 3 -type f | sort
```

After editing:

```bash
bash scripts/validate-config.sh
git diff -- config agents skills docs scripts
```

Report:
- what changed
- why it changed
- whether live config must be synced
- whether restart is required
