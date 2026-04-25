# Runbook

## Routine workflow

```bash
make doctor
make validate
make diff
```

## Before syncing live config

1. Review the diff.
2. Backup the live config.
3. Confirm the target file and overwrite intent.
4. Sync only after approval.
