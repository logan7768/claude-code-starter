# Claude Code Starter
[![CI](https://github.com/logan7768/claude-code-starter/actions/workflows/test-hooks.yml/badge.svg)](https://github.com/logan7768/claude-code-starter/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v2.1.59%2B-orange)](https://code.claude.com)

A production-grade Claude Code configuration encoding Anthropic's 2026 best practices: OODA reasoning, official anti-hallucination techniques, INVEST-based planning, deterministic security via PreToolUse hooks, and modular skills loaded on demand.

## Why this exists

Most CLAUDE.md examples online are 300-line monoliths that load the same rules every session. This wastes tokens and hurts adherence (Anthropic's own finding: shorter rules are better followed).

This starter splits responsibilities the way Anthropic's primitives intend:
- **CLAUDE.md** (~55 lines): identity, models, security baseline. Always loaded.
- **Skills** (`.claude/skills/`): conditional behaviors loaded only when their description matches. Token-efficient.
- **Hooks** (`.claude/settings.json`): deterministic enforcement via `hookSpecificOutput.permissionDecision`. 100% guarantee, not ~80% advisory.
- **Auto Memory** (native, v2.1.59+): cross-session learning, no manual error log needed.

## What you get

| Component | Purpose |
|---|---|
| `CLAUDE.md` | Minimal global rules (~55 lines) |
| `skills/ooda-reasoning/` | Observe-Orient-Decide-Act protocol |
| `skills/anti-hallucination/` | Anthropic's 3 official techniques + read-before-edit |
| `skills/plan-before-code/` | INVEST-based planning (per-step validation) |
| `skills/hindsight/` | Self-improvement protocol with user approval |
| `skills/security-audit/` | Session-start security check |
| `hooks/pre-bash-security` | Blocks `rm -rf /`, `curl \| sh`, asks on `git push`, `chmod 777` |
| `hooks/pre-write-secret-scan` | Blocks writes containing secrets (13 patterns, MultiEdit-aware) |
| `hooks/post-write-format` | Auto-runs prettier/black after edits (opt-in) |
| `hooks/session-start-context` | Injects git branch + status at session start (opt-in) |

## Quickstart

### Linux / macOS

```bash
git clone https://github.com/logan7768/claude-code-starter.git
cd claude-code-starter
./install.sh
```

Requires `bash 4+` and `jq`. Install jq via your package manager (`brew install jq`, `apt install jq`, etc.).

### Windows (PowerShell)

```powershell
git clone https://github.com/logan7768/claude-code-starter.git
cd claude-code-starter
.\install.ps1
```

Requires `PowerShell 5.1+`.

The installer:
1. Detects your OS and copies the matching `settings.{linux,windows}.json` as `settings.json`
2. Copies all hooks and skills to `~/.claude/`
3. Makes shell scripts executable (Linux/Mac)
4. Backs up any existing `~/.claude/` config first
5. Runs the test suite to verify everything works

### Verify

```bash
claude --version          # must be >= 2.1.59 for Auto Memory

claude

# Inside session:
/memory                   # see CLAUDE.md and Auto Memory location
/context                  # see token usage
```

Then in a Claude Code Bash tool, try `rm -rf /etc` — the hook should deny it with a clear reason. Try also `cat .env` (if you have one) — it should also be blocked.

## Requirements

- Claude Code v2.1.59 or later (Auto Memory support)
- Bash 4+ and `jq` (Linux/Mac) OR PowerShell 5.1+ (Windows)
- A Claude API key, Pro, or Max subscription

## Customization

See [`docs/CUSTOMIZATION.md`](docs/CUSTOMIZATION.md). Common adjustments:
- **Add languages to secret scan**: edit `hooks/pre-write-secret-scan.*`
- **Change default models**: edit the table in `CLAUDE.md`
- **Add a skill**: copy any `skills/<name>/SKILL.md` template; the YAML frontmatter `description` controls auto-invocation. Use third person and be specific about WHEN to invoke
- **Disable a skill**: delete its folder, or set `disable-model-invocation: true`
- **Disable all hooks**: add `"disableAllHooks": true` to your `settings.json`
- **Mid-session add to CLAUDE.md**: press `#` in a Claude Code session

## Distribution alternatives

- **As a plugin**: this starter can be packaged as a Claude Code plugin and submitted to the [marketplace](https://claude.com/plugins). See `docs/CUSTOMIZATION.md`.
- **Per-project hooks**: copy only `claude-config/hooks/` and a project-local `.claude/settings.json` for project-scoped enforcement.

## Philosophy

See [`docs/PHILOSOPHY.md`](docs/PHILOSOPHY.md).

TL;DR — 5 principles:
1. CLAUDE.md global = minimal identity (< 60 lines)
2. Auto Memory replaces manual error logs
3. Skills = unit of conditional behavior, loaded on match
4. Hooks = deterministic enforcement (not advisory)
5. Hindsight = explicit self-improvement loop with user approval

## Credits

- **OODA Loop**: Col. John Boyd (USAF, 1970s)
- **INVEST criteria**: Bill Wake (Agile XP) — adapted per Anthropic issue #20051
- **Anti-hallucination**: [Anthropic official docs](https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/reduce-hallucinations)
- **Hindsight protocol**: original to this template
- **Anthropic primitives**: [Skills](https://code.claude.com/docs/en/skills), [Hooks](https://code.claude.com/docs/en/hooks), [Memory](https://code.claude.com/docs/en/memory)

## License

MIT — see [`LICENSE`](LICENSE).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Issues, PRs, skill ideas, hook patterns, and platform fixes welcome.

## Security

Found a vulnerability? See [`SECURITY.md`](SECURITY.md). Do **not** open a public issue.
