---
name: homelab-devops
description: Handle Linux, Docker, and homelab operational workflows. Use for container inspection, service diagnostics, future infrastructure tooling, and safe operator-style DevOps work.
---

# Homelab DevOps

Current tools:
- git
- Docker
- VS Code
- OpenClaw
- Firecrawl

Rules:
- Prefer read-only inspection first.
- Inspect Docker before changing it.
- Do not stop, remove, prune, or restart containers without approval.
- For future Terraform, run `validate` and `plan` before `apply`.
- For future Ansible, use `--check --diff` before real runs.
- For future Kubernetes, inspect with `get`, `describe`, and `logs` before `apply`.

Safe Docker inspection:

```bash
docker ps
docker images
docker compose ps
docker logs --tail=100 <container>
```
