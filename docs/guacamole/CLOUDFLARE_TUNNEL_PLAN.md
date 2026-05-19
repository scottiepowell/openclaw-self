# Guacamole Cloudflare Tunnel Plan

## Goal

Expose Guacamole later through Cloudflare Tunnel without changing the internal-first install.

## Keep from phase 1

- `Service.type: ClusterIP`
- PostgreSQL persistence on NFS
- No public ingress yet

## Future tunnel shape

- Create a Cloudflare Tunnel and route a hostname to the Guacamole service
- Prefer a private origin path to the in-cluster service
- Keep Guacamole auth local until SSO is explicitly planned

## Suggested tunnel inputs

- Hostname: a later `guacamole.<domain>` record
- Origin service: `http://guacamole:80`
- TLS: terminate at Cloudflare
- Access policy: restrict to Scott / allowed users before opening broadly

## Migration checklist

1. Confirm the local install is healthy
2. Decide on hostname and tunnel name
3. Add Cloudflare secrets/config outside this repo
4. Enable tunnel routing
5. Re-check login and upload/download flows

## Not in scope yet

- Cloudflare deployment manifests
- DNS changes
- Public exposure

