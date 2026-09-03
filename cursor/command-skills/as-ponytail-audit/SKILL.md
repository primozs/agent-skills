---
name: as-ponytail-audit
description: >-
  Ponytail over-engineering audit → persisted checklist → fix one finding at a
  time with agent-skills. Optional folder scopes the audit. Use when the user
  invokes /as-ponytail-audit.
disable-model-invocation: true
---

# as-ponytail-audit

Brownfield loop: audit once, persist, burn down one checkbox at a time.
Does **not** auto-commit. Stop after each resolved (or skipped) item.

## User input

Text after `/as-ponytail-audit` is **$ARGUMENTS**:

| Args | Mode |
|------|------|
| empty / `audit` | Run audit on the whole repo; write/overwrite `PONYTAIL-AUDIT.md`; stop |
| `<path>` / `audit <path>` | Run audit scoped to that folder only; same file + stop |
| `next` | Fix the first unchecked item; stop |
| `<N>` | Fix item number N; stop |
| `skip <N> [reason]` | Mark item N wontfix; stop |
| `status` | List open / done / skipped; change nothing |

Parse order: reserved modes (`next`, `status`, `skip …`, bare `audit`, integer `<N>`) win first. Anything else that looks like a path (`/…`, `./…`, `../…`, `~…`, or contains `/`) is a scoped audit. Example: `/as-ponytail-audit src/api`.

## Audit file

Path: `PONYTAIL-AUDIT.md` at the repo root (create if missing). Always at repo root even when the audit is folder-scoped.

```markdown
# Ponytail audit — <YYYY-MM-DD>
<!-- optional: Scope: <path> -->

- [ ] 1. `delete:` <what to cut>. <replacement>. [`path`]
- [ ] 2. `yagni:` …
…

net: -<N> lines, -<M> deps possible
```

Checked = done. Use `- [x]` or `- [~] wontfix: <reason>` for skips.

## Mode: audit

1. Resolve scope: no path → whole repo; path given → that directory only (refuse if missing / not a directory).
2. If `ponytail-audit` is installed, read and follow it
   (`~/.agents/skills/ponytail-audit/SKILL.md` or `~/.cursor/skills/ponytail-audit/SKILL.md`),
   passing the folder scope when set.
   Else hunt over-engineering only (dead code, reinvented stdlib/native,
   single-impl abstractions, thin wrappers, unused config) and emit one line
   per finding: `` <tag> <what to cut>. <replacement>. [`path`] `` with tags
   `delete:` `stdlib:` `native:` `yagni:` `shrink:`. End with
   `net: -<N> lines, -<M> deps possible.` Nothing to cut → `Lean already. Ship.`
3. Write findings into `PONYTAIL-AUDIT.md` as numbered checkboxes (biggest cut first). If scoped, note `Scope: <path>` under the title.
4. Summarize count + top 3 (and scope if set). **Do not fix anything.** Stop.

## Mode: next / `<N>`

1. Read `PONYTAIL-AUDIT.md`. If missing, tell the user to run `/as-ponytail-audit` first.
2. Pick the target item (`next` = first `- [ ]`; else number N). Refuse if already done/skipped.
3. Work **only** that item. Do not touch other findings.

### Tier by tag (do not over-ceremony)

| Tag | Skills / depth |
|-----|----------------|
| `delete:` / obvious dead | `context-engineering` → cut → `test-driven-development` (run existing tests; add a check only if nothing covers the path) |
| `stdlib:` / `native:` / `shrink:` | same + `code-simplification` for the replacement |
| `yagni:` / multi-caller / public API | `context-engineering` → `doubt-driven-development` (is the cut safe?) → minimum fix → `code-review-and-quality` if it crosses a module boundary → tests |

Read and follow the matching skills under `.cursor/skills/` (or `~/.agents/skills/` / `~/.cursor/skills/`). Prefer the shortest correct cut (ponytail ladder). Scope: over-engineering only — do not expand into unrelated refactors.

4. If the finding is wrong or too risky, mark
   `- [~] N. … wontfix: <one-line reason>` instead of forcing a cut. Stop.
5. On success: mark `- [x]`, summarize the diff in 2–3 lines, say how many open items remain. **Stop.** Wait for `/as-ponytail-audit next` (or `skip` / `status`).

## Mode: skip / status

- **skip:** update the checkbox with `wontfix` + reason; stop.
- **status:** counts + list open items; change nothing.

## Boundaries

- One item per invocation (except `audit` / `status` / `skip`).
- No commits unless the user explicitly asks.
- Correctness/security/performance bugs are out of scope for the audit list — route those to `/as-review` or `/as-test`.
