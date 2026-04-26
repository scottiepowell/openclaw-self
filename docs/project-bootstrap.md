# Project Bootstrap Guide

Use this when starting a new coding project with OpenClaw.

## Where to create the project

Create new coding projects under:

```bash
~/projects/<project-name>
```

Examples:
- `~/projects/todo-api`
- `~/projects/home-dashboard`
- `~/projects/notes-sync`

Keep `~/projects/openclaw-self` for OpenClaw's own architecture and workflow repo.
Do not mix unrelated app code into `openclaw-self`.

## Minimum files to create before asking OpenClaw to build

Recommended starting layout:

```text
~/projects/<project-name>/
├── AGENTS.md
├── README.md
├── TASKS.md
├── CHANGELOG.md
├── docs/
│   └── architecture.md
└── scratch/
```

### AGENTS.md

Put durable repo rules here.
This is the most important file.

Include:
- mission of the project
- stack and constraints
- safety rules
- coding style preferences
- validation commands
- commit and release rules

### README.md

Put the human-facing project summary here.

Include:
- what the project is
- how to run it
- how to test it
- key directories

### TASKS.md

Put the high-level project to-do list here.

Use it for:
- milestones
- next tasks
- open questions
- deferred ideas

Keep it short and current. This is the best place for your high-level to-do list.

### CHANGELOG.md

Track meaningful project changes.

### docs/architecture.md

Put the system design here.

Use it for:
- components
- data flow
- APIs
- deployment shape
- tradeoffs

## What to put in AGENTS.md before starting

At minimum, define:
- what the software does
- what stack to prefer
- how strict to be about tests
- whether OpenClaw can commit automatically
- what commands are safe without asking
- what commands require approval

Good examples:
- "Use Python 3.12 and FastAPI"
- "Prefer small patches and keep functions under 50 lines when practical"
- "Run pytest -q before commit"
- "Never run docker compose down without asking"

## Best way to use OpenClaw to build the project

Yes, you can absolutely use this chat window.
That is a good way to start.

Recommended flow:
1. create `~/projects/<project-name>`
2. add `AGENTS.md`, `README.md`, `TASKS.md`, and `docs/architecture.md`
3. open the repo in VS Code
4. tell OpenClaw to work inside that repo
5. ask for a read-only triage first
6. then ask for the smallest useful implementation step

Example prompt:

```text
Use Wright.

Read AGENTS.md and TASKS.md. Treat this repo as the source of truth. Do a read-only triage first: inspect the repo, summarize the architecture, identify missing pieces, and recommend the smallest useful next implementation step. Do not edit files yet.
```

## Should you use this chat or Discord?

Both work.

- Use this chat when you want focused build sessions and fast iteration.
- Use Discord when you want lightweight routing, async follow-ups, or channel-separated work.
- Use VS Code as the main place to inspect files and diffs.

Best default:
- plan and steer in this chat or Discord
- inspect and review in VS Code
- let OpenClaw edit inside the repo

## Simple rule of thumb

Before asking OpenClaw to code, give it:
- a repo
- an `AGENTS.md`
- a `TASKS.md`
- a minimal architecture note

That is enough to start building sanely.
