# Workflows

How to use agent-skills slash commands across the development lifecycle — for new features, refactors, performance work, and legacy migrations.

For installation and tool-specific setup, see [getting-started.md](getting-started.md). For greenfield vs brownfield rollout strategy, see [adoption-guide.md](adoption-guide.md). For orchestration patterns and personas, see [agents.md](agents.md).

---

## Commands and the lifecycle

Eight slash commands map to the development lifecycle. Each activates the right skills automatically.

```
  DEFINE          PLAN           BUILD          VERIFY         REVIEW          SHIP
 ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐
 │ Idea │ ───▶ │ Spec │ ───▶ │ Code │ ───▶ │ Test │ ───▶ │  QA  │ ───▶ │  Go  │
 │Refine│      │  PRD │      │ Impl │      │Debug │      │ Gate │      │ Live │
 └──────┘      └──────┘      └──────┘      └──────┘      └──────┘      └──────┘
  /spec          /plan          /build        /test         /review       /ship
```

| Command | Skill(s) | Key principle |
|---------|----------|---------------|
| `/spec` | spec-driven-development | Spec before code |
| `/plan` | planning-and-task-breakdown | Small, atomic tasks |
| `/build` | incremental-implementation + test-driven-development | One slice at a time |
| `/build auto` | planning-and-task-breakdown → incremental-implementation + TDD | Whole plan, one approval |
| `/test` | test-driven-development | Tests are proof |
| `/review` | code-review-and-quality | Improve code health |
| `/code-simplify` | code-simplification | Clarity without behavior change |
| `/webperf` | web-performance-auditor + performance-optimization | Measure before you optimize |
| `/ship` | shipping-and-launch | Faster is safer |

On Cursor, the same commands are available as `/as-spec`, `/as-plan`, `/as-build`, and so on.

**You are the orchestrator.** There is no automated lifecycle runner. You run commands in an order that fits the work, carrying context and commit history between steps. Human judgment between phases catches wrong-direction work early.

---

## How the commands relate (common confusion)

`/build`, `/test`, and `/review` are **lifecycle phases**, not nested sub-steps of each other.

| Command | Role |
|---------|------|
| `/build` | Implement plan tasks. Each task runs the full TDD loop and commits. |
| `/test` | Standalone prove-it or bug-fix TDD when you are **not** going through `/build`. |
| `/review` | Pre-merge quality gate on staged or recent commits. Read-only analysis. |
| `/code-simplify` | Behavior-preserving clarity refactor. Not a substitute for `/build` or perf work. |

**`/build` already includes testing.** Every task: RED → GREEN → full suite → build → commit → mark complete. You do not need `/test` after every build task — `/test` is for targeted work outside the build loop (characterization tests before a refactor, reproducing a bug, and so on).

**`/review` is safe to run anytime** — including mid-build after a few committed slices. It does not mutate plan state or task status. If review finds issues in already-committed work, fix them (new commit), then resume build.

---

## Feature development (greenfield)

The default path for new capability in a codebase with good conventions and test coverage.

### Full lifecycle

```
/spec  →  /plan  →  /build  →  /review  →  /ship
                      ↑
                   /test (optional, for ad-hoc prove-it work)
```

### Step by step

**1. Define — `/spec`**

Write `SPEC.md` (repo root), `docs/SPEC.md`, or a file under `spec/`. Cover objectives, boundaries, acceptance criteria, and how you will know it is done. Do not write code during this phase.

**2. Plan — `/plan`**

Produce `tasks/plan.md` and `tasks/todo.md` (or your project's external tracker). Tasks should be small, ordered by dependency, and each have explicit acceptance criteria.

**3. Build — `/build` or `/build auto`**

See [Build modes](#build-modes) below.

**4. Review — `/review`**

Five-axis review (correctness, readability, architecture, security, performance). Findings categorized as Critical, Important, or Suggestion. Run before every merge.

**5. Ship — `/ship`**

Pre-launch checklist, staged rollout, monitoring, rollback plan.

### Optional mid-lifecycle commands

| When | Command |
|------|---------|
| Code works but feels over-engineered | `/code-simplify` then `/review` |
| Web app with perf requirements | `/webperf` (baseline before and after changes) |
| High-stakes decision in flight | Pause for `doubt-driven-development` sign-off |
| Something broke during build | `debugging-and-error-recovery`, then resume `/build` |

---

## Build modes

`/build` has two modes. Autonomous mode is not faster *per task* — it runs the same test-driven loop — it only removes human stepping *between* tasks.

### Default: one task (`/build`)

Implement the **next pending** task from the plan, then **stop**.

For each task:

1. Read acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Write a failing test (RED)
4. Implement minimum code to pass (GREEN)
5. Run the full test suite
6. Run the build
7. Commit with a descriptive message
8. Mark the task complete and **stop**

Use when you want to inspect each slice before continuing.

### Autonomous: whole plan (`/build auto` or `/build all`)

One plan approval, then every task in dependency order — one commit per task.

1. **Require a spec** at a known path (`SPEC.md`, `docs/SPEC.md`, or `spec/*`). If none exists, run `/spec` first.
2. **Establish a clean baseline.** Uncommitted changes outside planning artifacts must be committed, stashed, or explicitly handled — autonomous commits must not absorb unrelated local work.
3. **Plan if needed.** Generate `tasks/plan.md` when missing.
4. **Single checkpoint.** Present the full plan; wait for unambiguous approval ("approve", "go", "yes"). Commit `tasks/plan.md` as a preparatory commit if newly generated.
5. **Execute every task** in dependency order. Stage only files that task touched plus its status update — never blind `git add -A`. One commit per task for clean rollback.
6. **Stop and ask** (do not push through) when:
   - a test cannot pass or the build breaks without an obvious fix
   - the spec is ambiguous or a task needs a decision the spec does not cover
   - a task is high-risk or irreversible (auth, migrations, payments, secrets, anything you cannot undo with `git revert`)

   After the user resolves a blocker, re-invoke `/build auto` — it resumes from the **next pending** task.
7. **Summarize** at the end: tasks completed, tests added, commits made, anything flagged.

Use when you trust the plan and do not need to inspect every slice.

### Stopping mid-build

Commits during build are **save points**, not "the spec is done."

| Situation | What happened | What to do next |
|-----------|---------------|-----------------|
| Task finished and committed, then you stopped | Normal | `/build auto` or `/build` — picks up next pending task |
| You interrupted auto after task 3 of 10 | Normal | Resume with `/build auto`. Tasks 1–3 are revertable save points. |
| Task failed mid-loop (test won't pass) | Auto stops | Fix the problem, then `/build auto` again. Failed task stays pending. |
| You want quality check mid-spec | Safe | `/review` on recent commits, fix findings, then resume build |

You do **not** normally re-run completed tasks unless review or testing exposed a defect in an already-shipped slice.

### When to pick which mode

| Goal | Mode |
|------|------|
| Inspect each slice before continuing | `/build` repeatedly |
| Trust the plan, minimal interruption | `/build auto` |
| Hit a blocker mid-auto | Fix → `/build auto` to resume |
| Check quality of work so far | `/review` — safe anytime |
| Reproduce or fix one specific bug | `/test` |
| All plan tasks done, ready to merge | `/review` → `/ship` |

---

## Refactoring and optimizing old code

Refactor and optimize work uses a **shorter lifecycle** than greenfield features. You often enter at BUILD or REVIEW, not DEFINE. A full `/spec` is required only for large or risky changes.

### Choose your path first

| Goal | Primary skill | Typical commands |
|------|---------------|------------------|
| Same behavior, clearer code | code-simplification | `/code-simplify` → `/review` |
| Faster / lighter (proven bottleneck) | performance-optimization | measure → `/build` or `/test` → `/webperf` (web) |
| Replace or remove old system | deprecation-and-migration + incremental-implementation | `/spec` → `/plan` → `/build` |
| Scope unclear — whole area is messy | code-review-and-quality | `/review [scope]` → pick a path below |

---

### Path A: Clarity refactor (behavior must not change)

Use when code works but is hard to read, deeply nested, duplicated, or over-abstracted.

```
Understand  →  (add tests if missing)  →  simplify in slices  →  review  →  ship
```

#### 1. Understand first (Chesterton's Fence)

Before editing, answer:

- What is this code's responsibility?
- What calls it? What does it call?
- What are the edge cases and error paths?
- Are there tests that define expected behavior?
- Why might it have been written this way? (Performance? Platform constraint? Historical reason?)
- What does git blame show?

If you cannot answer these, read more context before changing anything. The weird retry loop may be load-bearing.

#### 2. Safety net: characterization tests

If coverage is thin, pin down **current** behavior before touching structure:

```
/test "lock in current behavior of UserService.validate"
```

These tests document what the code does today — not what it should do. They are the refactor safety net. On brownfield code, **no characterization tests means no refactor.**

#### 3. Simplify incrementally

```
/code-simplify src/services/UserService.ts
```

Or scope it: `/code-simplify the auth middleware`.

The code-simplification skill applies one simplification at a time, runs tests after each change, and preserves exact behavior. If tests fail after a simplification, revert that change and reconsider.

#### 4. Review and ship

```
/review
/ship
```

#### Path A rules

- **Separate refactor PRs from feature and bug PRs.** Mixed diffs are hard to review and revert.
- **One logical change per commit** — extract helper, run tests, commit; rename, run tests, commit.
- **No drive-by refactors** of unrelated files while working in one module.
- **Rule of 500:** if a refactor would touch more than 500 lines, use automation (codemods, AST transforms) rather than manual edits.

#### Path A lifecycle (by size)

| Size | Lifecycle |
|------|-----------|
| Small (one file/module, tests exist) | `/code-simplify [scope]` → `/review` → `/ship` |
| Medium (multi-file, weak tests) | `/test` (characterization) → `/plan` → `/build` (repeat) → `/review` → `/ship` |

---

### Path B: Performance optimization (measure first)

Use when something is measurably slow — page load, API latency, N+1 queries, bundle size.

```
Measure baseline  →  find real bottleneck  →  fix one thing  →  measure again  →  guard  →  ship
```

#### 1. Measure — do not guess

The performance-optimization skill is explicit: optimize only what measurements prove matters.

**Web applications:**

```
/webperf
```

Deep mode when you have Lighthouse JSON, PageSpeed Insights, CrUX, or DevTools traces. Quick mode scans source for structural anti-patterns and labels findings as *potential impact*.

**Backend / API / database:**

Profile with your stack's tools (query logs, APM, `EXPLAIN`, load tests) and provide results to the agent. Paste profiler output or name the slow endpoint.

#### 2. Spec — only when needed

| Scope | Spec? |
|-------|-------|
| Small fix (one query, one lazy-load, one index) | Skip `/spec` |
| Multi-area perf initiative (checkout flow, entire API layer) | Short `/spec` with **budgets** — e.g. LCP ≤ 2.5s, p95 checkout API ≤ 200ms |

#### 3. Plan slices by bottleneck

```
/plan
```

Example tasks:

- Task 1: Add index + fix N+1 in `OrderRepository`
- Task 2: Code-split admin dashboard route
- Task 3: Add perf regression test or budget check in CI

Order by impact, not by file layout.

#### 4. Build with proof

```
/build          # one slice at a time — often better for perf (verify each fix)
/build auto     # trusted plan, many slices
```

For perf fixes, `/test` often means: write a test or benchmark that fails on the slow path, fix, confirm improvement.

#### 5. Verify improvement

Re-run `/webperf` or your profiler. If numbers did not move, **revert** — the "optimization" added complexity for nothing.

#### 6. Review and ship

```
/review
/ship
```

Add monitoring or CI budget checks to **guard** against regression (observability-and-instrumentation).

#### Path B rules

- **Do not use `/code-simplify` as the perf path.** Simpler code can be slower. Simplify after perf work is done and measured, if the optimized code got messy.
- **Synthetic + RUM:** Lighthouse/DevTools for reproducible diagnosis; real-user metrics to confirm the fix helped actual users.
- **Core Web Vitals targets:** LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1 (good thresholds).

---

### Path C: Structural rewrite / replacing old code

Use when migrating off a legacy module, consolidating duplicates, or changing architecture — not just cleaning up.

```
Spec (constraints + migration)  →  Plan (risk-ordered slices)  →  Build  →  Deprecate old  →  Review  →  Ship
```

#### 1. Spec — what changes, what must stay compatible

```
/spec
```

Cover:

- **Objective** — what replaces what
- **Behavior contract** — what callers depend on (Hyrum's Law: undocumented behavior gets depended on, including bugs)
- **Migration strategy** — strangler fig, feature flag, parallel run, big bang?
- **Rollback plan** — how to revert if migration fails
- **Non-goals** — what you are *not* rewriting

#### 2. Plan — risk-first, small slices

```
/plan
```

Good refactor plan ordering:

1. Add tests around legacy behavior (characterization tests)
2. Introduce new implementation behind a flag
3. Route one caller at a time
4. Delete old path only when nothing calls it

Follow deprecation-and-migration: **build the replacement before removing the old thing.**

#### 3. Build

```
/build auto     # large multi-task migration with trusted plan
/build          # one risky slice at a time — often better for legacy
```

High-risk slices (auth, payments, data migration) trigger automatic stops in `/build auto`. Use doubt-driven-development for explicit sign-off.

#### 4. Verify continuously

```
/test           # repro tests for edge cases discovered during migration
/review         # mid-migration reviews on committed slices are fine
```

#### 5. Remove old code and ship

Document architectural decisions in an ADR when appropriate. Then `/ship`.

---

### Path D: "This whole area is a mess" (explore first)

When scope is unclear:

```
1. /review src/legacy/          # five-axis review, ranked findings
2. Pick ONE theme (not everything at once)
3. Enter Path A, B, or C for that theme
```

Do not try to refactor an entire subsystem in one pass. Pick the highest-leverage theme (worst hotspot, known perf bottleneck, duplicate implementation) and run the appropriate path.

---

## Feature work vs refactor/optimize

| | Feature work | Refactor / optimize |
|---|--------------|---------------------|
| `/spec` | Usually required | Light spec only for large/risky changes |
| Behavior | New | Must stay the same (unless migrating) |
| `/test` | Drives new behavior | Locks in *existing* behavior first |
| `/code-simplify` | Often at the end | *Is* the main work (Path A) |
| `/webperf` | Optional | Baseline *before* optimizing (Path B) |
| Commits | One per plan task | One per simplification or perf fix |
| PR discipline | Feature PRs | Refactor PRs separate from feature/bug PRs |

---

## Brownfield adoption sequence

For established codebases, adopt skills in phases before running the full lifecycle everywhere. See [adoption-guide.md](adoption-guide.md) for detail.

```
Phase 1  context-engineering, code-review-and-quality, debugging-and-error-recovery
Phase 2  test-driven-development (characterization), code-simplification, git-workflow-and-versioning
Phase 3  Full lifecycle for NEW work only (/spec → /plan → /build → /review)
Phase 4  deprecation-and-migration, observability-and-instrumentation, performance-optimization
```

The two paths (greenfield and brownfield) converge on the same steady state: full lifecycle for new work, always-on TDD and git discipline, review gates before merge.

---

## Decision guide

### "What command do I run next?"

| Situation | Next command |
|-----------|--------------|
| New feature, no spec yet | `/spec` |
| Have spec, no tasks | `/plan` |
| Have plan, want one slice | `/build` |
| Have plan, trust it fully | `/build auto` |
| Blocked mid-auto, fixed issue | `/build auto` (resumes) |
| Bug or behavior to prove | `/test` |
| Code works, want clarity | `/code-simplify` |
| Slow web app, need baseline | `/webperf` |
| Ready to merge | `/review` |
| Ready to deploy | `/ship` |
| Legacy module, no tests | `/test` (characterization) first — then Path A or C |
| Unsure what to fix in legacy area | `/review [scope]` |

### "Can I run review or test while build is paused?"

Yes.

- **`/review`** — safe anytime. Read-only. Fix findings with new commits, then resume `/build`.
- **`/test`** — for targeted prove-it work (characterization tests, bug repro). Does not conflict with plan state.
- After fixes from review or test, continue with **`/build`** or **`/build auto`** for the next pending plan task.

---

## Artifacts and file conventions

| Artifact | Path | Created by |
|----------|------|------------|
| Specification | `SPEC.md`, `docs/SPEC.md`, or `spec/*` | `/spec` |
| Implementation plan | `tasks/plan.md` | `/plan` |
| Task checklist | `tasks/todo.md` | `/plan` |
| Commits | git history | `/build`, `/code-simplify`, `/test` |

`/build auto` looks for specs only at known paths. A README or arbitrary doc does **not** count as a spec.

---

## Principles that apply to every workflow

1. **Verify, don't assume.** Tests pass, build succeeds, behavior confirmed. See [definition-of-done.md](../references/definition-of-done.md).
2. **Atomic commits.** One logical change per commit. ~100 lines per commit/PR is the target. See git-workflow-and-versioning.
3. **Scope discipline.** Touch only what the task requires. Note adjacent improvements; do not fix them unasked.
4. **Separate concerns.** Refactoring and features do not belong in the same PR.
5. **Chesterton's Fence on legacy.** Understand why code exists before removing or simplifying it.
6. **Measure before optimizing.** No perf work without baseline data.
7. **Characterization tests before refactor.** On brownfield code, this is non-negotiable.

---

## Related documentation

| Document | Covers |
|----------|--------|
| [adoption-guide.md](adoption-guide.md) | Greenfield vs brownfield rollout |
| [getting-started.md](getting-started.md) | Installation and loading skills |
| [agents.md](agents.md) | Personas, orchestration patterns |
| [orchestration-patterns.md](../references/orchestration-patterns.md) | Sequential pipeline, fan-out, anti-patterns |
| [definition-of-done.md](../references/definition-of-done.md) | Project-wide quality bar |
