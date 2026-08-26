# Cursor command skills (`as-*`)

Thin entry-point skills for Cursor that mirror the lifecycle slash commands in `.claude/commands/`. Each command skill wraps one or more workflow skills from `skills/`.

## Usage

Invoke from Cursor Agent chat with `/`:

```text
/as-spec add user authentication
/as-plan
/as-build
/as-build auto
/as-test fix the checkout bug
/as-review
/as-code-simplify
/as-ship
/as-webperf https://example.com
```

Text after the slash command is treated as **$ARGUMENTS** — additional context for the workflow.

## Install

**Prerequisite:** sync workflow skills first:

```bash
mkdir -p ~/.cursor/skills
rsync -a /path/to/agent-skills/skills/ ~/.cursor/skills/
```

Then symlink command skills (from repo root):

```bash
./cursor/install.sh
```

## Mapping

| Command | Underlying skill(s) | Claude equivalent |
|---------|---------------------|-------------------|
| `/as-spec` | `spec-driven-development` | `/spec` |
| `/as-plan` | `planning-and-task-breakdown` | `/plan` |
| `/as-build` | `incremental-implementation`, `test-driven-development` | `/build` |
| `/as-test` | `test-driven-development` | `/test` |
| `/as-review` | `code-review-and-quality` | `/review` |
| `/as-code-simplify` | `code-simplification` | `/code-simplify` |
| `/as-ship` | personas + `shipping-and-launch` | `/ship` |
| `/as-webperf` | `web-performance-auditor` persona | `/webperf` |

## Source layout

```text
cursor/command-skills/
├── as-spec/SKILL.md
├── as-plan/SKILL.md
├── as-build/SKILL.md
├── as-test/SKILL.md
├── as-review/SKILL.md
├── as-code-simplify/SKILL.md
├── as-ship/SKILL.md
└── as-webperf/SKILL.md
```

Each skill sets `disable-model-invocation: true` so it only runs when explicitly invoked via `/`.
