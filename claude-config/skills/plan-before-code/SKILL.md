---
name: plan-before-code
description: Produces a structured INVEST-based plan before implementing any non-trivial change. IMPORTANT - use this skill for tasks involving more than 3 steps, multiple files, architectural changes, or whenever the user says "plan", "design", "architect", "before you start", or asks for an approach proposal.
allowed-tools: Read, Grep, Glob
---
# Plan Before Code — INVEST Protocol

## When to invoke
- Task involves >3 steps
- Task involves multiple files or modules
- Architectural change
- User explicitly requests a plan

Skip only for <3 trivial steps with zero external files.

## Workflow

1. Switch to Opus 4.7 → `/model claude-opus-4-7`
2. Produce plan: Objective / Steps (each INVEST) / Risks / Deliverable
3. Submit for confirmation — do NOT start without explicit approval
4. After approval → switch to Sonnet 4.6 → `/model claude-sonnet-4-6`

## INVEST criteria per step

- Independent — executable without depending on a later step
- Negotiable — user can amend before execution
- Valuable — produces an observable deliverable
- Estimable — duration/complexity estimable
- Small — <1 file modified ideally, never >3
- Testable — explicit validation criterion

## Step structure (each step has 3 fields)

- `goal`: what we're trying to accomplish
- `validation`: how we verify (test, command, output)
- `congruence_check`: consistency with previous steps (no regression)

## NOT waterfall

Issue Anthropic #20051: waterfall phases + mid-task compaction → 100% hallucination rate.
Use gated steps with per-step validation instead.
