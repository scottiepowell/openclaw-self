# Mailbox Task 0005 — Diagnose Guacamole LAN Access

## Objective

Scott tried to access Guacamole from the LAN at:

```text
http://192.168.1.206:8080/
```

It did not work.

Diagnose whether the issue is port-forward binding, host firewall, wrong node IP, wrong service, Guacamole service health, or Kubernetes networking. Do not expose Guacamole publicly and do not configure Cloudflare yet.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Current known good from Task 0003

- Guacamole app was running internally.
- Service name was reported as `svc/guacamole-guacamole`.
- Local port-forward smoke test to `127.0.0.1:8080` returned HTTP 200.
- Command reported for local access:

  ```bash
  kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80
  ```

## Important hypothesis

`kubectl port-forward` defaults to binding localhost only. If Scott tried `http://192.168.1.206:8080/` from another machine while port-forward was bound to `127.0.0.1`, it would fail.

LAN-access test requires running this on the host with IP `192.168.1.206`:

```bash
kubectl -n guacamole port-forward --address 0.0.0.0 svc/guacamole-guacamole 8080:80
```

Then from another LAN machine:

```text
http://192.168.1.206:8080/
```

## Required checks

Run and summarize:

```bash
cd /home/scott/projects/openclaw-self
git pull --ff-only
hostname -I || true
ip -br addr || true
ss -ltnp | grep ':8080' || true
kubectl -n guacamole get svc,pods,pvc -o wide
helm -n guacamole status guacamole || true
kubectl -n guacamole get endpoints,endpointslices -o wide
```

## Test localhost port-forward

Start a short-lived localhost-only port-forward and verify it works on the same machine:

```bash
kubectl -n guacamole port-forward svc/guacamole-guacamole 8080:80 >/tmp/guacamole-pf-localhost.log 2>&1 &
PF_PID=$!
sleep 5
ss -ltnp | grep ':8080' || true
curl -I http://127.0.0.1:8080/ || true
kill "$PF_PID" || true
cat /tmp/guacamole-pf-localhost.log
```

## Test LAN-bind port-forward

Start a short-lived LAN-bind port-forward and verify it is listening on all interfaces:

```bash
kubectl -n guacamole port-forward --address 0.0.0.0 svc/guacamole-guacamole 8080:80 >/tmp/guacamole-pf-lan.log 2>&1 &
PF_PID=$!
sleep 5
ss -ltnp | grep ':8080' || true
curl -I http://127.0.0.1:8080/ || true
curl -I http://192.168.1.206:8080/ || true
kill "$PF_PID" || true
cat /tmp/guacamole-pf-lan.log
```

If `192.168.1.206` is not an IP on the host running the command, use the actual host IP and report the correct LAN URL.

## Firewall checks

Inspect host firewall state safely:

```bash
sudo ufw status || true
sudo firewall-cmd --state || true
sudo firewall-cmd --list-all || true
sudo nft list ruleset | grep -E '8080|reject|drop' | head -80 || true
```

Do not open firewall ports unless clearly needed and safe. If a firewall rule is needed, write the exact command as a recommendation rather than applying it unless the fix is narrowly scoped and obviously safe.

## Optional temporary NodePort comparison

Do not permanently change the service type yet.

If port-forward LAN bind continues to fail, inspect whether a temporary NodePort would be more appropriate for LAN testing, but do not apply it unless you document the change and make it reversible.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0005-diagnose-guacamole-lan-access-response.md
```

## Response must include

- Whether Guacamole pods and service are healthy
- Whether localhost port-forward works
- Whether `--address 0.0.0.0` port-forward works from the host
- Whether `192.168.1.206` is actually on the host where port-forward ran
- Exact `ss` listener output summary for port 8080
- Firewall status summary
- Correct LAN URL to try
- Exact command Scott should run next
- Whether task `0004` has been completed or is still pending locally
- Any recommended follow-up task
- Commit SHA and push result

## Safety rules

- Do not configure Cloudflare yet.
- Do not enable public ingress.
- Do not print secrets.
- Do not delete PVCs.
- Do not leave port-forward processes running unattended.
- If blocked, write the blocker clearly in the outbox response.
