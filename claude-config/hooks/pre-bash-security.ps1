# Pre-tool security gate for Bash commands (Windows).
$inputJson = [Console]::In.ReadToEnd() | ConvertFrom-Json
$cmd = $inputJson.tool_input.command
function Deny($reason) {
  @{
    hookSpecificOutput = @{
      hookEventName = "PreToolUse"
      permissionDecision = "deny"
      permissionDecisionReason = $reason
    }
  } | ConvertTo-Json -Depth 5 -Compress
  exit 0
}
function Ask($reason) {
  @{
    hookSpecificOutput = @{
      hookEventName = "PreToolUse"
      permissionDecision = "ask"
      permissionDecisionReason = $reason
    }
  } | ConvertTo-Json -Depth 5 -Compress
  exit 0
}
function Allow { exit 0 }

$hasRmDel = $false
if ($cmd -match '(^|[\s;|&(/])\\?(\.?/?(bin/|usr/bin/)?)?rm\s') {
  if ($cmd -match '-[a-zA-Z]*[rRfF]') { $hasRmDel = $true }
  if ($cmd -match '--(recursive|force|no-preserve-root)') { $hasRmDel = $true }
}
if ($hasRmDel) {
  if ($cmd -match '\s/(\s+|$|[;&|])') { Deny "Recursive rm targeting filesystem root blocked" }
  if ($cmd -match '\s/(etc|usr|bin|sbin|boot|lib|lib64|System)(/|\s|$|;|\||&)') { Deny "Recursive rm targeting pure system directory blocked" }
  if ($cmd -match '\s/(var|home|opt|root|Library|Applications)(\s|$|;|\||&)') { Deny "Recursive rm targeting user-data system root blocked" }
}
if ($cmd -match '(^|[\s;|&(])(cat|less|more|head|tail|bat|nl|type|Get-Content|gc|grep|egrep|fgrep|rg|sed|awk)\s([^|;&]*[\s/])?\.env(\.|\s|$|;|\|)') {
  Deny "Reading .env files via Bash blocked"
}
if ($cmd -match '(curl|wget).*\|\s*(sh|bash|zsh)') { Deny "Piping remote content to shell is blocked" }
if ($cmd -match 'Remove-Item.*-Recurse.*-Force.*[Cc]:\\?(\s|$)') { Deny "Recursive force-delete on system drive blocked" }
if ($cmd -match '(DROP|TRUNCATE)\s+TABLE') { Ask "Destructive SQL detected" }
if ($cmd -match '(^|[\s;|&(])(printenv|env|Get-ChildItem\s+env:)\s*($|[;&|])') { Ask "Dumping environment variables" }
if ($cmd -match '>>?\s*([^\s]+[/\\])?\.env(\s|$|\.|;|\|)') { Ask "Writing to .env via Bash redirect" }
if ($cmd -match 'git\s+push' -and $cmd -notmatch '--dry-run') { Ask "git push requires explicit user confirmation" }
if ($cmd -match 'chmod\s+777') { Ask "chmod 777 grants world-write" }
if ($cmd -match 'Remove-Item.*-Recurse.*-Force') { Ask "Remove-Item -Recurse -Force needs confirmation" }
Allow