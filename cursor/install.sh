#!/usr/bin/env bash
# Symlink cursor/command-skills/* into ~/.cursor/skills/
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}"
SOURCE="$REPO_ROOT/cursor/command-skills"

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
