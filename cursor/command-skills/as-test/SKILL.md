---
name: as-test
description: >-
  Runs the TDD workflow — write failing tests, implement, verify. Use when the user
  invokes /as-test or asks to test-drive a change or fix a bug with Prove-It.
disable-model-invocation: true
---

# as-test

## User input

Text after `/as-test` is **$ARGUMENTS** — the feature, behavior, or bug to test-drive.

## Workflow

1. Read and follow `.cursor/skills/test-driven-development/SKILL.md`.
2. Apply the kickoff steps below.

For new features:
1. Write tests that describe the expected behavior (they should FAIL)
2. Implement the code to make them pass
3. Refactor while keeping tests green

For bug fixes (Prove-It pattern):
1. Write a test that reproduces the bug (must FAIL)
2. Confirm the test fails
3. Implement the fix
4. Confirm the test passes
5. Run the full test suite for regressions

For browser-related issues, also read and follow `.cursor/skills/browser-testing-with-devtools/SKILL.md` to verify with Chrome DevTools MCP.
