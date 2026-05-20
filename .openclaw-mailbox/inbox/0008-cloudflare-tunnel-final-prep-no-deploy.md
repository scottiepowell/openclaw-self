# Mailbox Task 0008 — Cloudflare Tunnel Final Prep, No Deploy

## Objective

Do the final repository prep needed before deploying Cloudflare Tunnel for Guacamole remote access.

This task should create the final secretless scaffolding, validation scripts, and operator instructions, but it must **not** deploy Cloudflare Tunnel and must **not** expose Guacamole publicly yet.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Current known state

- Guacamole is deployed by Helm in namespace `guacamole`.
- Service is `svc/guacamole-guacamole`.
- Internal origin service for Cloudflare should be:

  ```text
  http://guacamole-guacamole.guacamole.svc.cluster.local:80
  ```

- PostgreSQL PVC is bound on NFS-backed storage.
- App and PostgreSQL are temporarily pinned to `worker-01` because the `devops` node has a routing issue.
- There is or may soon be a LAN-only NodePort task in progress; do not depend on NodePort for Cloudflare.
- Cloudflare should point to the internal ClusterIP service DNS name, not to the NodePort.
- Cloudflare Tunnel and Ingress must remain disabled until Scott explicitly approves deployment.

## Security gates before real deployment

Do not deploy Cloudflare until Scott confirms all of these:

1. Default `guacadmin / guacadmin` credentials have been changed or disabled.
2. A named admin user exists and can log in.
3. Cloudflare Access policy has been created and protects the hostname.
4. Cloudflare Tunnel token has been created in Cloudflare.
5. Tunnel token has been stored directly in Kubernetes as a Secret, not committed to Git.

## Required checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
git status --short
git branch --show-current
helm -n guacamole status guacamole || true
kubectl -n guacamole get pods,pvc,svc -o wide
kubectl -n guacamole get ingress || true
kubectl get ns
```

Also check what Cloudflare prep files already exist:

```bash
find docs helm scripts k8s -maxdepth 4 -type f | sort | grep -Ei 'cloudflare|tunnel|guacamole' || true
```

## Work requested

Create or update the final pre-deployment scaffold for Cloudflare Tunnel.

Suggested files:

```text
docs/guacamole/CLOUDFLARE_REMOTE_ACCESS_RUNBOOK.md
docs/guacamole/CLOUDFLARE_TUNNEL_PLAN.md
helm/cloudflare-tunnel/values-guacamole.example.yaml
scripts/guacamole/create-cloudflare-tunnel-secret.example.sh
scripts/guacamole/verify-cloudflare-readiness.sh
scripts/guacamole/test-cloudflare-origin.sh
scripts/guacamole/deploy-cloudflare-tunnel.example.sh
```

Also update `.gitignore` if needed to prevent secret-containing local files from being committed.

## Required `.gitignore` protections

Ensure `.gitignore` includes patterns like:

```gitignore
# Cloudflare / tunnel local secrets
.env.cloudflare
*.cloudflare-token
*tunnel-token*
helm/cloudflare-tunnel/values-guacamole.local.yaml
helm/cloudflare-tunnel/*.secret.yaml
```

Do not remove existing ignore rules.

## Runbook requirements

The runbook should explain the exact operator sequence for Scott:

1. Confirm Guacamole local/LAN login works.
2. Confirm default credentials are changed or disabled.
3. In Cloudflare Zero Trust, create an Access application for the Guacamole hostname.
4. Create an Access policy allowing only Scott's email or chosen identity group.
5. Create a remotely managed Cloudflare Tunnel named something like:

   ```text
   openclaw-guacamole
   ```

6. Copy the tunnel token locally, but do not save it into Git.
7. Create the Kubernetes namespace and secret manually:

   ```bash
   kubectl create namespace cloudflare-tunnel
   kubectl -n cloudflare-tunnel create secret generic cloudflare-tunnel-token \
     --from-literal=TUNNEL_TOKEN='PASTE_REAL_TOKEN_HERE'
   ```

8. Tell OpenClaw only that the secret exists; do not send the token through Git or Discord.
9. Only after the secret exists and Access is protecting the hostname, run the future deploy task.

## Example values requirements

The example Helm values should be explicitly marked as example-only and should contain placeholders for:

- hostname, for example `guacamole.example.com`
- tunnel name, for example `openclaw-guacamole`
- secret name, for example `cloudflare-tunnel-token`
- namespace, for example `cloudflare-tunnel`
- origin service:

  ```text
  http://guacamole-guacamole.guacamole.svc.cluster.local:80
  ```

If the exact Cloudflare Helm chart schema is uncertain, include comments stating that the file must be checked against the chart before deployment.

## Script requirements

### `create-cloudflare-tunnel-secret.example.sh`

This must be an example/helper only. It may prompt for a token or require `TUNNEL_TOKEN` in the environment, but it must not contain a real token.

It should:

- create namespace `cloudflare-tunnel` if missing
- create or update secret `cloudflare-tunnel-token`
- avoid echoing the token
- print only safe status messages

### `verify-cloudflare-readiness.sh`

This should be non-invasive and should check:

- Guacamole Helm release is deployed
- Guacamole service exists
- origin service DNS target is documented
- service type remains safe
- no Guacamole ingress exists
- Cloudflare namespace exists or not
- Cloudflare tunnel secret exists or not
- Access/credential gates are manual and must be confirmed by Scott

It must not print secret contents.

### `test-cloudflare-origin.sh`

This should test the internal origin path from inside the cluster, if possible.

Preferred approach:

- create a temporary curl pod in a safe namespace
- curl `http://guacamole-guacamole.guacamole.svc.cluster.local:80/`
- show HTTP status
- delete the temporary pod afterward

Do not leave debug pods running.

### `deploy-cloudflare-tunnel.example.sh`

This must be example-only or guarded so it cannot accidentally deploy without explicit variables/confirmation.

It should:

- check the secret exists
- check the example/local values file exists
- print the Helm command that would be used
- either require an explicit `CONFIRM_DEPLOY_CLOUDFLARE_TUNNEL=yes` or stay dry-run only

Do not perform a real deploy during this task.

## Validation commands

Run:

```bash
bash -n scripts/guacamole/create-cloudflare-tunnel-secret.example.sh
bash -n scripts/guacamole/verify-cloudflare-readiness.sh
bash -n scripts/guacamole/test-cloudflare-origin.sh
bash -n scripts/guacamole/deploy-cloudflare-tunnel.example.sh
bash scripts/guacamole/verify-cloudflare-readiness.sh || true
bash scripts/guacamole/test-cloudflare-origin.sh || true
```

Do not create real Cloudflare resources.
Do not create real DNS routes.
Do not deploy `cloudflared`.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0008-cloudflare-tunnel-final-prep-no-deploy-response.md
```

## Response must include

- Current Guacamole Helm status
- Current Guacamole service type
- Whether any Guacamole ingress exists
- Files created or changed
- Whether `.gitignore` was updated
- Whether scripts were made executable
- Validation command results
- Whether the Cloudflare namespace exists
- Whether the Cloudflare tunnel secret exists, without printing its value
- Exact data Scott still needs from Cloudflare
- Exact manual steps Scott must do before the deploy task
- Recommended next prompt/action
- Commit SHA
- Push result

## Do not do yet

- Do not deploy Cloudflare Tunnel.
- Do not create Cloudflare DNS routes.
- Do not enable Kubernetes ingress.
- Do not expose Guacamole publicly.
- Do not print tokens, passwords, or Kubernetes secret values.
- Do not change Guacamole database contents.
- Do not delete or recreate the PostgreSQL PVC.

## Safety rule

If any readiness check shows Guacamole is unhealthy or publicly exposed already, stop and write a blocker response explaining what must be fixed first.
