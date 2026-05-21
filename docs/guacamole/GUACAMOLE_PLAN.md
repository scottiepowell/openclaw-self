# Guacamole Helm Plan

## What I inspected

- Repo layout under `/home/scott/projects/openclaw-self`
- Cluster state:
  - `kubectl get nodes -o wide`
  - `kubectl get storageclass`
  - `kubectl get pv,pvc -A`
  - `helm list -A`
- HelmForge Guacamole chart values and chart metadata

## Recommended chart

- `helmforge/guacamole` (`version: 1.4.7`, app `1.6.0`)
- Web app and `guacd` run together; PostgreSQL is a bundled subchart
- The chart keeps the app internal by default and supports later ingress enablement

## Cluster facts

- Nodes: 1 control/infra + 2 workers
- StorageClasses available:
  - `local-path`
  - `nfs-client`
  - `nfs-static`
- For this install, use `nfs-client` for PostgreSQL persistence unless the cluster owner wants a different NFS class
- Temporary scheduling workaround:
  - Pin Guacamole and PostgreSQL to `kubernetes.io/hostname=worker-01`
  - Reason: the `devops` node currently returns `No route to host` when a pod tries to reach the PostgreSQL service/pod network
  - Remove this after the cluster routing issue is fixed and re-run `helm upgrade`
- Init hook workaround:
  - `initDb.enabled` is currently off in local values because the chart's post-install schema job does not expose node scheduling controls and was repeatedly landing on `devops`
  - The schema is already initialized in this cluster
  - Re-enable only for a fresh bootstrap or after the chart adds scheduling controls for the hook

## Local phase

- Namespace: `guacamole`
- Service: `ClusterIP`
- Ingress: disabled
- PostgreSQL: enabled
- PostgreSQL persistence: NFS-backed PVC
- Cloudflare Tunnel: not deployed yet
- TOTP: enabled in Helm values; enroll from the Guacamole UI after first login

## LAN access phase

- Additional NodePort service: `k8s/guacamole/guacamole-nodeport-service.yaml`
- NodePort: `32080`
- LAN URL shape:

  ```text
  http://<worker-01-LAN-IP>:32080/
  ```

- This is LAN-only access, not public exposure.
- Keep Cloudflare and ingress disabled for now.
- If access fails from another LAN machine, check node firewall, kube-proxy, and routing.

## Security hardening phase

- `docs/guacamole/GUACAMOLE_SECURITY_CHECKLIST.md`
- `docs/guacamole/GUACAMOLE_BACKUP_RESTORE.md`
- `scripts/guacamole/backup-guacamole-db.sh`
- `scripts/guacamole/verify-guacamole-security.sh`

## Suggested values

- `helm/guacamole/values-local.yaml`
  - internal-only service
  - PostgreSQL subchart enabled
  - `postgresql.standalone.persistence.storageClass: nfs-client`
- `helm/guacamole/values-cloudflare.yaml`
  - future-facing ingress/tunnel notes
  - no public exposure in the first phase

## Install flow

1. Validate chart rendering:
   - `helm template ... -f helm/guacamole/values-local.yaml`
2. Install into `guacamole` namespace
3. Port-forward the service for first login/testing
4. Change the default Guacamole admin password before any connection testing
5. Create a named admin user before any public exposure work
6. Use the LAN NodePort only after the default credentials are changed or disabled

## Port-forward test

```bash
kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
```

Then open `http://127.0.0.1:8080/`.

## LAN test

- NodePort service: `guacamole-guacamole-nodeport`
- Suggested URL:

  ```text
  http://<worker-01-LAN-IP>:32080/
  ```

## Release health checks

- Confirm Helm is healthy:
  - `helm -n guacamole status guacamole`
- Confirm scheduling pin is still present in rendered output:
  - `bash scripts/guacamole/test-guacamole.sh`
- Confirm the live deployment is still on `worker-01`:
  - `kubectl -n guacamole describe deploy guacamole-guacamole`
- Confirm the non-invasive security checks pass:
  - `bash scripts/guacamole/verify-guacamole-security.sh`
- Show the LAN access summary:
  - `bash scripts/guacamole/show-guacamole-access.sh`

## Rollback

```bash
helm -n guacamole history guacamole
helm -n guacamole rollback guacamole <REVISION>
```

## Uninstall

```bash
scripts/guacamole/uninstall-guacamole.sh
```

## Notes

- Keep PostgreSQL on NFS-backed storage.
- Do not expose ingress until the Cloudflare Tunnel phase is ready.
- Change the default Guacamole admin password immediately after first login.
