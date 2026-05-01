# Hook test runner for Windows.
$ErrorActionPreference = "Continue"
$Root = (Get-Item $PSScriptRoot).Parent.FullName
$Hooks = Join-Path $Root "claude-config\hooks"
$Fixtures = Join-Path $PSScriptRoot "fixtures"
$pass = 0
$fail = 0
function Run-Test($name, $hook, $fixture, $expected) {
  $fixturePath = Join-Path $Fixtures $fixture
  # cmd /c is more reliable than PowerShell pipe-to-exe for stdin redirection
  $output = (cmd /c "type `"$fixturePath`" | powershell -ExecutionPolicy Bypass -File `"$hook`" 2>&1") | Out-String
  $output = $output.Trim()
  if ([string]::IsNullOrEmpty($expected)) {
    if ([string]::IsNullOrEmpty($output)) {
      Write-Host "OK   $name (allow)" -ForegroundColor Green
      $script:pass++
    } else {
      Write-Host "FAIL $name expected empty, got: $output" -ForegroundColor Red
      $script:fail++
    }
  } else {
    if ($output -like "*$expected*") {
      Write-Host "OK   $name" -ForegroundColor Green
      $script:pass++
    } else {
      Write-Host "FAIL $name expected '$expected', got: $output" -ForegroundColor Red
      $script:fail++
    }
  }
}
Write-Host "=== Bash security ==="
Run-Test "rm -rf / blocks"         (Join-Path $Hooks "pre-bash-security.ps1") "bash-rm-rf.json"     '"permissionDecision":"deny"'
Run-Test "curl|sh blocks"          (Join-Path $Hooks "pre-bash-security.ps1") "bash-curl-pipe.json" '"permissionDecision":"deny"'
Run-Test "git push asks"           (Join-Path $Hooks "pre-bash-security.ps1") "bash-git-push.json"  '"permissionDecision":"ask"'
Run-Test "chmod 777 asks"          (Join-Path $Hooks "pre-bash-security.ps1") "bash-chmod-777.json" '"permissionDecision":"ask"'
Run-Test "ls -la allows"           (Join-Path $Hooks "pre-bash-security.ps1") "bash-safe.json"      ""
Run-Test "rm long flags blocks"    (Join-Path $Hooks "pre-bash-security.ps1") "bash-rm-long-flag.json" '"permissionDecision":"deny"'
Run-Test "cat .env blocks"         (Join-Path $Hooks "pre-bash-security.ps1") "bash-cat-env.json"      '"permissionDecision":"deny"'
Run-Test "head path/.env blocks"   (Join-Path $Hooks "pre-bash-security.ps1") "bash-cat-env-path.json" '"permissionDecision":"deny"'
Write-Host "=== Secret scan ==="
Run-Test "AWS key blocks"          (Join-Path $Hooks "pre-write-secret-scan.ps1") "write-secret-aws.json"       '"permissionDecision":"deny"'
Run-Test "OpenAI key blocks"       (Join-Path $Hooks "pre-write-secret-scan.ps1") "write-secret-openai.json"    '"permissionDecision":"deny"'
Run-Test "MultiEdit secret blocks" (Join-Path $Hooks "pre-write-secret-scan.ps1") "write-secret-multiedit.json" '"permissionDecision":"deny"'
Run-Test "safe write allows"       (Join-Path $Hooks "pre-write-secret-scan.ps1") "write-safe.json"             ""
Run-Test "bare .env write blocks"  (Join-Path $Hooks "pre-write-secret-scan.ps1") "write-bare-env.json"         '"permissionDecision":"deny"'
Write-Host ""
Write-Host "Results: $pass passed, $fail failed"
if ($fail -gt 0) { exit 1 }
