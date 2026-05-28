# wger deployment

## Namespace

- `fitness`

## Chart

- Repo: `wger/wger`
- Chart version: `0.3.0`

## Storage

The install script auto-detects the cluster's NFS dynamic provisioner storageClass at runtime and injects it into the local values file.

Expected PVC sizes:

- App media: `10Gi`
- App static: `2Gi`
- Celery beat: `1Gi`
- PostgreSQL: `10Gi`
- Redis: `1Gi`

## Install

```bash
bash scripts/wger/install-local.sh
```

## Status

```bash
bash scripts/wger/status.sh
```

## Logs

```bash
bash scripts/wger/logs.sh
```

## Port-forward

```bash
bash scripts/wger/port-forward.sh
curl -I http://127.0.0.1:8080
```

## Troubleshooting

- If PVCs stay Pending, confirm the detected storageClass matches the NFS provisioner.
- If the app pod is Pending, check events for storage binding or node scheduling issues.
- If migrations fail, inspect `init-container` logs first, then the main `wger` container.
- If Redis persistence feels unnecessary later, it can be disabled in `helm/wger/values-local.yaml`.

## Next steps

- Create the initial wger account manually.
- Connect the mobile app.
- Add Cloudflare tunnel exposure later.
- Add Discord/OpenClaw fitness integration later.
- Build a future fitness bridge service when the manual workflow is stable.
