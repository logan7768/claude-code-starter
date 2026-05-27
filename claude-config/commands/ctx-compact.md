---
description: Print a short session snapshot anchored on git, then prompt the user to run /compact.
allowed-tools: Bash(date *), Bash(git status*), Bash(git diff *), Bash(git log *), Bash(git branch *)
---

# /ctx-compact — Pre-compact snapshot

Produce a compact snapshot of the session **before** the user runs `/compact`,
so that compaction has something faithful to summarize.

## Ground truth

- Time: !`date "+%H:%M"`
- Branch: !`git branch --show-current 2>/dev/null || echo "n/a"`
- Modified files:
```!
git diff --name-only HEAD 2>/dev/null || echo "(no diff or not a git repo)"
```
- Last 3 commits:
```!
git log -3 --oneline 2>/dev/null || echo "(no commits visible)"
```

## Output (print this exactly)

```
─────────────────────────────────────────
📸 SESSION SNAPSHOT — <time>
─────────────────────────────────────────
Task        : <one-line factual description>
Done        : <up to 3 bullets of completed actions>
Decisions   : <key decisions, with one-line justification each; "None" if N/A>
State now   : <exact file/function/step we are at>
Next step   : <next immediate action>
Modified    : <file list from git, or "(none)">
─────────────────────────────────────────
```

Then on a new line, print:

> Snapshot ready. Run `/compact` to compress context (~40-60% reduction).
> If the snapshot is lost after compact, ask: "rappelle le snapshot".

**Rules:**
- Pull from git ground truth above for `Modified` and recent commits.
- Pull from the conversation for `Task`, `Done`, `Decisions`, `State now`, `Next step`.
- If anything is unclear, write `(à confirmer)` rather than guess.
- Do **not** call `/compact` yourself — only the user runs it.
