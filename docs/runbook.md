# Runbook

## Routine workflow

```bash
make doctor
make validate
make validate-all
make review
make diff
```

## Before syncing live config

1. Run `make review` and inspect the risk hints.
2. Review the diff.
3. Backup the live config.
4. Confirm the target file and overwrite intent.
5. Sync only after approval.
