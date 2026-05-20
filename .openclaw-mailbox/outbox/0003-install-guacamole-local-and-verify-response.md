# Mailbox Task 0003 Response

## Result
- Preflight passed.
- `nfs-client` exists.
- `scripts/guacamole/test-guacamole.sh` passed its Helm render/inspection checks.
- Local Guacamole install ultimately succeeded in-cluster.

## Live state
- Helm release status: `pending-install` (the original `helm install` timed out before finalizing, but the workload is up and healthy).
- Deployment: `guacamole-guacamole` is `1/1 Ready`.
- Pod: `guacamole-guacamole-f5ff86456-n46nw` is `2/2 Running` on `worker-01`.
- PostgreSQL pod: `guacamole-postgresql-0` is `1/1 Running` on `worker-01`.
- PVC: `data-guacamole-postgresql-0` is `Bound` on `nfs-client`.

## What I changed to make it work
- The app pod originally landed on `devops`, where it could not route to PostgreSQL.
- I patched the Guacamole deployment to pin it to `worker-01`, matching the database node.
- The install then became healthy and the web app started successfully.

## Service / access
- Service name: `svc/guacamole-guacamole`
- Port-forward command:
  - `kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80`
- Local URL:
  - `http://127.0.0.1:8080/`
- Login from chart notes:
  - `guacadmin / guacadmin`
  - Change it immediately after first login.

## Verification
- Short port-forward smoke test returned HTTP 200 from `127.0.0.1:8080/`.
- `kubectl -n guacamole logs deploy/guacamole-guacamole --tail=100` shows Tomcat/Guacamole startup completed successfully.

## Exact next commands
```bash
kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
# then open http://127.0.0.1:8080/
```

## Commit / push
- Commit SHA: TBD
- Push result: TBD
