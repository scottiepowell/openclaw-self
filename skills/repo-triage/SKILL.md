---
name: repo-triage
description: Map a software repository before making changes. Use when entering a repo to inspect structure, dependencies, tests, config files, risky areas, and next steps in a read-only pass.
---

# Repo Triage

Start with read-only inspection.

Run:

```bash
pwd
git status --short
find . -maxdepth 3 -type f | sort | head -200
```

Identify:
- project purpose
- main languages
- entry points
- build commands
- test commands
- config files
- risky files
- recommended next step

Do not edit files during triage unless explicitly asked.
