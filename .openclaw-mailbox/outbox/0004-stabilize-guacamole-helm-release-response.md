# Mailbox Task 0004 Response

## Result
- Preflight passed.
- Helm release was `pending-install` before the fix.
- Helm release is now `deployed`.
- Manual live patch was replaced by Helm values.

## What changed
- `helm/guacamole/values-local.yaml`
  - pinned Guacamole to `kubernetes.io/hostname=worker-01`
  - pinned PostgreSQL to `kubernetes.io/hostname=worker-01`
  - disabled `initDb.enabled` because the schema is already initialized and the hook has no scheduling controls
- `docs/guacamole/GUACAMOLE_PLAN.md`
  - documented the temporary worker pin and init-hook workaround
  - updated the port-forward command
- `scripts/guacamole/test-guacamole.sh`
  - now shows rendered scheduling hints and the real service name
- `scripts/guacamole/install-guacamole.sh`
  - now prints the real port-forward command

## Root cause
- When the app pod landed on `devops`, that node could not route to the PostgreSQL service/pod network (`No route to host`).
- The chart’s post-install init job also had no node scheduling controls and kept landing on `devops`, which blocked Helm completion.

## Helm status
- Before: `pending-install`
- After: `deployed`

## Current runtime state
- Deployment: `guacamole-guacamole` is `1/1 Available`
- App pod: `guacamole-guacamole-6cc5587d44-hbfk6` on `worker-01`
- PostgreSQL pod: `guacamole-postgresql-0` on `worker-01`
- PVC: `data-guacamole-postgresql-0` is `Bound` on `nfs-client`
- Service: `svc/guacamole-guacamole`

## Access
- Port-forward:
  - `kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80`
- URL:
  - `http://127.0.0.1:8080/`
- Default login:
  - `guacadmin / guacadmin`

## Validation
- `bash scripts/guacamole/test-guacamole.sh` passed
- `kubectl -n guacamole rollout status deploy/guacamole-guacamole --timeout=180s` passed
- Short HTTP smoke test returned `200`

## Commit / push
- Commit SHA: 928e4ac
- Push result: pending

## Next recommended action
- Leave Cloudflare and ingress disabled for now.
- If the cluster routing issue is fixed later, remove the temporary worker pin and re-enable `initDb` only when the hook can be scheduled safely.
