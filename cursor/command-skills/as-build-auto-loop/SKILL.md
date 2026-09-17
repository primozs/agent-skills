---
name: as-build-auto-loop
description: >-
  Autonomously builds approved specs with a per-task implement→review→fix loop
  ending in a git commit, then a ship→fix loop, then the next module spec.
  Use when the user invokes /as-build-auto-loop or wants full-spec autonomous
  build with review and ship gates.
disable-model-invocation: true
---

# as-build-auto-loop

Orchestrates the full build for one or more **already-written** specs. Does **not**
invent requirements. References **only** core workflow skills under
`.cursor/skills/` — never other `/as-*` command wrappers.

## User input

Text after `/as-build-auto-loop` is **$ARGUMENTS** — optional context (module id
to resume, notes). Empty means resume from the next incomplete work.

## Core skills (load these, not as-*)

| Step | Skill path under `.cursor/skills/` |
|------|--------------------------------------|
| Plan | `planning-and-task-breakdown/SKILL.md` |
| Implement | `incremental-implementation/SKILL.md` |
| Tests / fixes | `test-driven-development/SKILL.md` |
| High-risk decisions | `doubt-driven-development/SKILL.md` |
| Review | `code-review-and-quality/SKILL.md` |
| Commit | `git-workflow-and-versioning/SKILL.md` |
| Ship gate | `shipping-and-launch/SKILL.md` |
| Stuck / broken | `debugging-and-error-recovery/SKILL.md` |

## Spec discovery

**Require a spec before anything else.** Do not invent requirements.

1. **Multi-module:** If `CAPABILITY-MAP.md` exists at the repo root (or an
   equivalent approved capability map naming module ids and build order), walk
   modules in that build order. Each module's spec is `SPEC-<module-id>.md` at
   the repo root (or under `docs/` / `spec/` with the same basename).
2. **Single-spec:** Else look for `SPEC.md`, `docs/SPEC.md`, or a file under
   `spec/`. A README or arbitrary doc does **not** count.

If none exists, **stop** and tell the user to write a spec first
(`spec-driven-development`) — do not invent requirements.

Plan / todo paths:

| Mode | Plan | Todo |
|------|------|------|
| Single | `tasks/plan.md` | `tasks/todo.md` |
| Module `<id>` | `tasks/plan-<id>.md` | `tasks/todo-<id>.md` |

## Outer loop (modules / specs)

```
for each incomplete module (or the single spec) in build order:
  plan (if needed) → approve once if new → task loop → ship loop
  mark module done
final ship loop if more than one module was built
summarize
```

### 0. Clean baseline

Run `git status --porcelain`. If there are uncommitted changes outside planning
artifacts (`SPEC.md`, `docs/SPEC.md`, `spec/*`, `CAPABILITY-MAP.md`,
`SPEC-*.md`, `tasks/plan.md`, `tasks/todo.md`, `tasks/plan-*.md`,
`tasks/todo-*.md`), stop and ask the user to commit, stash, or confirm how to
handle them.

### 1. Checkpoint (once per invocation when new plans will be created)

Present: active spec(s) in order, which are done vs pending, and any new plan
about to be generated. Wait for an unambiguous affirmative (`approve` / `go` /
`yes`). Hedged replies are **not** approval. After approval, run autonomously
until a hard stop (below) or completion.

If resuming and every remaining plan already exists, skip the checkpoint and
continue.

### 2. Plan the active spec

If the plan/todo for this spec is missing, read and follow
`planning-and-task-breakdown`. Commit the new plan artifacts with
`git-workflow-and-versioning` as one preparatory commit (do not mix into the
first task).

### 3. Task loop (every pending task in dependency order)

For each task:

```
implement (TDD) → review → fix → review → … until review clear → git commit
```

**Implement**

1. Read acceptance criteria; load relevant context.
2. Follow `incremental-implementation` + `test-driven-development`:
   RED → GREEN → full suite → build.
3. Do **not** commit yet.

**Review → fix loop**

1. Read and follow `code-review-and-quality` on the task's uncommitted diff
   (and its tests).
2. **Clear means:** no Critical and no Important findings. Suggestions may
   remain; do not block on them.
3. If not clear: fix with `test-driven-development` (and
   `doubt-driven-development` when the finding is a high-stakes design call).
   Then review again. Repeat until clear.
4. Cap: if the same Critical/Important theme persists after **3** fix→review
   cycles, stop and ask the user (do not thrash).

**Commit (ends the task)**

1. Read and follow `git-workflow-and-versioning`.
2. Stage only files this task touched plus its task-status update — never blind
   `git add -A`.
3. One atomic commit per task.
4. Mark the task complete in the todo/plan. Proceed to the next pending task.

### 4. Ship → fix loop (when all tasks for this spec are complete)

```
ship checklist → fix blockers → ship again → … until GO → git if needed
```

1. Read and follow `shipping-and-launch` against this spec's change set.
2. **GO:** no launch blockers (Critical/High checklist failures). Produce the
   rollback plan the skill requires.
3. **NO-GO:** fix blockers with `test-driven-development` and/or
   `doubt-driven-development`, then re-run `shipping-and-launch`. Repeat until
   GO or a hard stop.
4. Cap: **3** ship→fix cycles without clearing blockers → stop and ask.
5. If the ship loop left uncommitted fixes, commit them with
   `git-workflow-and-versioning` (one or more atomic commits). If nothing to
   commit, skip git.

### 5. Next spec

If a capability map has another incomplete module whose dependencies are done:
generate/load its plan (step 2) and continue from step 3 **without** waiting
for another approval (the initial checkpoint covered the map order).

If this was a single spec, or every module is done: run one **final**
`shipping-and-launch` pass over the whole initiative (same ship→fix→git-if-needed
loop), then summarize.

## Hard stops (do not push through)

Stop and ask the user when:

- a test cannot pass or the build breaks without an obvious fix →
  `debugging-and-error-recovery`
- the spec is ambiguous, or a task needs a decision the spec does not cover
- high-risk / irreversible work (auth, destructive migrations, payments,
  secrets, deploys, anything not undoable with `git revert`) →
  `doubt-driven-development` and explicit sign-off
- review or ship fix caps are hit

After the user resolves a blocker, they re-invoke `/as-build-auto-loop` — resume
from the next pending task (or the next incomplete module).

## Rules

1. Specs are inputs. Never invent or silently expand requirements.
2. Only core skills in the table above — no `/as-*` wrappers.
3. Review loop completes **before** the task commit. Ship loop completes
   **before** moving to the next module.
4. One commit per task; ship-fix commits only when the ship loop changed files.
5. Autonomous between tasks and modules after the checkpoint — not faster per
   task, only fewer human steps between them.

## End summary

Report: modules/specs completed, tasks completed, commits made, review/ship
cycles run, anything skipped or left for the user.
