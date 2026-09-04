# Codex command skills (`as-*`)

Thin entry-point skills for Codex that mirror the Cursor `/as-*` and Claude Code
slash commands. Each wraps one or more workflow skills from the **agent-skills**
Codex plugin.

## Prerequisite

Install and enable the agent-skills plugin so `$spec-driven-development` and the
other workflow skills resolve:

```bash
codex plugin marketplace add /path/to/agent-skills   # or addyosmani/agent-skills
codex plugin add agent-skills@agent-skills
```

## Usage

In Codex CLI / IDE, invoke with `$` (or pick via `/skills`):

```text
$as-spec add user authentication
$as-plan
$as-build
$as-build auto
$as-test fix the checkout bug
$as-review
$as-code-simplify
$as-ship
$as-webperf https://example.com
$as-ponytail-audit
$as-ponytail-audit src/api
$as-ponytail-audit next
```

Text after the skill name is treated as **$ARGUMENTS**.

## Install

From the agent-skills repo root:

```bash
./codex/install.sh
```

This symlinks `codex/command-skills/as-*` into `~/.codex/skills/`. Override the
target with `CODEX_SKILLS_DIR` if needed. Restart Codex after install.

For a **repo-local** install, symlink or copy each `as-*` folder into the
project's `.agents/skills/` instead (Codex scans that path from CWD up to repo root).

## Mapping

| Command | Underlying skill(s) | Cursor / Claude |
|---------|---------------------|-----------------|
| `$as-spec` | `spec-driven-development` | `/as-spec` / `/spec` |
| `$as-plan` | `planning-and-task-breakdown` | `/as-plan` / `/plan` |
| `$as-build` | `incremental-implementation`, `test-driven-development` | `/as-build` / `/build` |
| `$as-test` | `test-driven-development` | `/as-test` / `/test` |
| `$as-review` | `code-review-and-quality` | `/as-review` / `/review` |
| `$as-code-simplify` | `code-simplification` | `/as-code-simplify` / `/code-simplify` |
| `$as-ship` | personas + `shipping-and-launch` | `/as-ship` / `/ship` |
| `$as-webperf` | `web-performance-auditor` persona + `performance-optimization` | `/as-webperf` / `/webperf` |
| `$as-ponytail-audit` | ponytail-audit + context / doubt / simplify / test / review | `/as-ponytail-audit` / `/ponytail-audit` |

## How this differs from Cursor

| | Cursor | Codex |
|---|---|---|
| Invoke | `/as-spec` | `$as-spec` |
| Explicit-only | `disable-model-invocation: true` | `agents/openai.yaml` → `allow_implicit_invocation: false` |
| Workflow body | Read `.cursor/skills/.../SKILL.md` | Invoke plugin skills by name (`$spec-driven-development`) |
| Install target | `~/.cursor/skills/` | `~/.codex/skills/` |

## Source layout

```text
codex/command-skills/
├── as-spec/SKILL.md
├── as-plan/SKILL.md
├── as-build/SKILL.md
├── as-test/SKILL.md
├── as-review/SKILL.md
├── as-code-simplify/SKILL.md
├── as-ship/SKILL.md
├── as-webperf/SKILL.md
└── as-ponytail-audit/SKILL.md
```

Each skill includes `agents/openai.yaml` with `allow_implicit_invocation: false`
so it only runs when explicitly invoked via `$as-*`.
