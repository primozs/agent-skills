---
name: as-code-simplify
description: >-
  Simplifies code for clarity and maintainability without changing behavior. Use
  when the user invokes $as-code-simplify or asks to simplify recent changes.
---

# as-code-simplify

Codex entry point for the agent-skills lifecycle. Invoke as `$as-code-simplify`.

## Prerequisite

The **agent-skills** Codex plugin must be installed and enabled.

## User input

Text after `$as-code-simplify` is **$ARGUMENTS** — optional scope (files or area to simplify).

## Workflow

1. Invoke and fully follow the `code-simplification` skill from the agent-skills plugin (`$code-simplification`).
2. Apply the kickoff steps below.

Simplify recently changed code (or the specified scope) while preserving exact behavior:

1. Read project rules (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/*.mdc` if present) and study project conventions
2. Identify the target code — recent changes unless a broader scope is specified in $ARGUMENTS
3. Understand the code's purpose, callers, edge cases, and test coverage before touching it
4. Scan for simplification opportunities:
   - Deep nesting → guard clauses or extracted helpers
   - Long functions → split by responsibility
   - Nested ternaries → if/else or switch
   - Generic names → descriptive names
   - Duplicated logic → shared functions
   - Dead code → remove after confirming
5. Apply each simplification incrementally — run tests after each change
6. Verify all tests pass, the build succeeds, and the diff is clean

If tests fail after a simplification, revert that change and reconsider. Use `$code-review-and-quality` to review the result.
