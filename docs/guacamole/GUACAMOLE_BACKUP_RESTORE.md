# Guacamole PostgreSQL Backup / Restore

This guide is for the Helm deployment in `guacamole`.

## Backup path

Store backups under a repo-ignored local path such as:

```text
backups/guacamole/
```

## Identify the PostgreSQL pod

```bash
kubectl -n guacamole get pods -l app.kubernetes.io/name=postgresql,app.kubernetes.io/instance=guacamole
```

## Create a timestamped backup

Preferred flow:

1. Find the running PostgreSQL pod.
2. Read the PostgreSQL user password from the existing Kubernetes secret.
3. Run `pg_dump` from inside the pod.
4. Stream the dump to your local machine.
5. Compress and save it under `backups/guacamole/`.

Example command shape:

```bash
kubectl -n guacamole exec <postgres-pod> -- env PGPASSWORD='<from-secret>' pg_dump \
  -h 127.0.0.1 -U guacamole_user -d guacamole_db \
  --no-owner --no-acl | gzip > backups/guacamole/guacamole-$(date -u +%Y%m%dT%H%M%SZ).sql.gz
```

The helper script `scripts/guacamole/backup-guacamole-db.sh` automates this without printing secret values.

## Copying the dump out

If you need to stage the dump elsewhere, copy it from `backups/guacamole/` after the command finishes. Keep the file local unless you have an approved secure destination.

## Restore outline

Restore is intentionally not scripted here.

High-level outline only:

1. Confirm the target namespace and release.
2. Confirm the existing database can be overwritten.
3. Back up the current database first.
4. Restore with `psql` or `pg_restore` using the matching dump format.
5. Re-check Guacamole login and one known-good connection.

## Warnings

- Do not restore without explicit approval.
- Do not use restore as a troubleshooting shortcut.
- Do not reset the database unless the repo owner explicitly asks for that.
- Do not delete the PVC.
