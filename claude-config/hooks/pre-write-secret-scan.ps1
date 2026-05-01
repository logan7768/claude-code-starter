# Pre-tool secret scanner Windows - 13 patterns
$inputJson = [Console]::In.ReadToEnd() | ConvertFrom-Json
$filePath = $inputJson.tool_input.file_path
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
$basename = Split-Path -Leaf $filePath
if ($basename -match '^\.env\.(example|template)$') { exit 0 }
if ($basename -match '^\.env$' -or $basename -match '^\.env\..+$') {
  Deny "Direct write to .env file blocked"
}
$pieces = @()
if ($inputJson.tool_input.content) { $pieces += $inputJson.tool_input.content }
if ($inputJson.tool_input.new_string) { $pieces += $inputJson.tool_input.new_string }
if ($inputJson.tool_input.edits) {
  foreach ($edit in $inputJson.tool_input.edits) {
    if ($edit.new_string) { $pieces += $edit.new_string }
  }
}
$contents = $pieces -join "`n"
$Q = '[' + "'" + '"' + ']'
$NQ = '[^' + "'" + '"' + ']'
$patterns = @(
  "api[_-]?key\s*=\s*$Q[\w-]{20,}",
  "password\s*=\s*$Q$NQ{8,}",
  "token\s*=\s*$Q[\w-]{20,}",
  "secret\s*=\s*$Q[\w-]{20,}",
  'AKIA[0-9A-Z]{16}',
  'sk-[a-zA-Z0-9-]{32,}',
  'sk-ant-[a-zA-Z0-9-]{32,}',
  'ghp_[a-zA-Z0-9]{36}',
  'github_pat_[a-zA-Z0-9_]{82}',
  'glpat-[a-zA-Z0-9_-]{20}',
  'xox[baprs]-[a-zA-Z0-9-]{10,}',
  'AIza[0-9A-Za-z_-]{35}',
  '-----BEGIN [A-Z ]+PRIVATE KEY-----'
)
foreach ($p in $patterns) {
  if ($contents -match $p) {
    Deny "Potential secret detected"
  }
}
exit 0