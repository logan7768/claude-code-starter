$ErrorActionPreference = "Stop"
$ClaudeDir = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { "$env:USERPROFILE\.claude" }
$Root = $PSScriptRoot
$SourceDir = Join-Path $Root "claude-config"
Write-Host "Claude Code Starter installer"
Write-Host "Target: $ClaudeDir"
# Fail-fast checks
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Warning "claude CLI not found in PATH (will still install)"
}
# Backup existing
if ((Test-Path $ClaudeDir) -and (Get-ChildItem $ClaudeDir -ErrorAction SilentlyContinue)) {
  $confirm = Read-Host "$ClaudeDir exists. Backup and replace? [y/N]"
  if ($confirm -notmatch '^[Yy]') { exit 1 }
  Move-Item $ClaudeDir "$ClaudeDir.backup.$([int][double]::Parse((Get-Date -UFormat %s)))"
}
# Install
New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
Copy-Item "$SourceDir\CLAUDE.md" $ClaudeDir
Copy-Item "$SourceDir\hooks" $ClaudeDir -Recurse
Copy-Item "$SourceDir\skills" $ClaudeDir -Recurse
Copy-Item "$SourceDir\settings.windows.json" "$ClaudeDir\settings.json"
# Validate
Write-Host ""
Write-Host "Running hook tests..."
& "$Root\tests\test-hooks.ps1"
if ($LASTEXITCODE -ne 0) {
  Write-Warning "Some tests failed. Check output above."
  exit 1
}
Write-Host ""
Write-Host "✓ Installed to $ClaudeDir"
Write-Host "  Run 'claude' and try '/memory' to verify."
