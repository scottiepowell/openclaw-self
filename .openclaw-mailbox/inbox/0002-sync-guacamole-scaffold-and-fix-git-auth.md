# Mailbox Task 0002 — Sync Guacamole Scaffold and Fix Git Auth

## Objective

The previous task created the Guacamole Helm scaffold locally, but the outbox response reported that `git push` was blocked by GitHub HTTPS authentication:

```text
fatal: could not read Username for 'https://github.com'
```

Fix the local `openclaw-self` repo Git authentication path so OpenClaw can push reliably, then push the Guacamole scaffold changes from Task 0001 to GitHub.

## Repo path

```text
/home/scott/projects/openclaw-self
```

## Important context

- Scott does not have direct OpenClaw CLI access from this desktop session.
- This mailbox workflow is the control channel.
- You must write your result under `.openclaw-mailbox/outbox/` and commit/push it.
- The mailbox response file from Task 0001 is visible on GitHub, but a GitHub search did not show the requested Guacamole scaffold files on `main`.
- Therefore, assume the scaffold files may exist only in your local working tree until proven otherwise.

## Required first checks

Run these and record the output summary in your response:

```bash
cd /home/scott/projects/openclaw-self
pwd
git status --short
git branch --show-current
git remote -v
git log --oneline -5
ls -la docs/guacamole helm/guacamole scripts/guacamole 2>/dev/null || true
```

## Git auth fix

If `origin` uses HTTPS, change this repo to SSH.

Preferred remote:

```bash
git remote set-url origin git@github.com:scottiepowell/openclaw-self.git
```

Then test:

```bash
ssh -T git@github.com || true
git fetch origin main
```

If SSH auth fails because the correct SSH key is not loaded or configured, do **not** repeatedly retry. Instead:

1. Write the exact SSH/Git error to the outbox response.
2. Include the output of:

   ```bash
   ls -la ~/.ssh
   git remote -v
   ssh -T git@github.com || true
   ```

3. If a public key exists that looks appropriate, include only the public key filename, not private key contents.
4. Do not print private key contents.

## Sync requirements

If the Guacamole scaffold files from Task 0001 exist locally, commit and push them.

Expected files:

```text
docs/guacamole/GUACAMOLE_PLAN.md
docs/guacamole/CLOUDFLARE_TUNNEL_PLAN.md
helm/guacamole/values-local.yaml
helm/guacamole/values-cloudflare.yaml
scripts/guacamole/install-guacamole.sh
scripts/guacamole/test-guacamole.sh
scripts/guacamole/uninstall-guacamole.sh
```

Use a clear commit message:

```text
Add Guacamole Helm service scaffold
```

If those files do not exist locally, recreate them from the Task 0001 requirements, then commit and push.

## Validation commands

After the files are present, run:

```bash
bash scripts/guacamole/test-guacamole.sh
```

If the script performs only safe dry-run/template checks, capture whether it passed or failed.

Do **not** run the install script yet unless the script itself is clearly safe and Scott has explicitly approved installation. For now, prefer test/template validation only.

## Expected response file

Write your response here:

```text
.openclaw-mailbox/outbox/0002-sync-guacamole-scaffold-and-fix-git-auth-response.md
```

## Response must include

- Current branch
- Remote URL before and after any change
- Whether SSH auth works
- Whether the Guacamole scaffold files existed locally or had to be recreated
- Files committed
- Commit SHA
- Push result
- Output summary from `bash scripts/guacamole/test-guacamole.sh`
- Exact next command Scott should send or run

## Safety rules

- Do not expose private SSH key contents.
- Do not install Guacamole yet unless explicitly approved.
- Do not modify unrelated workloads.
- Do not delete any existing repo files.
- If blocked, still write an outbox response explaining the blocker and exact fix needed.
