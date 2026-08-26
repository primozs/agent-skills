# Pi setup

Pi auto-discovers skills from `~/.agents/skills/` — no config file needed.

## One-time machine setup

```bash
./pi/install.sh
```

Creates symlinks:

- `~/.agents/skills/` → `repo/skills/`
- `~/.agents/references/` → `repo/references/`
- `~/.agents/agents/` → `repo/agents/`
- `~/.pi/agent/extensions/agent-skills-commands.ts` → `repo/pi/agent-skills-commands.ts`

## Per-repo setup

Copy or append `pi/AGENTS.md.example` into your project's `AGENTS.md`.

That's it. No `.pi/settings.json` required — `enableSkillCommands` defaults to `true`.

## Commands

The extension registers `/as-*` commands that mirror the Claude Code `.toml` commands:

| Command | Underlying skill(s) |
| --------- | --------------------- |
| `/as-spec` | `spec-driven-development` |
| `/as-plan` | `planning-and-task-breakdown` |
| `/as-build` | `incremental-implementation` + `test-driven-development` |
| `/as-test` | `test-driven-development` |
| `/as-review` | `code-review-and-quality` |
| `/as-code-simplify` | `code-simplification` |
| `/as-ship` | `shipping-and-launch` + personas |
| `/as-webperf` | `web-performance-auditor` persona |

Arguments pass through: `/as-spec add user authentication`.

## Comparison to Cursor

| | Cursor | Pi |
| --- | --- | --- |
| Init file | `cursor/agent-skills.mdc.example` → `.cursor/rules/` | `pi/AGENTS.md.example` → project `AGENTS.md` |
| Skill discovery | Needs rule pointing to `~/.agents/skills/` | Auto-discovers `~/.agents/skills/` natively |
| Commands | `cursor/command-skills/as-*` wrappers | `pi/agent-skills-commands.ts` extension |
| References | Via rule file | Mention in `AGENTS.md` |
| Personas | `~/.cursor/agents/` auto-discovery | Mention in `AGENTS.md` |
