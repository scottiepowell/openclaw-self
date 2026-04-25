---
name: python-project-dev
description: Build or modify Python scripts, validators, tests, packaging, or automation. Use when a repo task centers on Python implementation or lightweight test scaffolding.
---

# Python Project Dev

Workflow:
1. Inspect the repo.
2. Identify Python version and dependency style.
3. Make the smallest useful change.
4. Add validation where practical.
5. Run the narrowest useful test.

Preferred commands:

```bash
python --version
python -m py_compile scripts/*.py
pytest -q
```

If no test framework exists, prefer a simple shell validation first.
Do not install packages globally.
Prefer `.venv`.
