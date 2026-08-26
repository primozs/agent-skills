#!/usr/bin/env bash
# Set up global agent-skills symlinks for pi (and other harnesses).
# Run once per machine. Idempotent.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Skills: ~/.agents/skills/ -> repo/skills/
TARGET_SKILLS="${AGENT_SKILLS_DIR:-$HOME/.agents/skills}"
mkdir -p "$(dirname "$TARGET_SKILLS")"
if [[ -L "$TARGET_SKILLS" ]]; then
  echo "skills symlink already exists: $TARGET_SKILLS"
else
  ln -sfn "$REPO_ROOT/skills" "$TARGET_SKILLS"
  echo "linked $TARGET_SKILLS -> $REPO_ROOT/skills"
fi

# References: ~/.agents/references/ -> repo/references/
TARGET_REFS="${AGENT_REFS_DIR:-$HOME/.agents/references}"
if [[ -L "$TARGET_REFS" ]]; then
  echo "references symlink already exists: $TARGET_REFS"
else
  ln -sfn "$REPO_ROOT/references" "$TARGET_REFS"
  echo "linked $TARGET_REFS -> $REPO_ROOT/references"
fi

# Agents (personas): ~/.agents/agents/ -> repo/agents/
TARGET_AGENTS="${AGENT_AGENTS_DIR:-$HOME/.agents/agents}"
if [[ -L "$TARGET_AGENTS" ]]; then
  echo "agents symlink already exists: $TARGET_AGENTS"
else
  ln -sfn "$REPO_ROOT/agents" "$TARGET_AGENTS"
  echo "linked $TARGET_AGENTS -> $REPO_ROOT/agents"
fi

# Commands extension: ~/.pi/agent/extensions/agent-skills-commands.ts -> repo/pi/agent-skills-commands.ts
TARGET_EXT="${PI_EXT_DIR:-$HOME/.pi/agent/extensions}"
mkdir -p "$TARGET_EXT"
if [[ -L "$TARGET_EXT/agent-skills-commands.ts" ]]; then
  echo "extension symlink already exists: $TARGET_EXT/agent-skills-commands.ts"
else
  ln -sfn "$REPO_ROOT/pi/agent-skills-commands.ts" "$TARGET_EXT/agent-skills-commands.ts"
  echo "linked $TARGET_EXT/agent-skills-commands.ts -> $REPO_ROOT/pi/agent-skills-commands.ts"
fi

echo ""
echo "Done. Global symlinks installed under ~/.agents/ and ~/.pi/agent/extensions/"
echo ""
echo "Per-repo setup: copy pi/AGENTS.md.example into your project's AGENTS.md"
echo "(or append the relevant sections). No .pi/settings.json needed —"
echo "enableSkillCommands defaults to true."
echo ""
echo "Commands available: /as-spec /as-plan /as-build /as-test /as-review /as-code-simplify /as-ship /as-webperf"
