# Migration from a monolithic CLAUDE.md

If you have a 200-300 line `CLAUDE.md` with rules, examples, and conventions all stacked, here is the recommended migration path. Estimated effort: 2-4 hours.

## Phase 1 — Inventory (30 min)

List every rule in your current `CLAUDE.md`. Categorize each as:
- **Identity / always-on** (e.g., "be concise", "use Python 3.11") → stays in `CLAUDE.md`
- **Conditional / situational** (e.g., "when refactoring tests, ...") → becomes a skill
- **Invariant / must-hold** (e.g., "never commit `.env`") → becomes a hook
- **Stale / unused** → delete

## Phase 2 — Skills extraction (1-2h)

For each conditional rule:
1. Create `~/.claude/skills/<name>/SKILL.md`
2. Write a description in 3rd person listing trigger phrases
3. Move the rule body into the skill body
4. Remove the rule from `CLAUDE.md`

Test each skill with a session that should trigger it. If trigger rate is low, the description needs more specific phrases.

## Phase 3 — Hooks extraction (30-60 min)

For each invariant rule:
1. Decide which hook event matches: `PreToolUse` (block before), `PostToolUse` (validate after), `SessionStart` (inject context)
2. Write a small bash/PowerShell script using the templates in this repo
3. Add a fixture and test case
4. Wire into `settings.json`

## Phase 4 — Slim CLAUDE.md (15 min)

Target ~55-60 lines. If still over, the remaining content is either:
- Documentation that belongs in your project README
- Conditional content that should still be a skill

## Phase 5 — Auto Memory parallel (1 week observation)

Enable Auto Memory and observe what it captures over a week. Compare with your old manual notes. Most users find Auto Memory captures 70-80% of what they used to track manually.

## Common pitfalls

- **Migrating skill content as-is** — manual rules tend to be too verbose. Skills work best at <500 lines and benefit from progressive disclosure (`references/` for detail).
- **Forgetting `user-invocable: false`** for internal skills — otherwise they pollute the slash command menu.
- **Trusting hook adherence without testing** — always run the test suite after wiring a hook.
- **Mixing CLAUDE.md global and project** — global is `~/.claude/CLAUDE.md` (shared), project is `<project>/CLAUDE.md` (specific). Keep them distinct.
