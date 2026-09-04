---
name: as-webperf
description: >-
  Runs a web performance audit via the web-performance-auditor persona. Use when
  the user invokes $as-webperf or asks for a Core Web Vitals or Lighthouse audit.
---

# as-webperf

Codex entry point for the agent-skills lifecycle. Invoke as `$as-webperf`.

## Prerequisite

The **agent-skills** Codex plugin must be installed and enabled.

## User input

Text after `$as-webperf` is **$ARGUMENTS** — target URL, page name, artifact paths, or scope hints.

`$as-webperf` targets web applications specifically. Do not use it for utility libraries, CLIs, or server-only code with no browser-facing output.

## Determine the mode

**Deep mode** — activate when any of these is available:
- A Lighthouse JSON report file (e.g. `npx lighthouse <url> --output json --output-path ./report.json`, or Chrome DevTools MCP `lighthouse_audit`)
- A PageSpeed Insights JSON response (includes Lighthouse + CrUX)
- A CrUX API response (requires `CRUX_API_KEY` or `GOOGLE_API_KEY`)
- A DevTools performance trace
- A live URL plus Chrome DevTools MCP / CLI available in the harness
- Local Chrome DevTools MCP CLI output the user pastes in

**Quick mode** — default when none of the above are available. The agent scans source code for structural anti-patterns and labels every finding as `potential impact`.

## Run the audit

Adopt the `web-performance-auditor` persona from `agents/web-performance-auditor.md` in the agent-skills checkout (or plugin cache under `~/.codex/plugins/cache/agent-skills/`). If a parallel subagent mechanism is available, run the persona there; otherwise run it in this session.

Pass explicitly:
- The files, components, or diff under review
- Any artifact paths (Lighthouse JSON, PSI JSON, CrUX response, trace) or pasted JSON content from $ARGUMENTS
- The target URL or page name when known
- A note on which mode you expect (Quick or Deep), so missing Deep inputs are surfaced

Also apply `$performance-optimization` for remediation guidance after the audit when the user asks for fixes.

The audit returns a scorecard (only populated with sourced values), a ranked list of findings, positive observations, and proactive recommendations.

## Output

Return the full audit report to the user. No synthesis or merge step is needed — this is a single-persona command.
