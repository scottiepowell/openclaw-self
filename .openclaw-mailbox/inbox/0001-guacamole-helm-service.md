# Mailbox Task 0001 — Guacamole Helm Service

## Objective

Add a Kubernetes/Helm planning scaffold for deploying Apache Guacamole in the `openclaw-self` repo.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Cluster context

- Homelab Kubernetes cluster
- 1 infra/control node
- 2 worker nodes
- Storage is NFS-backed, not local-path
- Helm is preferred for deployments
- Guacamole should work locally before Cloudflare exposure
- Cloudflare Tunnel is a later phase, not part of the first install

## Constraints

- Do not expose Guacamole publicly yet.
- Keep services internal/ClusterIP for now.
- Do not modify existing workloads unless explicitly needed.
- Do not assume the NFS `StorageClass` name; inspect it or document where to set it.
- PostgreSQL persistence must use the NFS-backed StorageClass.
- Prefer dry-runs and Helm template validation before install.
- Avoid destructive commands.

## Requested files

Create or update these files:

```text
docs/guacamole/GUACAMOLE_PLAN.md
docs/guacamole/CLOUDFLARE_TUNNEL_PLAN.md
helm/guacamole/values-local.yaml
helm/guacamole/values-cloudflare.yaml
scripts/guacamole/install-guacamole.sh
scripts/guacamole/test-guacamole.sh
scripts/guacamole/uninstall-guacamole.sh
```

## Work requested

1. Inspect the current repo layout.
2. Inspect Kubernetes state if available:

   ```bash
   kubectl get nodes -o wide
   kubectl get storageclass
   kubectl get pv,pvc -A
   helm list -A
   ```

3. Pick a reasonable Helm-based approach for Guacamole.
4. Include Guacamole web app, guacd, and PostgreSQL.
5. Use NFS-backed persistent storage for PostgreSQL.
6. Keep ingress disabled for the local phase.
7. Include port-forward testing instructions.
8. Include uninstall and rollback instructions.
9. Add Cloudflare Tunnel planning notes, but do not deploy Cloudflare yet.

## Expected response

Write a response file here:

```text
.openclaw-mailbox/outbox/0001-guacamole-helm-service-response.md
```

The response should include:

- What you inspected
- What files you created or changed
- What commands you ran
- Any blockers
- Exact next commands Scott should run
- Whether the changes were committed and pushed

## Commit guidance

If you make changes, commit them with a clear message such as:

```text
Add Guacamole Helm service scaffold
```
