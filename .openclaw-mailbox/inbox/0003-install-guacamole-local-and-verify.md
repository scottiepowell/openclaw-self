# Mailbox Task 0003 — Install Guacamole Locally and Verify

## Objective

Proceed from scaffold validation to a controlled local Kubernetes install of Apache Guacamole using the existing Helm scaffold.

This is now approved for local install only.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Context

Task 0002 confirmed:

- Branch is `main`.
- GitHub SSH auth works.
- Remote is SSH-based.
- Guacamole scaffold files exist.
- `bash scripts/guacamole/test-guacamole.sh` ran safe template/inspection checks.
- Guacamole has not been installed yet.

Current scaffold files expected on `main`:

```text
docs/guacamole/GUACAMOLE_PLAN.md
docs/guacamole/CLOUDFLARE_TUNNEL_PLAN.md
helm/guacamole/values-local.yaml
helm/guacamole/values-cloudflare.yaml
scripts/guacamole/install-guacamole.sh
scripts/guacamole/test-guacamole.sh
scripts/guacamole/uninstall-guacamole.sh
```

## Install scope

You are approved to install Guacamole into Kubernetes using the existing script:

```bash
bash scripts/guacamole/install-guacamole.sh
```

Do not configure Cloudflare Tunnel yet.
Do not enable ingress yet.
Keep Guacamole internal/local only.

## Required preflight checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
pwd
git status --short
git branch --show-current
git remote -v
kubectl get nodes -o wide
kubectl get storageclass
kubectl get pv,pvc -A
helm list -A
```

Confirm that the NFS-backed StorageClass referenced by `helm/guacamole/values-local.yaml` exists:

```bash
grep -n "storageClass" helm/guacamole/values-local.yaml
kubectl get storageclass nfs-client
```

If `nfs-client` does not exist, stop and write the blocker response. Do not install.

## Required dry-run/test step

Before installing, run:

```bash
bash scripts/guacamole/test-guacamole.sh
```

If this fails in a way that indicates invalid Helm values, stop and write the blocker response.

## Install step

If preflight and test are acceptable, run:

```bash
bash scripts/guacamole/install-guacamole.sh
```

## Post-install verification

Run and summarize:

```bash
kubectl -n guacamole get all
kubectl -n guacamole get pvc
kubectl -n guacamole get secrets
helm -n guacamole status guacamole
kubectl -n guacamole describe pods
kubectl -n guacamole logs deploy/guacamole --tail=100 || true
```

If the deployment names differ, inspect `kubectl -n guacamole get deploy` and use the actual names.

## Local access test

Do not leave a long-running port-forward process unattended.

Run a short port-forward test if possible, for example:

```bash
kubectl -n guacamole get svc
```

Then identify the correct service name and write the exact command Scott should run locally, likely one of:

```bash
kubectl -n guacamole port-forward svc/guacamole 8080:80
```

or whatever service name actually exists.

If you can safely test with a short-lived background port-forward and `curl`, do so and then kill the background process. Example pattern:

```bash
kubectl -n guacamole port-forward svc/guacamole 8080:80 >/tmp/guacamole-port-forward.log 2>&1 &
PF_PID=$!
sleep 5
curl -I http://127.0.0.1:8080/ || true
kill "$PF_PID" || true
cat /tmp/guacamole-port-forward.log
```

Adjust the service name if needed.

## Failure handling

The install script uses `--atomic`, so Helm should roll back on failure.

If install fails:

1. Capture the exact error.
2. Run:

   ```bash
   helm -n guacamole status guacamole || true
   kubectl -n guacamole get all,pvc,secrets
   kubectl -n guacamole describe pods || true
   kubectl -n guacamole get events --sort-by=.lastTimestamp | tail -40 || true
   ```

3. Do not repeatedly retry.
4. Write the outbox response with the blocker and next fix.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0003-install-guacamole-local-and-verify-response.md
```

## Response must include

- Whether preflight passed
- Whether `nfs-client` exists
- Whether Helm template/test passed
- Whether install succeeded
- Helm release status
- Pod status
- PVC status
- Service name and port-forward command
- Login URL/path to try from Scott's machine
- Any default credentials or credential location, if the chart documents or prints them
- Exact commands Scott should run next
- Commit SHA for the response
- Push result

## Safety rules

- Do not configure Cloudflare yet.
- Do not enable ingress yet.
- Do not expose Guacamole outside the cluster/LAN.
- Do not delete unrelated resources.
- Do not print private secrets or private SSH keys.
- If blocked, still write a response explaining the exact blocker.
