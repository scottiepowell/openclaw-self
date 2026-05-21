# Mailbox Task 0009 — Enable Guacamole TOTP and Plan Cloudflare Access

## Objective

Make Guacamole security hardening code-driven in the repo before public exposure.

Target final state:

1. Guacamole built-in TOTP enabled while still local/LAN only.
2. Cloudflare Access configured in front of Guacamole.
3. Final public path protected by both Cloudflare Access MFA and Guacamole TOTP.

Important distinction:

- Cloudflare Tunnel provides private connectivity from Cloudflare to the Kubernetes service.
- Cloudflare Access provides the identity/authentication policy in front of that tunnel hostname.
- We eventually need both, but this task should focus on enabling Guacamole TOTP and documenting/preparing Cloudflare Access/Tunnel cleanly.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Current context

- Guacamole is installed in Kubernetes namespace `guacamole`.
- Access via port-forward is now working from LAN/controller after firewall/port-forward troubleshooting.
- Do not expose Guacamole publicly yet.
- Keep all changes reproducible through Helm values and scripts/docs in this repo.
- Use the mailbox workflow: write your response to outbox and commit/push it.

## Required first checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
git status --short
git branch --show-current
git log --oneline -8
kubectl -n guacamole get pods,svc,pvc -o wide
helm -n guacamole status guacamole || true
helm -n guacamole get values guacamole || true
helm -n guacamole get manifest guacamole | grep -i -E 'totp|extension|guacamole-home|GUACAMOLE' | head -120 || true
```

## Investigate chart support for TOTP

Inspect the current Guacamole chart values and docs locally through Helm:

```bash
helm show values helmforge/guacamole | grep -i -n -E 'totp|extension|extensions|extraEnv|env|volume|init|guacamole-home' -C 4 || true
helm show chart helmforge/guacamole
```

Determine whether the chart supports Guacamole TOTP directly with a values block such as:

```yaml
totp:
  enabled: true
```

If the chart supports it, update the repo values to enable it.

If it does not support it directly, propose the safest chart-compatible way to add the official Guacamole TOTP extension without making a fragile manual live patch. Do not force a risky implementation if the chart does not clearly support it.

## Repo updates requested

Update these files as appropriate:

```text
helm/guacamole/values-local.yaml
helm/guacamole/values-cloudflare.yaml
docs/guacamole/GUACAMOLE_PLAN.md
docs/guacamole/CLOUDFLARE_TUNNEL_PLAN.md
scripts/guacamole/test-guacamole.sh
```

Add or update documentation to clearly explain:

- Cloudflare Tunnel vs Cloudflare Access.
- Cloudflare Tunnel is transport/connectivity.
- Cloudflare Access is identity/MFA policy.
- Desired final hostname flow:

  ```text
  user browser -> Cloudflare Access MFA -> Cloudflare Tunnel -> guacamole service -> Guacamole login + TOTP
  ```

- Guacamole must remain internal until Access is configured.
- Default `guacadmin / guacadmin` must be changed before public exposure.

## Deployment scope

You are approved to apply a Helm upgrade only if the TOTP enablement is clearly represented in Helm values and the chart supports it cleanly.

Before upgrade, run:

```bash
bash scripts/guacamole/test-guacamole.sh
helm template guacamole helmforge/guacamole -n guacamole -f helm/guacamole/values-local.yaml >/tmp/guacamole-totp-rendered.yaml
```

If the render passes and the change is low-risk, run:

```bash
helm upgrade guacamole helmforge/guacamole -n guacamole -f helm/guacamole/values-local.yaml --wait --timeout 10m
```

If the chart support is uncertain, do not upgrade. Commit docs/values notes and write a blocker/recommendation response.

## Post-upgrade verification, if upgrade is run

Run:

```bash
helm -n guacamole status guacamole || true
kubectl -n guacamole rollout status deploy/guacamole-guacamole --timeout=180s
kubectl -n guacamole get pods,svc,pvc -o wide
kubectl -n guacamole logs deploy/guacamole-guacamole --tail=120 | grep -i -E 'totp|extension|guacamole|error|warn' || true
```

Then do a short port-forward smoke test if safe:

```bash
kubectl -n guacamole port-forward --address 0.0.0.0 svc/guacamole-guacamole 8080:80 >/tmp/guacamole-pf-totp.log 2>&1 &
PF_PID=$!
sleep 5
curl -I http://127.0.0.1:8080/ || true
kill "$PF_PID" || true
cat /tmp/guacamole-pf-totp.log
```

Do not leave duplicate port-forwards running.

## Cloudflare Access preparation

Do not deploy Cloudflare Tunnel in this task unless it is already part of the repo and explicitly safe as a no-public-exposure dry run.

Prepare docs/values for a later task that will configure:

- Cloudflare Tunnel deployment in Kubernetes.
- A public hostname such as `guac.<Scott's domain>` as a placeholder/TODO.
- Cloudflare Access application/policy requiring MFA.
- Tunnel service target pointing to the internal Kubernetes service, likely:

  ```text
  http://guacamole-guacamole.guacamole.svc.cluster.local:80
  ```

Use placeholders for domain, account ID, tunnel token/secret, and allowed emails/groups. Do not commit real secrets.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0009-enable-guacamole-totp-and-cloudflare-access-plan-response.md
```

## Response must include

- Whether the chart supports TOTP directly.
- What values/docs/scripts were changed.
- Whether a Helm upgrade was run.
- Helm status after any upgrade.
- Pod/PVC/service status.
- Whether the Guacamole UI still responds by port-forward.
- Any required manual steps for first TOTP enrollment.
- Cloudflare Tunnel vs Cloudflare Access explanation summary.
- Exact next recommended prompt/action.
- Commit SHA and push result.

## Safety rules

- Do not expose Guacamole publicly yet.
- Do not configure a live Cloudflare hostname yet.
- Do not commit secrets, tunnel tokens, API keys, private SSH keys, or passwords.
- Do not reset/delete the PostgreSQL PVC.
- Do not disable existing Guacamole access without confirming recovery path.
- If blocked, write a clear blocker response instead of forcing a risky change.
