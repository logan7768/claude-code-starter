---
description: Complete reset procedure — generate a handoff anchored on git, then print instructions to /clear and resume.
allowed-tools: Bash(date *), Bash(git status*), Bash(git diff *), Bash(git log *), Bash(git branch *), Bash(mkdir *), Write
---

# /ctx-reset — Save + reset procedure

This command does **two things in one shot**:
1. Generate a session handoff file (same logic as `/ctx-save`).
2. Print the reset procedure for the user.

## Ground truth (collected)

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
- Diff stat vs HEAD:
```!
git diff --stat HEAD 2>/dev/null || echo "(no diff)"
```

## Step 1 — Write the handoff

1. Run `mkdir -p ~/.claude/handoffs` if the directory doesn't exist.
2. Write to `~/.claude/handoffs/handoff-<filename-slug>.md` using this structure
   (fill from git ground truth above + this conversation; do not invent — write
   "(à confirmer)" when unclear):

```markdown
# HANDOFF — <timestamp>

## Branch & repo state
- Branch: <branch>
- Status (short):
  <status block>

## Recent commits
<git log block>

## Modified files (stat)
<diff stat block>

## Mission in progress
<one factual paragraph>

## Done this session
- <bullet 1>
- ...

## Key decisions
| Decision | Reason | Rejected alternative |
|---|---|---|
| ... | ... | ... |
(or "None recorded.")

## Next steps (ordered)
1. ...

## Watch out for
<gotchas>
(or "None.")
```

## Step 2 — Print the reset procedure

After the file is written, print exactly this block:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 CLEAN RESET — PROCEDURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Handoff written: ~/.claude/handoffs/handoff-<filename-slug>.md

1. Note the path above.
2. Run: /clear
3. In the new session, either:
   → Paste the handoff content, or
   → Say: "reprends depuis ~/.claude/handoffs/handoff-<filename-slug>.md"

💡 Tips:
   → Run /context first to check the new session is clean
   → Trigger /ctx-compact around 65% usage (preventive)
   → Trigger /ctx-reset around 80% (mandatory)

⏱️ Rule of thumb: /compact at 65%, /ctx-reset at 80%.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do not** run `/clear` yourself — that's the user's action.
