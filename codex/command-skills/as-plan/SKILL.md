---
name: as-plan
description: >-
  Breaks work into small verifiable tasks with acceptance criteria and dependency
  ordering. Use when the user invokes $as-plan or asks to plan tasks from a spec.
---

# as-plan

Codex entry point for the agent-skills lifecycle. Invoke as `$as-plan`.

## Prerequisite

The **agent-skills** Codex plugin must be installed and enabled.

## User input

Text after `$as-plan` is **$ARGUMENTS** — optional scope hints or constraints for the plan.

## Workflow

1. Invoke and fully follow the `planning-and-task-breakdown` skill from the agent-skills plugin (`$planning-and-task-breakdown`).
2. Apply the kickoff steps below.

Read the existing spec (SPEC.md or equivalent) and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to tasks/plan.md and task list to tasks/todo.md.
