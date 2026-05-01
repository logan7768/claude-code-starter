---
name: security-audit
description: Runs a session-start security audit checking .env, .gitignore, and scanning source files for hardcoded secrets across 16 languages. IMPORTANT - use this skill at the start of any session in a new repository, when the user mentions "security", "audit", "secrets", "credentials", or whenever Claude is about to work with code that handles authentication, API keys, or sensitive data.
allowed-tools: Read, Grep, Glob, Bash
---
# Security Audit — Session Start

## 4 checks in order

### 1. .env
Exists? Contains expected keys? (never display values)
Missing → create empty template + alert.

### 2. .gitignore
Contains: `.env`, `*.log`, `*.db`, `*.sqlite`?
Missing entries → add automatically.

### 3. Scan source files
Languages to scan: `.py`, `.js`, `.ts`, `.jsx`, `.tsx`, `.go`, `.rs`, `.rb`, `.java`, `.kt`, `.swift`, `.php`, `.cs`, `.cpp`, `.c`, `.h`
Config files: `.env*`, `*.config.js`, `*.yml`, `*.yaml`, `*.toml`, `*.ini`
Patterns: `api_key=`, `token=`, `password=`, `secret=`, AWS/OpenAI/Anthropic/GitHub/GitLab/Slack/Google patterns, PEM private keys.
Detected → STOP all actions until resolved.

### 4. Report (3 lines max)
- `.env`: present / absent → created
- `.gitignore`: complete / N entries added
- Secret scan: OK / ALERT in [file]

## Golden rule
Unsecured project = halted project. No other action before resolution.

## Deterministic backup
This skill is advisory (~80% adherence). The `pre-write-secret-scan` hook in this template provides 100% enforcement deterministically.
