# Guacamole Cloudflare Tunnel Plan

## Goal

Prepare the final secretless scaffolding for Cloudflare Tunnel and Cloudflare Access without deploying anything yet.

## Keep from phase 1

- `Service.type: ClusterIP`
- PostgreSQL persistence on NFS
- No public ingress
- No tunnel deployment yet

## Intended path

```text
Internet
  -> Cloudflare Access policy
  -> Cloudflare Tunnel
  -> cloudflared pod in Kubernetes
  -> svc/guacamole-guacamole.guacamole.svc.cluster.local:80
  -> Guacamole app
```

## Access before DNS

Cloudflare Access should be configured before any public DNS route points at Guacamole. The hostname should be protected before traffic can reach the app.

## Suggested inputs

- Public hostname: `guacamole.example.com`
- Cloudflare account ID: placeholder only
- Tunnel name: placeholder only
- Tunnel ID: placeholder only
- Kubernetes secret name for tunnel credentials: placeholder only
- Access policy allowed emails or identity provider group: placeholder only
- Origin service:

  ```text
  http://guacamole-guacamole.guacamole.svc.cluster.local:80
  ```

## Final prep scaffolding

- Runbook: `docs/guacamole/CLOUDFLARE_REMOTE_ACCESS_RUNBOOK.md`
- Example Helm values: `helm/cloudflare-tunnel/values-guacamole.example.yaml`
- Example secret helper: `scripts/guacamole/create-cloudflare-tunnel-secret.example.sh`
- Readiness check: `scripts/guacamole/verify-cloudflare-readiness.sh`
- Origin smoke test: `scripts/guacamole/test-cloudflare-origin.sh`
- Example deploy wrapper: `scripts/guacamole/deploy-cloudflare-tunnel.example.sh`

## Migration checklist

1. Confirm the local install is healthy.
2. Confirm the Guacamole UI security gate is complete.
3. Decide on hostname, tunnel name, and tunnel ID.
4. Gather Cloudflare account and Access policy details.
5. Create Cloudflare Tunnel and Access config outside this repo.
6. Enable tunnel routing only after Access is in front of the hostname.
7. Re-check login and upload/download flows.
8. Keep the token in a Kubernetes Secret only; do not commit it.

## Not in scope yet

- Cloudflare deployment manifests
- DNS changes
- Public exposure
