# OpenClaw Self Inbox Prompt: Set Up `openclaw-apps` Discord Channel Hello World

## Repo

Work in this repo only:

```text
/home/scott/projects/openclaw-self
```

This prompt is delivered through the GitHub-backed mailbox in:

```text
scottiepowell/openclaw-self
.openclaw-mailbox/inbox/
```

## Goal

Set up and verify OpenClaw can operate in a new Discord channel before we bind it to the new paper-trader application context.

This task is only about getting the Discord channel recognized and producing a safe hello-world response in that channel.

Do not configure the paper-trader project yet.
Do not edit the paper-trader repo yet.
Do not add Alpaca or broker functionality.
Do not touch Strategy Lab.

## New Discord channel

Channel ID:

```text
1507382627651555480
```

Channel name:

```text
openclaw-apps
```

## Required behavior

Update any OpenClaw channel/project routing, bootstrap docs, memory, or config needed so OpenClaw recognizes the `openclaw-apps` channel as a valid channel.

For this first pass, do not bind it deeply to a project-specific context. Treat it as a general app-orchestration channel with a hello-world verification only.

The new channel should be described as:

```text
openclaw-apps is a general app/project orchestration channel. Initial use is to verify OpenClaw can respond in the channel. Later, it may be bound to the openclaw-price-action-paper-trader repo / On The Levels app after explicit approval.
```

## Safety / scope boundaries

For this setup task:

- no paper trader setup yet
- no Strategy Lab changes
- no historical extractor changes
- no Alpaca order submission
- no broker APIs
- no live trading
- no paper orders
- no profitability claims

## Verification

After configuration, verify as much as possible from the repo/config side:

- channel ID is recorded correctly
- channel name is recorded correctly
- setup notes exist
- no project-specific paper-trader context is activated yet
- no trading-related behavior is enabled

If OpenClaw has a command or local way to send a hello-world message to the Discord channel, send a short message to channel `1507382627651555480`:

```text
Hello from OpenClaw. The openclaw-apps channel is reachable. No project context is bound yet.
```

If there is no safe/local way to send the message, do not fake it. Report that the config-side setup is complete and provide the exact manual Discord message to send/test.

## Deliverable

Write the response under:

```text
.openclaw-mailbox/outbox/0012-setup-openclaw-apps-discord-channel-hello-world-response.md
```

The response should include:

1. Files changed.
2. Whether the channel ID/name were recorded.
3. Whether a hello-world message was actually sent to Discord.
4. If not sent, the exact manual test message.
5. Any config or routing file updated.
6. Any follow-up needed before binding this channel to `openclaw-price-action-paper-trader`.
7. Test/validation result, if any.

After committing, run:

```text
git push
```

Also reply in the current Discord channel with only:

```text
Mailbox response written and pushed: .openclaw-mailbox/outbox/0012-setup-openclaw-apps-discord-channel-hello-world-response.md
```
