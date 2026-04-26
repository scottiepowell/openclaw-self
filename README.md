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
make review
code .
```

## Human workflow

1. Open the repo in VS Code.
2. Ask OpenClaw to use the appropriate agent role.
3. Make small changes.
4. Run validation.
5. Run `make review` to summarize the current diff and risk areas.
6. Review `git diff` if needed.
7. Backup live config.
8. Sync to live config only after approval.

## Safety

Do not commit secrets. Do not run destructive commands without explicit approval.
