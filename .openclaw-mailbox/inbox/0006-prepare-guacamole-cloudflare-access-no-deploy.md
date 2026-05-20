# Mailbox Task 0006 — Prepare Guacamole Cloudflare Access, No Deploy

## Objective

Prepare the repository for exposing Guacamole through Cloudflare Tunnel and Cloudflare Access later, but do **not** deploy the tunnel yet and do **not** expose Guacamole publicly.

This task is documentation, example configuration, and readiness validation only.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Current known state

From Task 0005:

- Helm release: `deployed`
- Guacamole app: healthy
- PostgreSQL: healthy
- PVC: `Bound` on `nfs-client`
- Service: `svc/guacamole-guacamole`
- Service type: `ClusterIP`
- Ingress: none present
- Backup and hardening scripts exist
- Security docs exist
- Deployment is still temporarily pinned to `worker-01` due to the `devops` node routing issue

## Critical manual security gate

Before real public exposure, Scott must complete these UI steps:

1. Port-forward:

   ```bash
   kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
   ```

2. Open:

   ```text
   http://127.0.0.1:8080/
   ```

3. Log in with the initial chart credentials only if still needed:

   ```text
   guacadmin / guacadmin
   ```

4. Change the `guacadmin` password immediately.
5. Create a named admin user for Scott.
6. Verify the named admin can log in.
7. Disable/delete the default `guacadmin` account if practical.

For this task, do **not** try to automate UI login or credential changes.
Instead, document the gate clearly and add a readiness check reminder.

## Required checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
git status --short
git branch --show-current
helm -n guacamole status guacamole
kubectl -n guacamole get pods,pvc,svc -o wide
kubectl -n guacamole get ingress || true
bash scripts/guacamole/verify-guacamole-security.sh || true
```

## Work requested

Create or update repository files to prepare for Cloudflare Tunnel and Cloudflare Access.

Suggested files:

```text
docs/guacamole/CLOUDFLARE_ACCESS_SETUP.md
docs/guacamole/CLOUDFLARE_TUNNEL_PLAN.md
helm/cloudflare-tunnel/values-guacamole.example.yaml
scripts/guacamole/verify-cloudflare-readiness.sh
```

Create directories as needed.

## Cloudflare documentation requirements

The docs should explain the intended path:

```text
Internet
  -> Cloudflare Access policy
  -> Cloudflare Tunnel
  -> cloudflared pod in Kubernetes
  -> svc/guacamole-guacamole.guacamole.svc.cluster.local:80
  -> Guacamole app
```

Document that Cloudflare Access should be configured before public DNS routes traffic to Guacamole.

Include placeholders for:

- public hostname, for example `guacamole.example.com`
- Cloudflare account ID
- tunnel name
- tunnel ID
- Kubernetes secret name for tunnel credentials
- Access policy allowed emails or identity provider group

Do not include real tokens or secrets.

## Example Helm values requirements

If you create `helm/cloudflare-tunnel/values-guacamole.example.yaml`, make it an example only.

It should include placeholders, not secrets.

It should route to the internal service, something like:

```text
http://guacamole-guacamole.guacamole.svc.cluster.local:80
```

If the exact chart schema is uncertain, clearly mark the file as a draft/example and document which chart it targets.

## Readiness script requirements

If you create `scripts/guacamole/verify-cloudflare-readiness.sh`, it should be non-invasive and should check:

- Guacamole Helm release is deployed
- Guacamole service exists
- Service type is `ClusterIP`
- No Kubernetes ingress exists for Guacamole
- Pods are ready
- PVC is bound
- Security checklist file exists
- Backup/restore guide exists
- Remind Scott to confirm default credentials were changed manually
- Remind Scott to configure Cloudflare Access before tunnel deployment

The script must not print secrets.
The script must not create Cloudflare resources.
The script must not deploy `cloudflared`.

## Validation commands

Run:

```bash
bash -n scripts/guacamole/verify-cloudflare-readiness.sh
bash scripts/guacamole/verify-cloudflare-readiness.sh || true
```

Also run existing checks:

```bash
bash scripts/guacamole/verify-guacamole-security.sh || true
bash scripts/guacamole/test-guacamole.sh
```

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0006-prepare-guacamole-cloudflare-access-no-deploy-response.md
```

## Response must include

- Current Helm status
- Current service type
- Whether any ingress exists
- Files created or changed
- Whether scripts were made executable
- Validation command results
- Exact manual Cloudflare prerequisites Scott must gather
- Exact manual Guacamole UI security gate Scott must confirm
- Recommended next prompt/action
- Commit SHA
- Push result

## Do not do yet

- Do not deploy Cloudflare Tunnel.
- Do not create Cloudflare DNS routes.
- Do not enable Kubernetes ingress.
- Do not expose Guacamole publicly.
- Do not print secrets or tokens.
- Do not change Guacamole database contents.
- Do not delete or recreate the PostgreSQL PVC.

## Safety rule

If anything suggests Guacamole is not healthy or no longer internal-only, stop after writing docs/checks and report the blocker clearly in the outbox response.
