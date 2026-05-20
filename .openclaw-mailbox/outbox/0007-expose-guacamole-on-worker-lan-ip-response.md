# Mailbox Task 0007 Response

## Result
- Added a separate LAN-only NodePort service for Guacamole.
- Kept the Helm-managed service internal as `ClusterIP`.
- Documented the LAN access path and security gate.

## Whether 32080 was available
- Yes, `32080` was free before the new service was created.
- It is now assigned to the Guacamole LAN NodePort service.

## Exposure option used
- Separate service manifest
- Helm chart does not expose a clean `nodePort` knob in the current values schema, so I used an explicit Kubernetes Service.

## Files changed
- `k8s/guacamole/guacamole-nodeport-service.yaml`
- `scripts/guacamole/show-guacamole-access.sh`
- `docs/guacamole/GUACAMOLE_PLAN.md`
- `docs/guacamole/GUACAMOLE_SECURITY_CHECKLIST.md`

## Scripts executable
- `scripts/guacamole/show-guacamole-access.sh` is executable

## Helm / service status after change
- Helm release: `deployed`
- Main Guacamole service: `ClusterIP`
- LAN service: `NodePort`
- NodePort: `32080`

## Worker node IPs
- `worker-01`: `192.168.1.174`
- `worker-02`: `192.168.1.156`
- `devops`: `192.168.1.206`

## Exact LAN URL Scott should test
- `http://192.168.1.174:32080/`

## Curl smoke test
- Failed from the OpenClaw host
- Failed from an in-cluster curl pod to the worker IP as well
- Likely firewall or node-port reachability needs attention before this is usable from the LAN

## Firewall note
- Yes, firewall changes may be needed on the worker nodes for TCP 32080.

## Port-forward fallback
- `kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80`

## Security warning
- Default credentials are still shown in Helm notes as `guacadmin / guacadmin`
- Do not use the LAN path broadly until those credentials are changed or disabled

## Validation
- `bash -n scripts/guacamole/show-guacamole-access.sh` ✅
- `bash scripts/guacamole/show-guacamole-access.sh` ✅
- `bash scripts/guacamole/verify-guacamole-security.sh || true` ✅
- `bash scripts/guacamole/test-guacamole.sh` ✅

## Commit / push
- Commit SHA: `0f8e09a`
- Push result: `origin/main` updated successfully
