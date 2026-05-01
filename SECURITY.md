# Security Policy

## Supported versions

The latest tagged release is supported. Older releases receive security patches only at the maintainer's discretion.

## Reporting a vulnerability

**Do not open a public GitHub issue.**

Instead, email the maintainer at `logansimoes7@gmail.com` with:
- A clear description of the vulnerability
- Reproduction steps (sanitized — do not include real secrets)
- Impact assessment
- Suggested fix if you have one

You will receive an acknowledgement within 72 hours. A fix will be released as soon as feasible, and the issue will be made public after the fix is shipped.

## Scope

In scope:
- Bypass of the secret scanner regex patterns
- Bypass of `.env` read/write protections (`permissions.deny` rules + Bash hook)
- `.env` content leakage via Bash tool (cat, head, grep, less, etc.)
- Bash/PowerShell injection via crafted hook inputs (e.g., shell metacharacters in `tool_input` that escape `jq` quoting)
- Hook output JSON injection (crafted `tool_input` producing malformed JSON output)
- Privilege escalation through hook execution
- Path traversal in installer scripts

Out of scope:
- Issues in user-modified forks
- Issues in Claude Code itself (report to Anthropic)
- Issues requiring physical access to the user's machine

## Recognition

Reporters who follow responsible disclosure will be credited in the CHANGELOG, unless they prefer to remain anonymous.
