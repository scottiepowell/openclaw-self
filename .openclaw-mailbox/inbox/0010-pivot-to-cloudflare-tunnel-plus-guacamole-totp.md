# Mailbox Task 0010 — Pivot to Cloudflare Tunnel + Guacamole TOTP

## Objective

Supersede the prior Cloudflare Access-focused direction.

Scott wants the final Guacamole exposure plan to be:

```text
Browser -> Cloudflare Tunnel public hostname -> Kubernetes Guacamole service -> Guacamole login + Guacamole TOTP
```

Do **not** require Cloudflare Access for this phase.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Why this change

The prior task discussed Cloudflare Access as a front-door identity/MFA layer. Scott was not tracking Cloudflare Access as a separate product/service and does not want to add another possible cost or operational dependency right now.

The desired approach is simpler:

1. Enable Guacamole built-in TOTP while still local/LAN only.
2. Deploy or prepare Cloudflare Tunnel to route a public hostname to the internal Guacamole Kubernetes service.
3. Use Guacamole login + Guacamole TOTP as the app-level protection.

## Important distinction to document

Update docs to clarify:

- Cloudflare Tunnel is the connectivity path from Cloudflare to the private Kubernetes service.
- Cloudflare Access is an optional Zero Trust identity gate in front of a hostname.
- For now, Scott wants Tunnel only, not Access.
- Guacamole TOTP will provide the second factor inside the application.

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
helm -n guacamole get values guacamole || true
```

## TOTP work

If TOTP was already enabled by task 0009, verify and document it.

If TOTP has not been enabled yet, inspect chart support:

```bash
helm show values helmforge/guacamole | grep -i -n -E 'totp|extension|extensions|extraEnv|env|volume|init|guacamole-home' -C 4 || true
helm show chart helmforge/guacamole
```

If the chart clearly supports Guacamole TOTP through values, update:

```text
helm/guacamole/values-local.yaml
helm/guacamole/values-cloudflare.yaml
```

Then run render/test:

```bash
bash scripts/guacamole/test-guacamole.sh
helm template guacamole helmforge/guacamole -n guacamole -f helm/guacamole/values-local.yaml >/tmp/guacamole-totp-rendered.yaml
```

Only if the change is clear and safe, apply:

```bash
helm upgrade guacamole helmforge/guacamole -n guacamole -f helm/guacamole/values-local.yaml --wait --timeout 10m
```

If chart support is uncertain, do not force it. Write a blocker and recommendation.

## Cloudflare Tunnel work

Prepare the repo for a Cloudflare Tunnel-only deployment, but do not commit real secrets.

Update docs and values/templates as appropriate so the target service is clearly:

```text
http://guacamole-guacamole.guacamole.svc.cluster.local:80
```

Use placeholders/TODOs for:

```text
public hostname, for example guac.example.com
Cloudflare tunnel token or credentials secret
Cloudflare account/zone details
```

Do not configure Cloudflare Access in this task.
Do not create Cloudflare Access policies.
Do not imply Access is required.

## Repo updates requested

Update as appropriate:

```text
helm/guacamole/values-local.yaml
helm/guacamole/values-cloudflare.yaml
docs/guacamole/GUACAMOLE_PLAN.md
docs/guacamole/CLOUDFLARE_TUNNEL_PLAN.md
scripts/guacamole/test-guacamole.sh
```

If there is existing wording saying Cloudflare Access is required, change it to say optional/future hardening only.

## Post-change verification

Run:

```bash
bash scripts/guacamole/test-guacamole.sh
helm -n guacamole status guacamole || true
kubectl -n guacamole get pods,svc,pvc -o wide
kubectl -n guacamole logs deploy/guacamole-guacamole --tail=120 | grep -i -E 'totp|extension|guacamole|error|warn' || true
```

If a Helm upgrade was run, also run:

```bash
kubectl -n guacamole rollout status deploy/guacamole-guacamole --timeout=180s
```

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0010-pivot-to-cloudflare-tunnel-plus-guacamole-totp-response.md
```

## Response must include

- Whether task 0009 made any Access-related changes and whether they were corrected.
- Whether Cloudflare Access is now documented as optional, not required.
- Whether TOTP is enabled or blocked by chart limitations.
- What Helm values changed.
- Whether a Helm upgrade was run.
- Helm status and pod/PVC/service status.
- Target Cloudflare Tunnel service URL.
- Exact next recommended prompt/action.
- Files changed.
- Commit SHA and push result.

## Safety rules

- Do not commit secrets.
- Do not create Cloudflare Access policies.
- Do not expose Guacamole publicly until TOTP is working and Scott approves the tunnel deployment.
- Do not delete or reset PostgreSQL PVCs.
- Do not disable current working LAN/port-forward access.
