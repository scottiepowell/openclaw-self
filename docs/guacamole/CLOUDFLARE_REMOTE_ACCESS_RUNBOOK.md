# Guacamole Cloudflare Remote Access Runbook

This is the final operator checklist before deploying Cloudflare Tunnel.
It is scaffolding only.

## Target path

```text
Browser
  -> Cloudflare Tunnel public hostname
  -> cloudflared pod in Kubernetes
  -> Guacamole login + TOTP
```

## Operator sequence

1. Confirm Guacamole local or LAN login works.
2. Confirm default credentials are changed or disabled.
3. In Cloudflare Zero Trust, create the tunnel only; Access is optional later.
4. Create a remotely managed Cloudflare Tunnel named something like:

   ```text
   openclaw-guacamole
   ```

6. Copy the tunnel token locally, but do not save it into Git.
7. Create the Kubernetes namespace and secret manually:

   ```bash
   kubectl create namespace cloudflare
   kubectl -n cloudflare create secret generic cloudflared-guacamole-token \
     --from-literal=token='PASTE_REAL_TOKEN_HERE'
   ```

8. Tell OpenClaw only that the secret exists; do not send the token through Git or Discord.
8. Only after the secret exists, run the future deploy task.

## Manual prerequisites to gather

- Public hostname, for example `guacamole.example.com`
- Cloudflare account ID
- Tunnel name, for example `openclaw-guacamole`
- Tunnel ID
- Kubernetes secret name, `cloudflared-guacamole-token`
- Kubernetes namespace, `cloudflare`
- Optional future Access policy allowed emails or identity provider group
- Origin service target is the Guacamole ClusterIP service:

  ```text
  http://guacamole-guacamole.guacamole.svc.cluster.local:80
  ```

## Secretless repo scaffolding

- Live Helm values: `helm/cloudflare-tunnel/values-guacamole.yaml`
- Example Helm values: `helm/cloudflare-tunnel/values-guacamole.example.yaml`
- Example tunnel secret helper: `scripts/guacamole/create-cloudflare-tunnel-secret.example.sh`
- Deploy wrapper: `scripts/guacamole/deploy-cloudflare-tunnel.sh`
- Uninstall wrapper: `scripts/guacamole/uninstall-cloudflare-tunnel.sh`
- Readiness check: `scripts/guacamole/verify-cloudflare-readiness.sh`
- Origin smoke test: `scripts/guacamole/test-cloudflare-origin.sh`

## Hard stop rules

- Do not deploy Cloudflare Tunnel yet.
- Do not create Cloudflare DNS routes yet.
- Do not enable Kubernetes ingress.
- Do not expose Guacamole publicly.
- Do not store the tunnel token in Git.

## Notes

- Cloudflare Access is optional for this phase and can be added later as hardening.
- The Guacamole service should remain internal-first; the future tunnel should point at the ClusterIP service DNS name, not the NodePort.
- If the LAN NodePort exists, it is still separate from Cloudflare planning.
