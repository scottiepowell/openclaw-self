# Guacamole Security Checklist

Use this before any Cloudflare Tunnel or public exposure work.

## Current local access

```bash
kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
```

Open:

```text
http://127.0.0.1:8080/
```

## LAN-only access path

- NodePort service: `guacamole-guacamole-nodeport`
- URL shape:

  ```text
  http://<worker-01-LAN-IP>:32080/
  ```

- This is LAN-only exposure, not Cloudflare and not public internet access.
- If access fails from another LAN machine, check node firewall, kube-proxy, and routing.
- Do not expose beyond the trusted LAN until `guacadmin / guacadmin` has been changed or disabled.

## First login

- Log in with the default chart credentials: `guacadmin / guacadmin`
- Change the `guacadmin` password immediately
- Do not create a test connection until the password has been changed

## Safer admin path

1. Log in as `guacadmin`
2. Create a named admin user for Scott
3. Verify the new admin can log in
4. Disable or delete `guacadmin` if practical for this deployment

## Exposure rules

- Keep the main Kubernetes service as `ClusterIP`
- Use the separate NodePort service only for trusted LAN access
- Do not enable ingress unless explicitly approved
- Do not expose Guacamole through Cloudflare until the tunnel token is installed and Scott approves public testing
- Cloudflare Access is optional future hardening, not a requirement for this phase
- Keep the LAN NodePort path trusted-only until the admin credentials are changed

## Cluster note

- Guacamole and PostgreSQL are temporarily pinned to `worker-01`
- The underlying issue is that the `devops` node currently cannot route to the PostgreSQL pod/service network
- Remove the pin only after that routing problem is fixed and the release is revalidated

## Quick sanity check

- Confirm the app still loads locally after the password change
- Confirm the new admin can log in
- Confirm `guacadmin` is no longer the day-to-day account
