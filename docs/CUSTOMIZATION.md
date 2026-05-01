# Customization

## Common adjustments

### Add a language to the secret scan

Edit `claude-config/hooks/pre-write-secret-scan.{sh,ps1}` and add a new pattern to the `patterns` array. Example for Stripe keys:

```
'sk_live_[a-zA-Z0-9]{24,}'
```

Add a corresponding test fixture in `tests/fixtures/` and a `run_test` line in both runners.

### Change default models

Edit the table in `claude-config/CLAUDE.md`. Use API model IDs (e.g., `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5`) or aliases (`opus`, `sonnet`, `haiku`).

### Add a skill

1. Create `claude-config/skills/<your-skill>/SKILL.md`
2. Frontmatter rules:
    - `name` lowercase + hyphens only
    - `description` ≤ **1,536 chars** (combined with `when_to_use`), third person, plain text, lists triggering phrases
    - Optional: `disable-model-invocation`, `user-invocable: false`, `allowed-tools`
3. Body ≤ 500 lines
4. Test by asking Claude something that should trigger it. If it doesn't trigger, the description is too vague — add specific user phrases.

### Disable a skill

Three options:
1. Delete its directory
2. `disable-model-invocation: true` (skill becomes user-only via slash command)
3. `user-invocable: false` (skill is Claude-only, no slash command exposure)

### Disable all hooks

Add `"disableAllHooks": true` to your `~/.claude/settings.json`. Useful for debugging.

### Make hooks project-scoped (vs user-scoped)

Copy `claude-config/hooks/` and `settings.{linux,windows}.json` into your project's `.claude/` directory. Project hooks merge with user hooks at runtime.

### Package as a plugin (advanced)

Claude Code plugins bundle skills, hooks, subagents, and MCP servers into a single installable unit. To convert this template:
1. Restructure as `plugin.json` + `hooks.json` + skills directory
2. Submit to the marketplace at https://claude.com/plugins

See https://github.com/anthropics/claude-code/tree/main/plugins for examples.

## Advanced patterns

### Optimize hook performance with `if` filters

For high-frequency tools (e.g., `Bash`), you can add an `if` filter to skip the script entirely when the command obviously doesn't need scanning:

```json
{
  "type": "command",
  "if": "Bash(rm *)",
  "command": "..."
}
```

WARNING: only single patterns are documented. Pipe-alternation like `Bash(rm *|chmod *)` is unverified and may fail silently. Use one hook entry per pattern if you need multiple.

### Inject SessionStart context

The bonus `session-start-context` hook injects git branch and modified-file count at session start. Adapt it to inject:
- Current sprint/ticket from your tracker
- Last deploy timestamp
- Active feature flags
- Whatever your team needs as universal session context

**Known issue (Anthropic #10373)** : SessionStart hooks may not fire on **brand-new conversations** in some Claude Code versions. They reliably fire on `/clear`, `/compact`, and `--resume`. Test with these triggers if your hook seems silent. Anthropic is tracking the regression.

### Multi-machine sync

`~/.claude/CLAUDE.md` and skills are synced if you keep `~/.claude/` in a private git repo or symlink. Auto Memory should NOT be synced — it's machine-specific and would create merge conflicts.
