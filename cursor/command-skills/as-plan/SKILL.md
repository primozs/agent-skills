---
name: as-plan
description: >-
  Breaks work into small verifiable tasks with acceptance criteria and dependency
  ordering. Use when the user invokes /as-plan or asks to plan tasks from a spec.
disable-model-invocation: true
---

# as-plan

## User input

Text after `/as-plan` is **$ARGUMENTS** — optional scope hints or constraints for the plan.

## Workflow

1. Read and follow `.cursor/skills/planning-and-task-breakdown/SKILL.md`.
2. Apply the kickoff steps below.

Read the existing spec (SPEC.md or equivalent) and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to tasks/plan.md and task list to tasks/todo.md.
