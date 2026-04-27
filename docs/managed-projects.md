# Managed Projects

This file lists software/configuration projects managed by OpenClaw.

## Core platform project

### openclaw-self

Path:

```text
~/projects/openclaw-self
```

Purpose:
- Manages OpenClaw configuration
- agent roles
- local skills
- validation scripts
- backups
- project bootstrap patterns

Rules:
- This is the core self-improvement project.
- Changes here affect how OpenClaw operates.
- Require extra review before syncing live config.
- Do not store secrets.
- Run `make validate-all` before completion.

## Child projects

### openclaw-home-media

Path:

```text
~/projects/openclaw-home-media
```

Purpose:
- Manages Home Assistant, Plex, Roku TV, Google Cast, and future OpenClaw AI media automations.

Rules:
- Do not store real PINs, Home Assistant tokens, Plex tokens, or kubeconfigs.
- Use Home Assistant scripts for approved routines.
- Use Kubernetes/Helm only through configured kubeconfig.
- Do not modify `openclaw-self` unless explicitly asked.

## Project creation rule

All new projects must be created under:

```text
~/projects/<project-name>
```

Do not nest child projects under `openclaw-self`.
