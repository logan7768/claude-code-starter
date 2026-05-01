#!/usr/bin/env bash
# Pre-tool secret scanner for Write/Edit/MultiEdit.
# Iterates ALL edits in MultiEdit (the previous version only checked the first one).
set -uo pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
deny() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}
# Skip template files (intentional placeholders)
# Use basename so bare ".env.example" filenames (no path prefix) are also matched
basename=$(basename "$file_path")
case "$basename" in
  .env.example|.env.template|*.env.example|*.env.template) exit 0 ;;
esac
# Block direct writes to .env (must be manual)
# Uses basename so bare ".env" (no path prefix) is also caught — fixes round-3 bypass
case "$basename" in
  .env|.env.*) deny "Direct write to .env file '$basename' is blocked — edit manually" ;;
esac
# Collect all content to scan: Write.content, Edit.new_string, MultiEdit.edits[].new_string
contents=$(echo "$input" | jq -r '
  [
    (.tool_input.content // empty),
    (.tool_input.new_string // empty),
    (.tool_input.edits[]?.new_string // empty)
  ] | join("\n")
')
# NOTE: '"'"' is the standard bash idiom to embed a single quote in a single-quoted string.
# This avoids \x27 hex escapes which are NOT supported by BSD grep on macOS.
Q='["'"'"']'  # character class matching either " or '
patterns=(
  "api[_-]?key[[:space:]]*=[[:space:]]*${Q}[[:alnum:]_-]{20,}"
  "password[[:space:]]*=[[:space:]]*${Q}[^\"']{8,}"
  "token[[:space:]]*=[[:space:]]*${Q}[[:alnum:]_-]{20,}"
  "secret[[:space:]]*=[[:space:]]*${Q}[[:alnum:]_-]{20,}"
  'AKIA[0-9A-Z]{16}'
  'sk-[a-zA-Z0-9]{32,}'
  'sk-ant-[a-zA-Z0-9-]{32,}'
  'ghp_[a-zA-Z0-9]{36}'
  'github_pat_[a-zA-Z0-9_]{82}'
  'glpat-[a-zA-Z0-9_-]{20}'
  'xox[baprs]-[a-zA-Z0-9-]{10,}'
  'AIza[0-9A-Za-z_-]{35}'
  '-----BEGIN [A-Z ]+PRIVATE KEY-----'
)
for p in "${patterns[@]}"; do
  if echo "$contents" | grep -qE "$p"; then
    deny "Potential secret detected (pattern: $p). Use environment variables or a secret manager."
  fi
done
exit 0
