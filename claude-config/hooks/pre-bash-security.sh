#!/usr/bin/env bash
# Pre-tool security gate for Bash commands.
# Outputs Anthropic-spec JSON (hookSpecificOutput.permissionDecision).
set -uo pipefail
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')
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
ask() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}
# Empty output = allow (Anthropic spec)
allow() { exit 0; }
# === DENY: catastrophic patterns ===
# Detect any destructive rm form (handles -rf, -r -f split, --recursive, --force, /bin/rm, \rm)
HAS_RM_DEL=0
if echo "$cmd" | grep -qE '(^|[[:space:];|&(/])\\?(.?/?(bin/|usr/bin/)?)?rm[[:space:]]'; then
  if echo "$cmd" | grep -qE '\-[a-zA-Z]*[rRfF]'; then HAS_RM_DEL=1; fi
  if echo "$cmd" | grep -qE '\--(recursive|force|no-preserve-root)'; then HAS_RM_DEL=1; fi
fi
if [ "$HAS_RM_DEL" = 1 ]; then
  # Filesystem root (handles 'rm -rf /', 'rm -rf / file', 'rm -rf /;')
  if echo "$cmd" | grep -qE '[[:space:]]/([[:space:]]+|$|[;&|])'; then
    deny "Recursive rm targeting filesystem root blocked"
  fi
  # Pure system directories — deny anything under them (catches /etc/passwd, /usr/bin/sudo, etc.)
  if echo "$cmd" | grep -qE '[[:space:]]/(etc|usr|bin|sbin|boot|lib|lib64|System)(/|[[:space:]]|$|;|\||&)'; then
    deny "Recursive rm targeting pure system directory blocked"
  fi
  # User-data system roots — deny only the dir itself (allow /var/log/myapp, /home/user/temp, etc.)
  if echo "$cmd" | grep -qE '[[:space:]]/(var|home|opt|root|Library|Applications)([[:space:]]|$|;|\||&)'; then
    deny "Recursive rm targeting user-data system root blocked"
  fi
fi
# .env content exfiltration via Bash — DENY (covers cat/less/head/tail/grep/etc with any flags)
if echo "$cmd" | grep -qE '(^|[[:space:];|&(])(cat|less|more|head|tail|bat|nl|tac|od|xxd|hexdump|strings|view|grep|egrep|fgrep|rg|sed|awk)[[:space:]]([^|;&]*[[:space:]/])?\.env(\.|[[:space:]]|$|;|\|)'; then
  deny "Reading .env files via Bash blocked. Use environment variables in code instead."
fi
if echo "$cmd" | grep -qE '(curl|wget)[[:space:]].*\|[[:space:]]*(sh|bash|zsh)'; then
  deny "Piping remote content to shell is blocked. Download, inspect, then execute."
fi
if echo "$cmd" | grep -qE ':\(\)\{[[:space:]]*:'; then
  deny "Fork bomb pattern detected"
fi
if echo "$cmd" | grep -qiE '(DROP|TRUNCATE)[[:space:]]+TABLE'; then
  ask "Destructive SQL detected — confirm intent"
fi
# === ASK: risky but legitimate ===
# Dumping environment variables (may expose secrets) — catches 'env', 'env > file', 'printenv | grep'
if echo "$cmd" | grep -qE '(^|[[:space:];|&(])(printenv|env)([[:space:]]|$|[;&|>])'; then
  ask "Dumping environment variables — confirm intent (may expose secrets loaded from .env)"
fi
# Writing to .env via Bash redirect
if echo "$cmd" | grep -qE '>>?[[:space:]]*([^[:space:]]+/)?\.env([[:space:]]|$|\.|;|\|)'; then
  ask "Writing to .env via Bash redirect — confirm intent (prefer manual editing)"
fi
if echo "$cmd" | grep -qE 'git[[:space:]]+push' && ! echo "$cmd" | grep -q -- '--dry-run'; then
  ask "git push requires explicit user confirmation"
fi
if echo "$cmd" | grep -qE 'chmod[[:space:]]+777'; then
  ask "chmod 777 grants world-write — confirm intent"
fi
if echo "$cmd" | grep -qE 'chmod[[:space:]]+-R[[:space:]]+'; then
  ask "Recursive chmod can affect many files — confirm intent"
fi
allow
