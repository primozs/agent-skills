---
name: as-review
description: >-
  Conducts a five-axis code review — correctness, readability, architecture,
  security, performance. Use when the user invokes $as-review or asks for a code review.
---

# as-review

Codex entry point for the agent-skills lifecycle. Invoke as `$as-review`.

## Prerequisite

The **agent-skills** Codex plugin must be installed and enabled.

## User input

Text after `$as-review` is **$ARGUMENTS** — optional scope (files, PR, or focus area).

## Workflow

1. Invoke and fully follow the `code-review-and-quality` skill from the agent-skills plugin (`$code-review-and-quality`).
2. Apply the kickoff steps below.

Review the current changes (staged or recent commits) across all five axes:

1. **Correctness** — Does it match the spec? Edge cases handled? Tests adequate?
2. **Readability** — Clear names? Straightforward logic? Well-organized?
3. **Architecture** — Follows existing patterns? Clean boundaries? Right abstraction level?
4. **Security** — Input validated? Secrets safe? Auth checked? (Use `$security-and-hardening`)
5. **Performance** — No N+1 queries? No unbounded ops? (Use `$performance-optimization`)

Categorize findings as Critical, Important, or Suggestion.
Output a structured review with specific file:line references and fix recommendations.
