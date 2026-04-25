# OpenClaw Self-Improvement Project

This repo manages Scott's OpenClaw architecture as a software engineering project.

## Goals

- Codex-like software engineering workflow
- Version-controlled OpenClaw config templates
- Agent role definitions
- Local skills
- VS Code workflow
- Discord routing
- Firecrawl web research
- Git-based change control

## Primary project

OpenClaw itself is the first managed dev project.

## Quick start

```bash
cd ~/projects/openclaw-self
make doctor
make validate
code .
```

## Human workflow

1. Open the repo in VS Code.
2. Ask OpenClaw to use the appropriate agent role.
3. Make small changes.
4. Run validation.
5. Review `git diff`.
6. Backup live config.
7. Sync to live config only after approval.

## Safety

Do not commit secrets. Do not run destructive commands without explicit approval.
