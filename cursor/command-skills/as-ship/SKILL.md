---
name: as-ship
description: >-
  Runs the pre-launch checklist via parallel specialist reviews, then synthesizes
  a go/no-go decision. Use when the user invokes /as-ship or asks if changes are
  ready to ship.
disable-model-invocation: true
---

# as-ship

## User input

Text after `/as-ship` is **$ARGUMENTS** — optional context (release notes, target environment, scope).

## Workflow

1. Read and follow `.cursor/skills/shipping-and-launch/SKILL.md`.
2. Run the fan-out orchestration below.

`/as-ship` is a **fan-out orchestrator**. It runs three specialist personas in parallel against the current change, then merges their reports into a single go/no-go decision with a rollback plan.

## Phase A — Parallel fan-out

Launch three Task subagents concurrently. **Issue all three Task tool calls in a single assistant turn so they execute in parallel** — sequential calls defeat the purpose of this command.

For each subagent, use `subagent_type: generalPurpose` and include the full persona prompt from the agent-skills repo (or project copy if present):

1. **code-reviewer** — Read `agents/code-reviewer.md` (from the agent-skills checkout or project). Run a five-axis review (correctness, readability, architecture, security, performance) on the staged changes or recent commits. Output the standard review template.
2. **security-auditor** — Read `agents/security-auditor.md`. Run a vulnerability and threat-model pass. Check OWASP Top 10, secrets handling, auth/authz, dependency CVEs. Output the standard audit report.
3. **test-engineer** — Read `agents/test-engineer.md`. Analyze test coverage for the change. Identify gaps in happy path, edge cases, error paths, and concurrency scenarios. Output the standard coverage analysis.

If the Task tool is unavailable, run each persona sequentially in separate passes and treat their outputs as if returned in parallel — the merge phase still works.

Constraints:
- Subagents cannot spawn other subagents — do not let one persona delegate to another.
- Each subagent returns only its report to this main session.

## Phase B — Merge in main context

Once all three reports are back, the main agent (not a sub-persona) synthesizes them:

1. **Code Quality** — Aggregate Critical/Important findings from `code-reviewer` and any failing tests, lint, or build output. Resolve duplicates between reviewers.
2. **Security** — Promote any Critical/High `security-auditor` findings to launch blockers. Cross-reference with `code-reviewer`'s security axis.
3. **Performance** — Pull from `code-reviewer`'s performance axis; cross-check Core Web Vitals if applicable.
4. **Accessibility** — Verify keyboard nav, screen reader support, contrast (not covered by the three personas — handle directly here, or use `references/accessibility-checklist.md`).
5. **Infrastructure** — Env vars, migrations, monitoring, feature flags. Verify directly.
6. **Documentation** — README, ADRs, changelog. Verify directly.

## Phase C — Decision and rollback

Produce a single output:

```markdown
## Ship Decision: GO | NO-GO

### Blockers (must fix before ship)
- [Source persona: Critical finding + file:line]

### Recommended fixes (should fix before ship)
- [Source persona: Important finding + file:line]

### Acknowledged risks (shipping anyway)
- [Risk + mitigation]

### Rollback plan
- Trigger conditions: [what signals would prompt rollback]
- Rollback procedure: [exact steps]
- Recovery time objective: [target]

### Specialist reports (full)
- [code-reviewer report]
- [security-auditor report]
- [test-engineer report]
```

## Rules

1. The three Phase A personas run in parallel — never sequentially when Task tool is available.
2. Personas do not call each other. The main agent merges in Phase B.
3. The rollback plan is mandatory before any GO decision.
4. If any persona returns a Critical finding, the default verdict is NO-GO unless the user explicitly accepts the risk.
5. **Skip the fan-out only if all of the following are true:** the change touches 2 files or fewer, the diff is under 50 lines, and it does not touch auth, payments, data access, or config/env. Otherwise, default to fan-out.
