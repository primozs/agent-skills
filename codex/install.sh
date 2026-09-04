#!/usr/bin/env bash
# Symlink codex/command-skills/* into ~/.codex/skills/
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
SOURCE="$REPO_ROOT/codex/command-skills"

skills=(as-spec as-plan as-build as-test as-review as-code-simplify as-ship as-webperf as-ponytail-audit)

mkdir -p "$TARGET"

for skill in "${skills[@]}"; do
  if [[ ! -d "$SOURCE/$skill" ]]; then
    echo "error: missing $SOURCE/$skill" >&2
    exit 1
  fi
  ln -sfn "$SOURCE/$skill" "$TARGET/$skill"
  echo "linked $TARGET/$skill -> $SOURCE/$skill"
done

echo "Done. ${#skills[@]} command skills installed under $TARGET"
echo "Restart Codex (or start a new session), then invoke with \$as-spec, \$as-plan, etc."
echo "Requires the agent-skills plugin: codex plugin add agent-skills@agent-skills"
