#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS="$ROOT/claude-config/hooks"
FIXTURES="$ROOT/tests/fixtures"
pass=0; fail=0
run_test() {
  local name="$1" hook="$2" fixture="$3" expected="$4"
  local output
  output=$(bash "$hook" < "$fixture" 2>&1 || true)
  if [ -z "$expected" ]; then
    if [ -z "$output" ]; then echo "✅ $name (allow)"; pass=$((pass+1))
    else echo "❌ $name expected empty (allow), got: $output"; fail=$((fail+1)); fi
  else
    if echo "$output" | grep -q "$expected"; then echo "✅ $name"; pass=$((pass+1))
    else echo "❌ $name expected '$expected', got: $output"; fail=$((fail+1)); fi
  fi
}
echo "=== Bash security ==="
run_test "rm -rf / blocks"        "$HOOKS/pre-bash-security.sh" "$FIXTURES/bash-rm-rf.json"     '"permissionDecision":"deny"'
run_test "curl|sh blocks"         "$HOOKS/pre-bash-security.sh" "$FIXTURES/bash-curl-pipe.json" '"permissionDecision":"deny"'
run_test "git push asks"          "$HOOKS/pre-bash-security.sh" "$FIXTURES/bash-git-push.json"  '"permissionDecision":"ask"'
run_test "chmod 777 asks"         "$HOOKS/pre-bash-security.sh" "$FIXTURES/bash-chmod-777.json" '"permissionDecision":"ask"'
run_test "ls -la allows"          "$HOOKS/pre-bash-security.sh" "$FIXTURES/bash-safe.json"      ""
run_test "rm long flags blocks"   "$HOOKS/pre-bash-security.sh" "$FIXTURES/bash-rm-long-flag.json" '"permissionDecision":"deny"'
run_test "cat .env blocks"        "$HOOKS/pre-bash-security.sh" "$FIXTURES/bash-cat-env.json"     '"permissionDecision":"deny"'
run_test "head path/.env blocks"  "$HOOKS/pre-bash-security.sh" "$FIXTURES/bash-cat-env-path.json" '"permissionDecision":"deny"'
echo "=== Secret scan ==="
run_test "AWS key blocks"         "$HOOKS/pre-write-secret-scan.sh" "$FIXTURES/write-secret-aws.json"       '"permissionDecision":"deny"'
run_test "OpenAI key blocks"      "$HOOKS/pre-write-secret-scan.sh" "$FIXTURES/write-secret-openai.json"    '"permissionDecision":"deny"'
run_test "MultiEdit secret blocks" "$HOOKS/pre-write-secret-scan.sh" "$FIXTURES/write-secret-multiedit.json" '"permissionDecision":"deny"'
run_test "safe write allows"      "$HOOKS/pre-write-secret-scan.sh" "$FIXTURES/write-safe.json"             ""
run_test "bare .env write blocks" "$HOOKS/pre-write-secret-scan.sh" "$FIXTURES/write-bare-env.json"         '"permissionDecision":"deny"'
echo
echo "Results: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
