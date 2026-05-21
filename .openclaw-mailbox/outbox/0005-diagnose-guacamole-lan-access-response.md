# Mailbox Task 0005 Response

## Current Guacamole status
- Guacamole pods: healthy (`2/2` ready on `guacamole-guacamole-6cc5587d44-hbfk6`)
- Guacamole service: healthy (`svc/guacamole-guacamole`, ClusterIP)
- Endpoints: present and correct (`10.244.171.20:8080`)
- Helm release: `deployed`

## Required checks
- `hostname -I`: `192.168.0.165 192.168.1.205 172.17.0.1 172.18.0.1 172.19.0.1`
- `ip -br addr`: host has `192.168.1.205/24` on `enp3s0f1.20`
- `192.168.1.206` is **not** on this host
- `ss` on 8080 during localhost PF:
  - `LISTEN 0 4096 127.0.0.1:8080 0.0.0.0:* users:(("kubectl",pid=740206,fd=7))`
  - `LISTEN 0 4096 [::1]:8080 [::]:* users:(("kubectl",pid=740206,fd=8))`
- `ss` on 8080 during LAN PF:
  - `LISTEN 0 4096 0.0.0.0:8080 0.0.0.0:* users:(("kubectl",pid=740315,fd=7))`

## Port-forward tests
- Localhost-only port-forward: **works**
  - `curl -I http://127.0.0.1:8080/` returned `HTTP/1.1 200`
- LAN-bind port-forward with `--address 0.0.0.0`: **works from the host**
  - `curl -I http://127.0.0.1:8080/` returned `HTTP/1.1 200`
  - `curl -I http://192.168.1.205:8080/` returned `HTTP/1.1 200`

## Firewall summary
- `firewalld`: `active`
- `ufw`: not installed or not accessible
- No 8080-specific `nft` rules were visible in the non-root probe
- I could not run the requested sudo firewall commands because sudo requires a password here

## Correct LAN URL to try
- `http://192.168.1.205:8080/`

## Exact command Scott should run next
```bash
kubectl -n guacamole port-forward --address 0.0.0.0 svc/guacamole-guacamole 8080:80
```

## Task 0004 status locally
- `0004-stabilize-guacamole-helm-release-response.md` exists in `.openclaw-mailbox/outbox`, so task 0004 is **completed locally**

## Recommended follow-up task
- Confirm whether `192.168.1.205` is the intended controller IP, then update any notes/runbooks that still reference `192.168.1.206`
- If you want to eliminate the port-forward dependency, a reversible NodePort comparison would be the next safe LAN test

## Commit SHA
- `TBD_AFTER_COMMIT`

## Push result
- `TBD_AFTER_PUSH`
