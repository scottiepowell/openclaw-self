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

- Keep the Kubernetes service as `ClusterIP`
- Do not enable ingress unless explicitly approved
- Do not expose Guacamole through Cloudflare until Cloudflare Access is configured
- Cloudflare Access must protect the Guacamole hostname before the request reaches the app

## Cluster note

- Guacamole and PostgreSQL are temporarily pinned to `worker-01`
- The underlying issue is that the `devops` node currently cannot route to the PostgreSQL pod/service network
- Remove the pin only after that routing problem is fixed and the release is revalidated

## Quick sanity check

- Confirm the app still loads locally after the password change
- Confirm the new admin can log in
- Confirm `guacadmin` is no longer the day-to-day account
