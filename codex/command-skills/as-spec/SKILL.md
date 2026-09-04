---
name: as-spec
description: >-
  Starts spec-driven development — writes a structured specification before code.
  Use when the user invokes $as-spec or asks to write a spec or SPEC.md.
---

# as-spec

Codex entry point for the agent-skills lifecycle. Invoke as `$as-spec`.

## Prerequisite

The **agent-skills** Codex plugin must be installed and enabled so workflow skills
(`$spec-driven-development`, etc.) are available.

## User input

Text after `$as-spec` is **$ARGUMENTS** — the feature or scope to specify. Incorporate it into clarifying questions and the final spec.

## Workflow

1. Invoke and fully follow the `spec-driven-development` skill from the agent-skills plugin (`$spec-driven-development`).
2. Apply the kickoff steps below.

Begin by understanding what the user wants to build. Ask clarifying questions about:
1. The objective and target users
2. Core features and acceptance criteria
3. Tech stack preferences and constraints
4. Known boundaries (what to always do, ask first about, and never do)

Then generate a structured spec covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries.

If the request bundles several independently testable capabilities, first propose a capability map (module ids, dependency direction, build order) per the skill's Phase 0 and get it approved, then spec each module in dependency order.

Save the spec as SPEC.md in the project root and confirm with the user before proceeding.
