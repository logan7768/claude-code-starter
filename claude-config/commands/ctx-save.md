---
description: Write a session handoff to ~/.claude/handoffs/ anchored on real git state. Run before /clear.
allowed-tools: Bash(date *), Bash(git status*), Bash(git diff *), Bash(git log *), Bash(git branch *), Bash(mkdir *), Bash(ls *), Write
---

# /ctx-save — Session handoff

The user wants to reset the session cleanly. Compose a handoff file
anchored on **real git state below**, not on memory.

## Ground truth (already collected)

- Timestamp: !`date "+%Y-%m-%d %H:%M"`
- Filename slug: !`date "+%Y-%m-%d-%H%M"`
- Branch: !`git branch --show-current 2>/dev/null || echo "(not a git repo)"`
- Status:
```!
git status --short 2>/dev/null || echo "(not a git repo)"
```
- Last 10 commits:
```!
git log -10 --oneline 2>/dev/null || echo "(not a git repo)"
```
- Changed files (diff stat vs HEAD):
```!
git diff --stat HEAD 2>/dev/null || echo "(no diff)"
```

## Your task

1. Create the handoffs directory if missing: `mkdir -p ~/.claude/handoffs`
2. Write a file at `~/.claude/handoffs/handoff-<filename-slug>.md` using the template below.
3. Fill it from (a) the git ground truth above, (b) the conversation we just had, and (c) what the user explicitly stated as the next step. **Do not invent decisions you didn't observe.** If unclear, write "(à confirmer)".
4. After writing the file, print exactly:

   ```
   ✅ Handoff → ~/.claude/handoffs/handoff-<filename-slug>.md
   Next: run /clear, then in the new session paste the handoff content (or say "reprends depuis <path>").
   ```

## Template to write

```markdown
# HANDOFF — <timestamp>

## Branch & repo state
- Branch: <branch>
- Status (short):
  <status block from above>

## Recent commits
<git log block from above>

## Modified files (stat)
<git diff --stat block from above>

## Mission in progress
<one paragraph, factual, no embellishment>

## Done this session
- <bullet 1>
- <bullet 2>
- ...

## Key decisions
| Decision | Reason | Rejected alternative |
|---|---|---|
| ... | ... | ... |

(Omit the table if no significant decisions were made — write "None recorded.")

## Next steps (ordered)
1. <precise actionable step>
2. ...

## Watch out for
<gotchas, pending dependencies, anything the next session must not miss>
(Omit if none.)
```
