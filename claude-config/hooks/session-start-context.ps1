# Inject git branch + status at session start.
$projectDir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
if (-not (Test-Path (Join-Path $projectDir ".git"))) { exit 0 }
$branch = (git -C $projectDir branch --show-current 2>$null) -join ""
if (-not $branch) { $branch = "detached" }
$modified = (git -C $projectDir status --porcelain 2>$null | Measure-Object -Line).Lines
$context = "Git context — branch: $branch | modified files: $modified"
@{
  hookSpecificOutput = @{
    hookEventName    = "SessionStart"
    additionalContext = $context
  }
} | ConvertTo-Json -Depth 5 -Compress
