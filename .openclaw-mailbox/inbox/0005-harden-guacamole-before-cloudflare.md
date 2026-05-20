# Mailbox Task 0005 — Harden Guacamole Before Cloudflare

## Objective

Guacamole is now running locally and Helm is stabilized. Before any Cloudflare Tunnel or public exposure work, harden the local Guacamole deployment and document the required manual security steps.

This task should **not** expose Guacamole publicly.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Current known state

From Task 0004 and Scott's local test:

- Helm release is now `deployed`.
- Guacamole app is healthy.
- PostgreSQL is healthy.
- PVC is `Bound` on `nfs-client`.
- App and PostgreSQL are temporarily pinned to `worker-01` because the `devops` node cannot route to the PostgreSQL pod/service network.
- Local port-forward works:

  ```bash
  kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
  ```

- Local URL works:

  ```text
  http://127.0.0.1:8080/
  ```

- Default chart credentials are currently documented as:

  ```text
  guacadmin / guacadmin
  ```

## Important security goal

Before Cloudflare Tunnel work begins, the repo should clearly document that Scott must change the default Guacamole admin credentials or create a new admin and disable/remove the default account.

Do **not** print database passwords or Kubernetes secret values.
Do **not** reset the database.
Do **not** delete the PVC.

## Required checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
git status --short
git branch --show-current
helm -n guacamole status guacamole
kubectl -n guacamole get pods,pvc,svc -o wide
kubectl -n guacamole get secrets
```

## Work requested

Create or update documentation and helper scripts for the hardening phase.

Suggested files:

```text
docs/guacamole/GUACAMOLE_SECURITY_CHECKLIST.md
docs/guacamole/GUACAMOLE_BACKUP_RESTORE.md
scripts/guacamole/backup-guacamole-db.sh
scripts/guacamole/verify-guacamole-security.sh
```

Update existing files if useful:

```text
docs/guacamole/GUACAMOLE_PLAN.md
scripts/guacamole/test-guacamole.sh
```

## Security checklist content requirements

The checklist should include:

1. Port-forward command.
2. URL to open locally.
3. First-login task: change `guacadmin` password immediately.
4. Recommended safer path:
   - log in as `guacadmin`
   - create a named admin user for Scott
   - verify the new admin can log in
   - disable or delete the default `guacadmin` user if practical
5. Create a test connection only after credentials are changed.
6. Do not expose through Cloudflare until Cloudflare Access is configured.
7. Cloudflare Access should protect the Guacamole hostname before the request reaches the app.
8. Keep Kubernetes service as `ClusterIP`.
9. Do not enable ingress unless explicitly approved.
10. Note the temporary `worker-01` pin and the underlying cluster routing issue.

## Backup/restore content requirements

Add a practical PostgreSQL backup/restore guide for this Helm deployment.

The guide should include:

- How to identify the PostgreSQL pod.
- How to create a timestamped `pg_dump` backup from the Guacamole database.
- How to copy the dump out of the pod/namespace.
- How to store backups under a repo-ignored local path such as `backups/guacamole/`.
- A restore outline with strong warnings.
- A statement that restore should not be run without explicit approval.

If you create `backup-guacamole-db.sh`, make it conservative:

- Read-only backup only.
- No restore behavior.
- Do not print passwords.
- Use Kubernetes secret references or pod environment where practical.
- Store output under `backups/guacamole/` or a path configurable by env var.
- Add useful error handling.

## Verification script requirements

If you create `verify-guacamole-security.sh`, it should check non-invasive things only:

- Helm release status.
- Pods ready.
- PVC bound.
- Service is ClusterIP.
- Ingress is absent/disabled.
- Remind Scott to verify default password is changed manually.

It should not attempt to log into Guacamole.
It should not print secrets.

## Validation commands

After file changes, run:

```bash
bash scripts/guacamole/test-guacamole.sh
bash scripts/guacamole/verify-guacamole-security.sh || true
```

If you create a backup script, run a dry-run/help check if supported. Do not create a database dump unless the script is clearly safe and read-only.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0005-harden-guacamole-before-cloudflare-response.md
```

## Response must include

- Current Helm status
- Current pod/PVC/service status
- Files created or changed
- Whether scripts were made executable
- Validation command results
- Exact manual steps Scott should perform in the Guacamole UI
- Exact next recommended prompt/action
- Commit SHA
- Push result

## Do not do yet

- Do not configure Cloudflare Tunnel.
- Do not enable ingress.
- Do not expose Guacamole publicly.
- Do not reset Guacamole database.
- Do not delete PostgreSQL PVC.
- Do not print secret values.

## Safety rule

If anything looks unstable, stop after documentation/script changes and write the blocker clearly in the outbox response.
