#!/usr/bin/env bash
# Auto-format files after Write/Edit/MultiEdit.
# Only runs if a formatter is available and the file extension matches.
set -uo pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0
case "$file_path" in
  *.py)
    command -v black >/dev/null && black --quiet "$file_path" 2>/dev/null
    ;;
  *.js|*.ts|*.jsx|*.tsx|*.json|*.md|*.css|*.html)
    command -v prettier >/dev/null && prettier --write --log-level=silent "$file_path" 2>/dev/null
    ;;
  *.go)
    command -v gofmt >/dev/null && gofmt -w "$file_path" 2>/dev/null
    ;;
  *.rs)
    command -v rustfmt >/dev/null && rustfmt --quiet "$file_path" 2>/dev/null
    ;;
esac
exit 0
