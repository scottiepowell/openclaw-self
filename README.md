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
make validate-all
make review
code .
```

## Human workflow

1. Open the repo in VS Code.
2. Ask OpenClaw to use the appropriate agent role.
3. Make small changes.
4. Run validation.
5. Run `make validate-all` before calling work done.
6. Run `make review` to summarize the current diff and risk areas.
7. Review `git diff` if needed.
8. Backup live config.
9. Sync to live config only after approval.

## Safety

Do not commit secrets. Do not run destructive commands without explicit approval.

## Project model

`openclaw-self` is the core platform project for OpenClaw itself.

Use it to manage:
- OpenClaw config
- agent definitions
- local skills
- validation scripts
- project bootstrap rules
- safety model

Do not place unrelated automation or app projects inside this repo.

Create child projects under:

```text
~/projects/<project-name>
```

Current child projects are tracked in `docs/managed-projects.md`.

## Starting a new coding project

Create new projects under `~/projects/<project-name>`, not inside `openclaw-self`.

Best starter files:
- `AGENTS.md` for repo rules and workflow
- `README.md` for project overview
- `TASKS.md` for the high-level to-do list
- `docs/architecture.md` for design notes

See `docs/project-bootstrap.md` for the concrete setup pattern.
