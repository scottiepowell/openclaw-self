# Guacamole Cloudflare Remote Access Runbook

This is the final operator checklist before deploying Cloudflare Tunnel.
It is scaffolding only. Do not deploy the tunnel yet.

## Target path

```text
Browser
  -> Cloudflare Tunnel public hostname
  -> cloudflared pod in Kubernetes
  -> http://guacamole-guacamole.guacamole.svc.cluster.local:80
  -> Guacamole login + TOTP
```

## Operator sequence

1. Confirm Guacamole local or LAN login works.
2. Confirm default credentials are changed or disabled.
3. In Cloudflare Zero Trust, decide whether Access is needed. It is optional for this phase.
4. Create a remotely managed Cloudflare Tunnel named something like:

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
8. Only after the secret exists, run the future deploy task.

## Manual prerequisites to gather

- Public hostname, for example `guacamole.example.com`
- Cloudflare account ID
- Tunnel name, for example `openclaw-guacamole`
- Tunnel ID
- Kubernetes secret name, for example `cloudflare-tunnel-token`
- Kubernetes namespace, for example `cloudflare-tunnel`
- Optional future Access policy allowed emails or identity provider group
- Origin service target:

  ```text
  http://guacamole-guacamole.guacamole.svc.cluster.local:80
  ```

## Secretless repo scaffolding

- Example Helm values: `helm/cloudflare-tunnel/values-guacamole.example.yaml`
- Example tunnel secret helper: `scripts/guacamole/create-cloudflare-tunnel-secret.example.sh`
- Readiness check: `scripts/guacamole/verify-cloudflare-readiness.sh`
- Origin smoke test: `scripts/guacamole/test-cloudflare-origin.sh`
- Example deploy wrapper: `scripts/guacamole/deploy-cloudflare-tunnel.example.sh`

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
