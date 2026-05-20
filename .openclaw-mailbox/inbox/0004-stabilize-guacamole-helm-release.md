# Mailbox Task 0004 — Stabilize Guacamole Helm Release

## Objective

Guacamole is running, but Task 0003 reported two important issues:

1. Helm release status is `pending-install` even though the workload is healthy.
2. The Guacamole deployment was manually patched to pin the app pod to `worker-01` because the app pod originally landed on `devops` and could not route to PostgreSQL.

Before Cloudflare exposure, clean this up so the deployment is reproducible from Helm values and the Helm release state is healthy.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Current known state

From Task 0003:

- Guacamole app pod is running: `guacamole-guacamole-f5ff86456-n46nw`
- PostgreSQL pod is running: `guacamole-postgresql-0`
- Both are on `worker-01`
- PVC `data-guacamole-postgresql-0` is `Bound`
- Service is `svc/guacamole-guacamole`
- Access command works:

  ```bash
  kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
  ```

- Login is currently default `guacadmin / guacadmin`; do not expose publicly yet.

## Required first checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
git status --short
git branch --show-current
git log --oneline -5
helm -n guacamole status guacamole || true
helm -n guacamole list
kubectl -n guacamole get all -o wide
kubectl -n guacamole get pvc -o wide
kubectl -n guacamole get events --sort-by=.lastTimestamp | tail -80
kubectl get nodes -o wide
kubectl get pods -A -o wide | grep -E 'guacamole|postgres|calico|coredns' || true
```

## Diagnose the node routing issue

Investigate why Guacamole could not route to PostgreSQL when the app pod was on `devops`.

Do not make broad network changes yet. Only inspect.

Run safe checks such as:

```bash
kubectl -n guacamole get svc,endpoints,endpointslices -o wide
kubectl -n guacamole describe svc guacamole-postgresql || true
kubectl -n guacamole describe pod guacamole-postgresql-0 || true
kubectl -n guacamole describe deploy guacamole-guacamole || true
kubectl get nodes --show-labels
kubectl get pods -n calico-system -o wide || true
kubectl get pods -n kube-system -o wide | grep -E 'calico|coredns|kube-proxy' || true
```

If useful and safe, launch a temporary diagnostic pod to test DNS and service connectivity from a worker node and/or devops node, then delete it afterward. Do not leave debug pods running.

## Stabilize Helm release

The target is:

```text
helm -n guacamole status guacamole
```

should report a healthy deployed release, not `pending-install`.

Preferred approach:

1. Preserve the working PostgreSQL PVC and database.
2. Avoid deleting the PVC.
3. Update Helm values so the needed scheduling behavior is represented in `helm/guacamole/values-local.yaml`, not only as a manual live patch.
4. Run a safe Helm upgrade/reconcile.
5. Confirm the app remains healthy.

If the chart supports `nodeSelector`, `affinity`, or `tolerations`, add the minimum needed values to keep Guacamole on worker nodes or specifically on `worker-01` as a temporary workaround.

Prefer a worker-node selector over hard-pinning to one hostname if the cluster labels support it. If they do not, use a clearly documented temporary hostname pin with a TODO explaining why.

## Repo updates requested

Update docs/scripts as needed:

```text
helm/guacamole/values-local.yaml
docs/guacamole/GUACAMOLE_PLAN.md
scripts/guacamole/test-guacamole.sh
```

Add notes explaining:

- why scheduling was constrained
- how to verify Helm release state
- how to remove the scheduling workaround later after cluster networking is fixed

## Validation commands

After changes, run:

```bash
bash scripts/guacamole/test-guacamole.sh
helm -n guacamole status guacamole || true
kubectl -n guacamole rollout status deploy/guacamole-guacamole --timeout=180s
kubectl -n guacamole get pods,pvc,svc -o wide
```

Run a short port-forward smoke test if safe:

```bash
kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80 >/tmp/guacamole-port-forward.log 2>&1 &
PF_PID=$!
sleep 5
curl -I http://127.0.0.1:8080/ || true
kill "$PF_PID" || true
cat /tmp/guacamole-port-forward.log
```

## Do not do yet

- Do not configure Cloudflare Tunnel.
- Do not enable ingress.
- Do not expose Guacamole publicly.
- Do not delete the PostgreSQL PVC.
- Do not print secrets.
- Do not reset the Guacamole database unless explicitly approved.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0004-stabilize-guacamole-helm-release-response.md
```

## Response must include

- Helm status before and after
- Whether Helm is now `deployed`
- Whether a manual patch was replaced by Helm values
- Which values were changed
- Current pod placement
- PVC status
- Service name and port-forward command
- Whether the short HTTP smoke test passed
- Any likely root cause for the devops-to-PostgreSQL routing issue
- Files changed
- Commit SHA
- Push result
- Exact next recommended prompt/action

## Safety rules

If you cannot safely fix Helm status without risking the running deployment or PVC, stop and write a blocker response with the safest manual recovery plan.
