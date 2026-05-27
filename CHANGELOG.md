# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.5] - 2026-05-27

### Added
- Context lifecycle slash commands in `claude-config/commands/`:
  - `/ctx-save` — write a session handoff to `~/.claude/handoffs/`, anchored on real git state.
  - `/ctx-compact` — print a faithful pre-compact snapshot.
  - `/ctx-reset` — combined handoff + reset procedure.
- Auto-creation of the handoff store at `~/.claude/handoffs/` during install.
- `CLAUDE.md`: minimal context-hygiene section pointing to the built-in `/context`.

### Changed
- `install.ps1` and `install.sh`: copy `claude-config/commands/` and create the `handoffs/` directory.
## [0.1.0] — 2026-05-01

### Added
- 5 skills : `ooda-reasoning`, `anti-hallucination`, `plan-before-code`, `hindsight`, `security-audit`
- 4 hooks : `pre-bash-security`, `pre-write-secret-scan`, `post-write-format` (opt-in), `session-start-context` (opt-in)
- 13 test fixtures + bash and PowerShell test runners
- CI workflow (Linux + Windows)
- Multi-OS installers (bash + PowerShell)
- Documentation : PHILOSOPHY, CUSTOMIZATION, MIGRATION, CREDITS

### Security baseline (consolidated across 5 audit rounds)
- `permissions.deny` blocking reads of `.env`, `.env.*` (incl. recursive subdirs), `.aws/credentials`, `.ssh/id_*`
- `pre-bash-security` blocks `cat .env`, `head -n 5 .env`, `grep KEY .env`, etc. across 18 read commands
- `pre-bash-security` improved `rm` detection : `--recursive --force`, `-r -f` split flags, `/bin/rm`, `\rm`
- `pre-bash-security` denies anything under critical system dirs (`/etc/**`, `/usr/**`, `/bin/**`, etc.)
- `pre-bash-security` denies user-data system roots (`/var`, `/home`, `/opt`, `/root`) when targeted directly
- `pre-bash-security` ASK on `printenv`/`env` (incl. with redirect) and `>> .env` redirects
- `pre-write-secret-scan` basename matching catches bare `.env` filenames
- `pre-write-secret-scan` patterns portable across BSD grep (macOS) and GNU grep via `Q` variable idiom
- 13 secret patterns covering AWS, OpenAI, Anthropic, GitHub PAT/fine-grained, GitLab, Slack, Google API, PEM keys

### Notes
- Targets Claude Code v2.1.59+ (Auto Memory required)
- Models : Opus 4.7 / Sonnet 4.6 / Haiku 4.5
- Hook output format : `hookSpecificOutput.permissionDecision` (Anthropic spec, post-v2.0.45)
