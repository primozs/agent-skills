---
description: Ponytail over-engineering audit → PONYTAIL-AUDIT.md → fix one finding at a time with agent-skills
---

Run the as-ponytail-audit workflow (brownfield: audit once, persist, burn down one checkbox at a time). Do not auto-commit. Stop after each resolved or skipped item.

## Arguments

| Args | Mode |
|------|------|
| empty / `audit` | Run audit on the whole repo; write/overwrite `PONYTAIL-AUDIT.md`; stop |
| `<path>` / `audit <path>` | Run audit scoped to that folder only; same file + stop |
| `next` | Fix the first unchecked item; stop |
| `<N>` | Fix item number N; stop |
| `skip <N> [reason]` | Mark item N wontfix; stop |
| `status` | List open / done / skipped; change nothing |

Reserved modes (`next`, `status`, `skip …`, bare `audit`, integer `<N>`) win first; otherwise a path-looking arg is a scoped audit.

## Audit file

`PONYTAIL-AUDIT.md` at repo root with numbered checkboxes (even when scoped). Note `Scope: <path>` when set. Skips use `- [~] wontfix: <reason>`.

## Mode: audit

Resolve scope (whole repo vs folder). Follow ponytail-audit if installed (pass folder when set); else hunt over-engineering (`delete:` `stdlib:` `native:` `yagni:` `shrink:`). Write `PONYTAIL-AUDIT.md`. Do not fix. Stop.

## Mode: next / N

Work ONLY that item. Tier: obvious deletes → context + tests; stdlib/native/shrink → + code-simplification; yagni/multi-caller → + doubt-driven-development (+ review if cross-module). Mark `[x]` or wontfix. Stop.

No commits unless the user explicitly asks. Over-engineering only.
