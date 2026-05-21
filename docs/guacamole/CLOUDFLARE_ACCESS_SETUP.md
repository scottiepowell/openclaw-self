# Guacamole Cloudflare Access Setup

This is an optional future hardening guide for Guacamole. It is a planning guide only.

## Intended request path

```text
Internet
  -> Cloudflare Access policy
  -> Cloudflare Tunnel
  -> cloudflared pod in Kubernetes
  -> svc/guacamole-guacamole.guacamole.svc.cluster.local:80
  -> Guacamole app
```

## Required order if Scott chooses to add Access later

1. Keep Guacamole internal-only.
2. Confirm the local UI security gate is complete.
3. Decide whether Access is needed at all.
4. If used, configure Cloudflare Access before publishing DNS.
5. Do not enable Kubernetes ingress for this flow.

## Manual security gate

Before any public exposure, Scott must confirm these UI steps locally:

- Port-forward:

  ```bash
  kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
  ```

- Open:

  ```text
  http://127.0.0.1:8080/
  ```

- If still needed, log in with:

  ```text
  guacadmin / guacadmin
  ```

- Change the `guacadmin` password immediately.
- Create a named admin user for Scott.
- Verify the named admin can log in.
- Disable or delete `guacadmin` if practical.

## Cloudflare prerequisites to gather

- Public hostname, such as `guacamole.example.com`
- Cloudflare account ID
- Tunnel name
- Tunnel ID
- Kubernetes secret name for tunnel credentials
- Access policy allowed emails or identity provider group
- Desired origin service:

  ```text
  http://guacamole-guacamole.guacamole.svc.cluster.local:80
  ```

## Notes

- If enabled, Access should protect the hostname before the request reaches Guacamole.
- Do not publish DNS routes until Access is in place, if Access is being used.
- Do not copy real tokens or secrets into this repo.
