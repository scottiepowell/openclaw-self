# AGENTS.md - OpenClaw Self-Improvement Project

## Mission

This repository manages Scott's OpenClaw architecture as a software engineering project.

The goal is to make OpenClaw behave like a Codex-style coding and DevOps assistant with:
- repo-bound workflows
- version-controlled config
- local skills
- agent roles
- VS Code integration
- Discord routing
- safe command execution
- Firecrawl web research

## Primary rules

- Always inspect the repository before changing files.
- Always check `git status --short` before edits.
- Prefer small, reviewable changes.
- Never commit unless Scott explicitly asks.
- Never push unless Scott explicitly asks.
- Never delete files unless Scott explicitly asks.
- Never expose secrets, tokens, keys, or OAuth data.
- Treat `config/openclaw.example.json5` as a template.
- Treat real `~/.openclaw/openclaw.json` as runtime config, not source of truth.
- Ask before running destructive or system-changing commands.

## Standard startup commands

Run these first when entering the repo:

```bash
pwd
git status --short
find . -maxdepth 3 -type f | sort
```

## Validation commands

Prefer these before proposing runtime changes:

```bash
bash scripts/doctor.sh
bash scripts/validate-config.sh
git diff -- config agents skills docs scripts
```

## Safe command posture

Allowed without extra confirmation:
- `git status`
- `git diff`
- `find`
- `ls`
- `cat`
- `grep`
- `jq` for read-only validation
- `docker ps`
- `docker logs`
- `docker inspect`
- `code .`

Ask first:
- changing system services
- restarting OpenClaw
- editing live `~/.openclaw/openclaw.json`
- running sync scripts
- deleting files
- Docker stop/remove/prune
- installing packages
- changing firewall/network settings

Forbidden unless Scott explicitly requests:
- `rm -rf`
- `git reset --hard`
- `git clean -fdx`
- force push
- deleting tokens or credentials
- formatting disks
- changing SSH keys

## Output format after work

Always report:
- Summary
- Files changed
- Commands run
- Validation result
- Risks or follow-up tasks
