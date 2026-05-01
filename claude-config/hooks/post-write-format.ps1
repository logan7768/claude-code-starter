# Auto-format files after Write/Edit/MultiEdit.
# Only runs if a formatter is available and the file extension matches.
$inputJson = [Console]::In.ReadToEnd() | ConvertFrom-Json
$filePath = $inputJson.tool_input.file_path
if (-not $filePath -or -not (Test-Path $filePath)) { exit 0 }
switch -Regex ($filePath) {
  '\.py$' {
    if (Get-Command black -ErrorAction SilentlyContinue) {
      & black --quiet $filePath 2>$null
    }
  }
  '\.(js|ts|jsx|tsx|json|md|css|html)$' {
    if (Get-Command prettier -ErrorAction SilentlyContinue) {
      & prettier --write --log-level=silent $filePath 2>$null
    }
  }
  '\.go$' {
    if (Get-Command gofmt -ErrorAction SilentlyContinue) {
      & gofmt -w $filePath 2>$null
    }
  }
  '\.rs$' {
    if (Get-Command rustfmt -ErrorAction SilentlyContinue) {
      & rustfmt --quiet $filePath 2>$null
    }
  }
}
exit 0
