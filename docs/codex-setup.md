# Using agent-skills with Codex

This repository is also a [Codex plugin](https://developers.openai.com/codex/plugins/build). The same root-level `skills/` directory used by Claude Code is consumed by Codex, so no files are copied or duplicated.

## Install

```bash
codex plugin marketplace add addyosmani/agent-skills
codex plugin add agent-skills@agent-skills
```

> Requires Codex CLI v0.122 or later. On older releases the command was `codex marketplace add`. See the [Codex CLI docs](https://developers.openai.com/codex/cli).

The first command registers this repository as the `agent-skills` marketplace. The second command installs and enables the `agent-skills` plugin from that marketplace. Start a new Codex session after installation so the skills are discovered.

Local clones work too:

```bash
codex plugin marketplace add /path/to/your/clone
codex plugin add agent-skills@agent-skills
```

## Usage

After install, invoke a skill in Codex with `$` (e.g. `$spec-driven-development`), via `/skills`, or just describe the task and let Codex pick the right skill. All 24 skills under `skills/` are available. (ChatGPT desktop may use `@` instead of `$`.)

## Lifecycle commands (`$as-*`)

For Cursor-style entry points (`/as-spec`, `/as-build`, …), this repo also ships **Codex command skills** under [`codex/command-skills/`](../codex/command-skills/). They wrap the plugin workflow skills and are invoked with `$`:

```bash
./codex/install.sh
```

That symlinks the wrappers into `~/.codex/skills/`. Restart Codex, then:

```text
$as-spec add user authentication
$as-plan
$as-build
$as-build auto
$as-test
$as-review
$as-code-simplify
$as-ship
$as-webperf https://example.com
$as-ponytail-audit
```

See [`codex/command-skills/README.md`](../codex/command-skills/README.md) for mapping and repo-local install (`.agents/skills/`).

These wrappers are **not** part of the plugin itself — install them with `./codex/install.sh` after enabling the plugin. Do not symlink the Cursor `cursor/command-skills/` copies into Codex; they hardcode `.cursor/skills/` paths.

## How it works

- `.codex-plugin/plugin.json` — Codex plugin manifest at the repo root. Points `skills` at `./skills/` and provides the metadata required by Codex.
- `.agents/plugins/marketplace.json` — marketplace entry declaring the repo root (`./`) as the plugin source.
- `skills/<name>/SKILL.md` — unchanged. Codex and Claude Code share the same `name` + `description` frontmatter format, so one file serves both platforms.
- `codex/command-skills/as-*/` — optional lifecycle wrappers (explicit `$as-*` only via `agents/openai.yaml`).

Slash commands in `.claude/commands/`, personas in `agents/`, and the lifecycle hook under `hooks/` stay Claude Code-specific. On Codex, use `$as-*` (after `./codex/install.sh`) or invoke the underlying skill directly (e.g. `$spec-driven-development` instead of `/spec`).
