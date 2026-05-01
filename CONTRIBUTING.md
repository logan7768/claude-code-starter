# Contributing

This project welcomes:
- Bug reports for hooks not behaving as documented
- New skill ideas (must be generic, not project-specific)
- Hook patterns for additional security/quality checks
- Platform-specific fixes (especially BSD, Alpine, macOS edge cases)
- Documentation improvements

## Before opening a PR

1. Run the test suite: `./tests/test-hooks.sh` (Linux/Mac) or `.\tests\test-hooks.ps1` (Windows). All tests must pass.
2. If you add a hook, add a fixture in `tests/fixtures/` and a test case in both runners.
3. If you add a skill, ensure the description is in third person, plain text (no markdown), pushy (lists triggering phrases), and the body is under 500 lines.
4. Run a real Claude Code session against your changes for at least 30 minutes before opening the PR.

## Hook output format

IMPORTANT: Use the official `hookSpecificOutput.permissionDecision` JSON format. Do NOT use the deprecated `decision: "block"` format (issue Anthropic #19115).

Reference: https://code.claude.com/docs/en/hooks

## Skill description guidelines

Skills auto-trigger based on the description in the YAML frontmatter. To maximize correct triggering:
- Third person: "Applies X..." not "Apply X..."
- Plain text only (markdown bold/italic does not render in system prompt)
- Be "pushy": list specific user phrases that should trigger it
- Specify WHEN to use, not just WHAT it does
- Each description (combined with optional `when_to_use` field) ≤ **1,536 characters** (Anthropic limit). Names ≤ 64 chars.

## Code style

- Bash: prefer `grep -qE` over `[[ =~ ]]` for portability; quote all variables; use `jq` for JSON
- PowerShell: never name a variable `$input` (reserved automatic variable). Use `$inputJson`. Use `ConvertTo-Json -Compress` to keep output a single line
- No abbreviations in skill names — be descriptive

## Reporting security issues

Do not open a public issue for security vulnerabilities. See [`SECURITY.md`](SECURITY.md).

## License

By contributing, you agree your contributions are licensed under MIT.
