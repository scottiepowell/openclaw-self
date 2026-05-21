# Mailbox Task 0011 — Deploy Cloudflare Tunnel for Guacamole

## Objective

Deploy Cloudflare Tunnel-only remote access for Guacamole now that Guacamole TOTP is confirmed working.

Final desired path:

```text
Browser -> Cloudflare Tunnel public hostname -> cloudflared in Kubernetes -> Guacamole ClusterIP service -> Guacamole login + Guacamole TOTP
```

Do not configure Cloudflare Access in this task.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Confirmed prerequisite

Scott confirmed:

- Guacamole TOTP is working.
- He logged out and back in successfully with TOTP.
- Cloudflare Access is intentionally not required for this phase.
- Tunnel-only plus Guacamole TOTP is the current target.

## Required first checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
git status --short
git branch --show-current
git log --oneline -10
kubectl -n guacamole get pods,svc,pvc -o wide
helm -n guacamole status guacamole || true
kubectl -n guacamole logs deploy/guacamole-guacamole --tail=120 | grep -i -E 'totp|extension|guacamole|error|warn' || true
```

Confirm Guacamole target service:

```bash
kubectl -n guacamole get svc guacamole-guacamole -o wide
```

Expected internal service target:

```text
http://guacamole-guacamole.guacamole.svc.cluster.local:80
```

## Cloudflare information needed

Do not commit real secrets.

This deployment needs a Cloudflare Tunnel token stored as a Kubernetes Secret. Use this expected secret location:

```text
namespace: cloudflare
secret: cloudflared-guacamole-token
key: token
```

Check whether it already exists:

```bash
kubectl get namespace cloudflare || true
kubectl -n cloudflare get secret cloudflared-guacamole-token || true
```

If the secret does not exist, stop before deploying and write a response telling Scott to create it manually with:

```bash
kubectl create namespace cloudflare --dry-run=client -o yaml | kubectl apply -f -
kubectl -n cloudflare create secret generic cloudflared-guacamole-token --from-literal=token='PASTE_CLOUDFLARE_TUNNEL_TOKEN_HERE'
```

Do not ask Scott to commit the token.
Do not write the token to any repo file.
Do not print the token if it already exists.

## Cloudflare dashboard/manual prerequisite

If the token is missing, document that Scott needs to do this in Cloudflare first:

1. Cloudflare Zero Trust dashboard.
2. Networks / Tunnels.
3. Create a new tunnel for Guacamole.
4. Choose Docker/Kubernetes connector method that provides a token.
5. Configure public hostname, for example:

   ```text
   guac.example.com
   ```

6. Service target should point to the Kubernetes service through cloudflared config/Helm values:

   ```text
   http://guacamole-guacamole.guacamole.svc.cluster.local:80
   ```

Use placeholders in docs. Do not commit actual hostname unless already present in local repo config and clearly intended.

## Repo updates requested

Update or create Cloudflare Tunnel Helm scaffolding if needed:

```text
helm/cloudflare-tunnel/values-guacamole.yaml
helm/cloudflare-tunnel/values-guacamole.example.yaml
scripts/guacamole/deploy-cloudflare-tunnel.sh
scripts/guacamole/test-cloudflare-tunnel.sh
scripts/guacamole/uninstall-cloudflare-tunnel.sh
docs/guacamole/CLOUDFLARE_TUNNEL_PLAN.md
docs/guacamole/CLOUDFLARE_REMOTE_ACCESS_RUNBOOK.md
docs/guacamole/GUACAMOLE_SECURITY_CHECKLIST.md
```

Prefer the official Cloudflare Helm chart if already documented in the repo. If the repo already has a chart approach, use that.

Expected Helm repo if needed:

```bash
helm repo add cloudflare https://cloudflare.github.io/helm-charts || true
helm repo update
```

Do not commit secrets.

## Deployment rules

If the Kubernetes secret exists and the chart/values render cleanly, you are approved to deploy cloudflared for Guacamole.

Before deployment, run safe validation:

```bash
bash scripts/guacamole/verify-cloudflare-readiness.sh || true
helm template guacamole-tunnel cloudflare/cloudflare-tunnel -n cloudflare -f helm/cloudflare-tunnel/values-guacamole.yaml >/tmp/guacamole-cloudflare-tunnel-rendered.yaml
```

If render fails, stop and write the blocker response.

If render succeeds and token secret exists, deploy:

```bash
bash scripts/guacamole/deploy-cloudflare-tunnel.sh
```

If that script does not exist yet, create it first and make it safe/idempotent.

## Post-deploy verification

Run and summarize:

```bash
kubectl -n cloudflare get pods,deploy,secret -o wide
helm -n cloudflare list
helm -n cloudflare status guacamole-tunnel || true
kubectl -n cloudflare logs deploy/guacamole-tunnel --tail=120 || true
kubectl -n guacamole get svc,pods -o wide
```

Do not print secret values.

## Browser verification

If the public hostname is known from local config/docs, report the URL Scott should test.

If hostname is not known, write that Scott must test the hostname configured in Cloudflare for this tunnel.

Expected behavior:

1. Public hostname loads Guacamole.
2. Guacamole login page appears.
3. User logs in with Guacamole credentials.
4. TOTP prompt appears and succeeds.

## Failure handling

If Cloudflare tunnel pod is running but public hostname fails:

- Capture cloudflared logs.
- Check hostname/service target mismatch.
- Check DNS route in Cloudflare dashboard.
- Do not switch to Cloudflare Access.
- Do not expose Guacamole via NodePort as a workaround unless Scott explicitly asks.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0011-deploy-cloudflare-tunnel-for-guacamole-response.md
```

## Response must include

- Guacamole/TOTP health status.
- Whether `cloudflared-guacamole-token` secret exists.
- Whether Cloudflare Tunnel was deployed or blocked waiting for token.
- Files changed.
- Helm chart/release used.
- Namespace used.
- Pod/deployment status.
- Cloudflared logs summary.
- Public hostname to test, if known.
- Exact next command/action for Scott.
- Commit SHA and push result.

## Safety rules

- Do not commit secrets.
- Do not print tunnel token.
- Do not configure Cloudflare Access.
- Do not disable Guacamole TOTP.
- Do not delete Guacamole PVCs.
- Do not expose Guacamole using NodePort or LoadBalancer unless Scott explicitly asks.
- If blocked due to missing token or hostname, write a clear response and stop.
