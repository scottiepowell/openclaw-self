# OpenClaw Git Mailbox Workflow

This document defines a lightweight GitHub-based mailbox pattern for coordinating with OpenClaw when direct desktop access is not available.

## Goal

Use this repository as an async handoff point between:

- ChatGPT or a desktop browser session that can write to GitHub
- OpenClaw running elsewhere, such as through a phone-accessible Discord channel
- The local `openclaw-self` working tree, which can pull and push the same GitHub remote

## Basic workflow

1. A prompt is written into `.openclaw-mailbox/inbox/`.
2. The change is committed and pushed to GitHub.
3. From the phone Discord channel, send OpenClaw a short instruction such as:

   ```text
   Pull openclaw-self, read the newest .openclaw-mailbox/inbox prompt, complete it, and write your response under .openclaw-mailbox/outbox.
   ```

4. OpenClaw pulls the repo, reads the newest inbox item, performs the requested work, and writes a response file under `.openclaw-mailbox/outbox/`.
5. OpenClaw commits and pushes its response.
6. The desktop side pulls the repo and reviews the response.

## Directory layout

```text
.openclaw-mailbox/
  README.md
  inbox/
    0001-example-task.md
  outbox/
    .gitkeep
  archive/
    .gitkeep
```

## File naming convention

Use a simple sequence number and short topic:

```text
0001-guacamole-helm-plan.md
0002-cloudflare-tunnel-plan.md
0003-review-k8s-storageclass.md
```

## Inbox prompt format

Each inbox prompt should include:

- Objective
- Repo path
- Constraints
- Requested files or commands
- Expected response location
- Whether OpenClaw is allowed to modify files

## Outbox response format

Each response should include:

- What OpenClaw inspected
- What OpenClaw changed
- Commands run
- Files changed
- Blockers
- Next recommended commands

## Safety rules

- OpenClaw should pull before starting work.
- OpenClaw should avoid destructive commands unless explicitly approved.
- OpenClaw should prefer docs, plans, dry-runs, Helm template validation, and small commits.
- OpenClaw should write a response file even if it cannot complete the task.
- For Kubernetes work, OpenClaw should inspect cluster state before installing or modifying workloads.

## Short phone prompt

Use this from Discord:

```text
In openclaw-self, pull latest main, read the newest .openclaw-mailbox/inbox prompt, do the requested work, then write and commit a response under .openclaw-mailbox/outbox.
```
