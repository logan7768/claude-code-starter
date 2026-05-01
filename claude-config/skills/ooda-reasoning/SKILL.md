---
name: ooda-reasoning
description: Applies the OODA loop (Observe-Orient-Decide-Act) reasoning protocol. IMPORTANT - use this skill for any non-trivial task involving debugging, decision-making under uncertainty, multi-step problem solving, or whenever the user mentions "OODA", "observe", "orient", "reasoning protocol", or asks Claude to "think carefully" before acting.
user-invocable: false
---
# OODA Loop — Reasoning Protocol

Four-stage iterative cycle from Boyd (USAF, 1970s). Use for any non-trivial decision or debugging task.

## 1. OBSERVE

Gather facts BEFORE any action:
- Read past lessons in `~/.claude/projects/<project>/memory/MEMORY.md`
- Read test status if `testing_results.json` exists
- Read the actual files concerned (never assume content)
- Capture recent outputs (commands, logs, stack traces)

## 2. ORIENT — critical step

Make sense of observations:
- Cross-check with MEMORY.md: is this a known issue?
- Cross-check with `@SPEC.md` / `@ARCHITECTURE.md`: does the planned solution respect project constraints?
- Identify applicable mental models (debug patterns, code patterns)
- Mark unverified hypotheses explicitly

## 3. DECIDE

- Most minimal action that resolves the observed problem
- If >3 steps OR multi-file → switch to `plan-before-code` skill
- If orientation uncertain → prefer verification action over modification

## 4. ACT

- One action at a time
- Capture result in test outputs + Auto Memory
- Result feeds the next OBSERVE — loop continues

## Golden rule

ORIENT determines the quality of everything else. Never skip it under time pressure.
