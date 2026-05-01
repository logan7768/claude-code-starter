#!/usr/bin/env bash
# Inject git branch + status at session start.
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
[ ! -d .git ] && exit 0
branch=$(git branch --show-current 2>/dev/null || echo "detached")
modified=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
context="Git context — branch: $branch | modified files: $modified"
jq -n --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
