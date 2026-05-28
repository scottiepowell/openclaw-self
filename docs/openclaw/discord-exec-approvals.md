# Discord exec approvals

## Active config

- `~/.openclaw/openclaw.json`

## Keys changed

- `commands.ownerAllowFrom`
  - Added Scott's Discord user ID so OpenClaw can resolve the approver from owner config.
- `channels.discord.execApprovals.approvers`
  - Added Scott's Discord user ID as an explicit fallback approver.

## Why

Discord exec approvals need a resolvable approver. OpenClaw can infer this from owner config, but the explicit approver list is a reliable fallback if inference is delayed or unavailable.

## How to find IDs

- Discord user ID: enable Discord Developer Mode, then copy the user's ID from their profile or message context menu.
- Discord channel ID: right-click the channel and copy its ID.
- Discord guild/server ID: right-click the server and copy its ID.

## How to test

1. From a Discord-connected OpenClaw session, run a harmless command like:
   - `pwd`
   - `kubectl get ns`
2. Confirm the approval prompt appears in Discord.
3. Approve it from the Discord channel or DM flow.
4. Confirm the command completes and is logged.

## Rollback

Restore the backup file:

```bash
cp ~/.openclaw/openclaw.json.bak.20260526-0528 ~/.openclaw/openclaw.json
```

Then restart/reload OpenClaw.

## Warning

- Do not disable exec approvals.
- Do not set always-allow.
- Keep approvals auditable and tied to known Discord identities.
