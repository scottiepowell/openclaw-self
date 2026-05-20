# Mailbox Task 0007 — Expose Guacamole on Worker LAN IP

## Objective

Scott verified Guacamole works through `kubectl port-forward`, but he does not want to rely only on loopback access. Configure a LAN-only access path so Guacamole can be reached from a browser by pointing to a Kubernetes worker node IP and a stable port.

This is **not** Cloudflare exposure and **not** public internet exposure.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Current known state

- Guacamole is deployed by Helm in namespace `guacamole`.
- Current internal service is `svc/guacamole-guacamole`.
- Current local-only access works:

  ```bash
  kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
  ```

- App pod and PostgreSQL are temporarily pinned to `worker-01` because `devops` has a pod/service network routing issue.
- Service must remain LAN/internal only for now.
- Do not configure Cloudflare yet.
- Do not configure Kubernetes Ingress yet.

## Important security gate

Before broad LAN use, confirm whether Scott has changed the default Guacamole credentials.

Do not try to automate Guacamole UI login.
Do not print passwords or secrets.

If you cannot verify credentials were changed, include a clear warning in the outbox response and docs:

```text
Do not expose beyond the trusted LAN until guacadmin/guacadmin has been changed or disabled.
```

## Preferred approach

Prefer a Kubernetes `NodePort` service for LAN-only access, because the cluster does not currently have a confirmed load balancer implementation.

Target behavior should be something like:

```text
http://<worker-01-LAN-IP>:<nodePort>/
```

Use a stable explicit nodePort if safe and available, for example in the Kubernetes NodePort range `30000-32767`.

Suggested candidate:

```text
32080
```

But first check whether it is already used.

## Required preflight checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
git status --short
git branch --show-current
helm -n guacamole status guacamole
kubectl -n guacamole get pods,pvc,svc -o wide
kubectl get nodes -o wide
kubectl get svc -A -o wide
```

Check whether NodePort `32080` is already in use:

```bash
kubectl get svc -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{" "}{range .spec.ports[*]}{.nodePort}{" "}{end}{"\n"}{end}' | grep -w 32080 || true
```

## Implementation options

### Option A — Helm values service.type NodePort

If the Guacamole Helm chart supports setting the main service to NodePort cleanly, update:

```text
helm/guacamole/values-local.yaml
```

so the Guacamole service is still Helm-managed but exposed as a NodePort.

Preserve the current service name if possible:

```text
svc/guacamole-guacamole
```

Desired values, adjusted to the chart schema:

```yaml
service:
  type: NodePort
  port: 80
  nodePort: 32080
```

Then run a Helm upgrade/reconcile and verify.

### Option B — Separate LAN-only NodePort service manifest

If the chart does not support `nodePort` cleanly, create a separate explicit Kubernetes Service manifest under the repo, for example:

```text
k8s/guacamole/guacamole-nodeport-service.yaml
```

The service should select the existing Guacamole app pods and expose port 80 through a stable NodePort such as 32080.

Only use this option if Helm values cannot do it cleanly.

Document why this separate service exists.

## Do not use unless explicitly justified

Do not use hostNetwork.
Do not use hostPort unless NodePort is impossible.
Do not use LoadBalancer unless MetalLB or another load balancer is already installed and clearly working.
Do not enable Ingress.
Do not configure Cloudflare Tunnel.

## Apply and validate

After choosing the safest option, apply it and run:

```bash
helm -n guacamole status guacamole
kubectl -n guacamole get pods,pvc,svc -o wide
kubectl -n guacamole describe svc guacamole-guacamole || true
kubectl -n guacamole get svc -o yaml
```

Then identify:

- worker node name
- worker node LAN IP
- NodePort
- final URL Scott should test

Run a local cluster-side smoke test if possible:

```bash
curl -I http://127.0.0.1:32080/ || true
```

If running on a node where NodePort binds all node interfaces, also try the worker node IP if reachable from the OpenClaw host:

```bash
curl -I http://<worker-01-LAN-IP>:32080/ || true
```

Replace `<worker-01-LAN-IP>` with the actual IP from `kubectl get nodes -o wide`.

## Documentation updates requested

Update or create docs so Scott knows how to access Guacamole without port-forwarding:

```text
docs/guacamole/GUACAMOLE_PLAN.md
docs/guacamole/GUACAMOLE_SECURITY_CHECKLIST.md
```

Add a short section like:

```text
LAN access path:
http://<worker-01-LAN-IP>:32080/
```

Also document:

- This is LAN-only exposure.
- Keep Cloudflare and ingress disabled for now.
- Change/disable default credentials before regular use.
- Firewall may need to allow TCP 32080 on worker nodes.
- If access fails from another LAN machine, check node firewall, kube-proxy, and routing.

## Optional helper script

If useful, create:

```text
scripts/guacamole/show-guacamole-access.sh
```

It should print:

- Helm status
- service type
- nodePort
- worker node IPs
- suggested LAN URL(s)
- current port-forward fallback command

It must not print secrets.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0007-expose-guacamole-on-worker-lan-ip-response.md
```

## Response must include

- Whether `32080` was available
- Which exposure option was used: Helm NodePort or separate service manifest
- Files changed
- Helm status after change
- Service type after change
- NodePort value
- Worker node IP(s)
- Exact LAN URL Scott should test
- Whether curl smoke test passed
- Whether firewall changes may be needed
- Port-forward fallback command
- Security warning about default credentials if still relevant
- Commit SHA
- Push result

## Safety rules

- Do not expose through Cloudflare.
- Do not enable ingress.
- Do not delete or recreate the PostgreSQL PVC.
- Do not reset the Guacamole database.
- Do not print secrets.
- If the service cannot be exposed safely, stop and write a blocker response instead.
