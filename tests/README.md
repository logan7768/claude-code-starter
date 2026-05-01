# Hook test suite

This directory validates the security hooks before any release. CI runs these tests on Linux + Windows for every push and PR.

## Run locally

Linux/Mac:
```bash
./tests/test-hooks.sh
```

Windows:
```powershell
.\tests\test-hooks.ps1
```

## Layout

- `fixtures/` : JSON inputs that mimic real Claude Code hook calls
- `test-hooks.sh` / `test-hooks.ps1` : runners that pipe each fixture into the corresponding hook and assert the output

## Adding a test

1. Drop a new fixture in `fixtures/<scenario>.json` matching Claude Code's hook input schema
2. Add a `run_test` line in the runner (both bash and PowerShell)
3. Re-run locally before opening the PR

## Schema reference

Hook inputs follow the Anthropic spec. Common fields:
- `session_id`, `transcript_path`, `cwd`, `hook_event_name`
- `tool_name`: `Bash` | `Edit` | `Write` | `MultiEdit`
- `tool_input`: tool-specific. Bash → `{command}`. Write → `{file_path, content}`. Edit → `{file_path, new_string}`. MultiEdit → `{file_path, edits: [{new_string}]}`
