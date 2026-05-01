---
name: hindsight
description: Triggers a self-improvement protocol that proposes CLAUDE.md or skill rule improvements. IMPORTANT - use this skill at session close when any rule was violated, the same error appeared twice, a correction needed three or more attempts, or the user mentions "lessons learned", "improve the rules", "this should be a rule", or "remember this for next time". Never modifies rules without explicit user approval.
user-invocable: false
---
# Hindsight — Rule Self-Improvement

## Triggers (at end of session, if any condition met)
- A CLAUDE.md or skill rule was violated
- Same error appears 2+ times in MEMORY.md
- Correction needed 3+ attempts
- Anti-hallucination failed (unsourced claim delivered as truth)

## Process

1. Identify the failing or missing rule
2. Root-cause analysis: too vague / too rigid / absent / contradictory?
3. Formulate improved version (before/after)
4. Submit proposal — wait explicit user confirmation
5. After confirmation → modify file + log change with format:
    `[DATE] [HINDSIGHT] <Rule X> modified — OLD: "..." NEW: "..." REASON: ...`

## Absolute rule

YOU MUST NOT modify CLAUDE.md or any SKILL.md without explicit user confirmation.
Propose → Wait → Apply.
