# Guacamole Cloudflare Tunnel Plan

## Goal

Prepare the final secretless scaffolding for Cloudflare Tunnel without deploying anything yet.

## Keep from phase 1

- `Service.type: ClusterIP`
- PostgreSQL persistence on NFS
- No public ingress
- No tunnel deployment yet

## Intended path

```text
Browser
  -> Cloudflare Tunnel public hostname
  -> cloudflared pod in Kubernetes
  -> Guacamole login + TOTP
```

## Access is optional later

Cloudflare Access is an optional future hardening layer in front of the hostname.
It is **not required** for the current tunnel-only phase.
Hostname routing is configured in the Cloudflare dashboard; this repo only runs the tunnel connector.

## Suggested inputs

- Public hostname: `guacamole.example.com`
- Cloudflare account ID: placeholder only
- Tunnel name: placeholder only
- Tunnel ID: placeholder only
- Kubernetes secret name for tunnel credentials: `cloudflared-guacamole-token`
- Optional future Access policy allowed emails or identity provider group: placeholder only
- Origin service:

  ```text
  http://guacamole-guacamole.guacamole.svc.cluster.local:80
  ```

## Final prep scaffolding

- Runbook: `docs/guacamole/CLOUDFLARE_REMOTE_ACCESS_RUNBOOK.md`
- Live Helm values: `helm/cloudflare-tunnel/values-guacamole.yaml`
- Example Helm values: `helm/cloudflare-tunnel/values-guacamole.example.yaml`
- Secret helper: `scripts/guacamole/create-cloudflare-tunnel-secret.example.sh`
- Readiness check: `scripts/guacamole/verify-cloudflare-readiness.sh`
- Origin smoke test: `scripts/guacamole/test-cloudflare-origin.sh`
- Deploy wrapper: `scripts/guacamole/deploy-cloudflare-tunnel.sh`
- Uninstall wrapper: `scripts/guacamole/uninstall-cloudflare-tunnel.sh`

## Migration checklist

1. Confirm the local install is healthy.
2. Confirm Guacamole TOTP works locally or over LAN.
3. Decide on hostname, tunnel name, and tunnel ID.
4. Gather Cloudflare account and tunnel token details.
5. Create Cloudflare Tunnel config outside this repo.
6. Add Cloudflare Access later only if Scott wants an identity gate.
7. Re-check login and upload/download flows.
8. Keep the token in a Kubernetes Secret only; do not commit it.

## Not in scope yet

- Cloudflare deployment manifests
- DNS changes
- Public exposure
- Cloudflare Access policies for this phase
