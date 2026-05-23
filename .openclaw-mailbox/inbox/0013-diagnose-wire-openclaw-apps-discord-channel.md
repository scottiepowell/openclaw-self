# OpenClaw Self Inbox Prompt: Diagnose and Wire `openclaw-apps` Discord Channel

## Repo

Work in this repo only:

```text
/home/scott/projects/openclaw-self
```

GitHub repo:

```text
scottiepowell/openclaw-self
```

## Goal

The new Discord channel `openclaw-apps` does not appear to respond to OpenClaw prompts yet.

Diagnose and wire the channel so OpenClaw can respond there with a simple Hello World before we bind it to any app/project context.

## Channel details

Channel name:

```text
openclaw-apps
```

Channel ID:

```text
1507382627651555480
```

## Scope

This task is only about Discord/OpenClaw channel routing and verification.

Do not configure the paper-trader app yet.
Do not work in the paper-trader repo.
Do not work in the Strategy Lab repo.
Do not work in the historical data repo.
Do not add Alpaca/broker logic.
Do not add trading behavior.

## Diagnose

Inspect the OpenClaw self repo and local OpenClaw config/state to determine how Discord channel routing is currently configured.

Check for:

- Discord channel allowlists
- exec approval channel settings
- channel-to-project mappings
- channel memory/bootstrap mappings
- gateway config
- agent routing config
- project routing config
- any `AGENTS.md`, `BOOTSTRAP.md`, or docs that define Discord behavior
- whether `openclaw-apps` channel ID is missing from any routing config
- whether the Discord bot has permission to read/send in the channel
- whether a gateway reload or restart is required

Also inspect existing working channel setup and compare against this new channel.

## Configure

If a clear config change is needed, update the relevant OpenClaw config/docs to register `openclaw-apps` as a valid general-purpose app orchestration channel.

For this first pass, do not bind it to a specific repo yet.

Set the channel purpose as:

```text
openclaw-apps is a general app/project orchestration channel. Initial use is Hello World validation only. It may later be bound to openclaw-price-action-paper-trader after explicit approval.
```

## Verification

Try to verify the channel is reachable.

If OpenClaw has a safe command/tool to post a Discord test message, send this to channel ID `1507382627651555480`:

```text
Hello from OpenClaw. The openclaw-apps channel is reachable. No app project context is bound yet.
```

If there is no safe/local way to send the message, do not fake it. Report that config-side setup is complete and provide the exact manual Discord message to send/test.

## Gateway reload/restart

Determine whether the gateway needs reload or restart.

If a reload command exists, prefer reload over restart.

If restart is required, do not restart blindly unless that is normal for this repo and safe. Instead, state the exact command needed.

Look for actual project conventions and commands. Possible examples to investigate, but do not assume:

```text
openclaw dashboard
openclaw doctor
openclaw gateway reload
systemctl --user restart openclaw
pm2 restart
docker compose restart
```

## Deliverables

Create or update a diagnostic report:

```text
docs/openclaw-apps-discord-channel-setup.md
```

Include:

- files/config inspected
- what was missing
- what was changed
- whether channel ID `1507382627651555480` is now recorded
- whether a Hello World message was sent
- whether reload/restart is required
- exact reload/restart command if needed
- manual verification steps

Write the mailbox response to:

```text
.openclaw-mailbox/outbox/0013-diagnose-wire-openclaw-apps-discord-channel-response.md
```

Response should include:

1. Files changed.
2. Root cause or likely cause.
3. Whether channel ID/name were added.
4. Whether Hello World was posted.
5. Reload/restart requirement.
6. Exact next command Scott should run, if any.
7. Whether it is now safe to return to the paper-trader repo mailbox.

After committing, run:

```text
git push
```

Also reply in the current working Discord channel with only:

```text
Mailbox response written and pushed: .openclaw-mailbox/outbox/0013-diagnose-wire-openclaw-apps-discord-channel-response.md
```
