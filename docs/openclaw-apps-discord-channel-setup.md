# openclaw-apps Discord channel setup

## Scope

Diagnose and wire `#openclaw-apps` (`1507382627651555480`) as a general OpenClaw app/project orchestration channel, with hello-world verification only.

## Files / config inspected

- `/home/scott/projects/openclaw-self/docs/discord-ttp.md`
- `/home/scott/projects/openclaw-self/.openclaw-mailbox/inbox/0013-diagnose-wire-openclaw-apps-discord-channel.md`
- `/home/scott/.openclaw/openclaw.json`
- Discord channel permissions via `message action=permissions`
- `openclaw doctor --non-interactive`

## What was missing

- `1507382627651555480` was not present in the Discord guild allowlist in `/home/scott/.openclaw/openclaw.json`.
- The existing working channels were already allowlisted, which made the omission easy to spot.

## What changed

- Added `1507382627651555480` to:
  - `channels.discord.guilds.*.channels`
- Kept it as a general-purpose channel with `requireMention: false`.
- Sent the hello-world test message to the channel.

## Channel registration

- Channel ID recorded: yes
- Channel name recorded: yes
- Purpose recorded: yes
  - `openclaw-apps is a general app/project orchestration channel. Initial use is Hello World validation only. It may later be bound to openclaw-price-action-paper-trader after explicit approval.`

## Hello World verification

- Posted to Discord: yes
- Message sent:
  - `Hello from OpenClaw. The openclaw-apps channel is reachable. No app project context is bound yet.`
- Discord message ID:
  - `1507749315441987665`

## Root cause

The channel was not wired because it was missing from the Discord guild channel allowlist in the live OpenClaw config.

## Reload / restart

- Required: no
- `gateway config.patch` applied successfully and the test message sent immediately after.
- `openclaw doctor --non-interactive` reported:
  - `Discord: ok`
  - no channel security warnings

## Next command

None required for wiring.

## Manual verification steps

- Confirm `#openclaw-apps` can receive and reply to a simple hello-world message.
- If you want to bind it to the paper-trader project later, get explicit approval first.

## Safe to return to paper-trader mailbox?

Yes.


## Discord model switching notes

- `fast` means the low-cost / quick cloud model.
- `local` means the local Ollama-backed model for dev/test workflows.
- Local model selection is dynamic: if Ollama is not running or `qwen2.5:7b` is not installed, `/model use local` will fail cleanly and no profile write will happen.
- The openclaw-apps profile is channel-local and only allows the projects listed in its profile JSON.
