# Philosophy

## Five principles

### 1. CLAUDE.md global = minimal identity (< 60 lines)

HumanLayer's research and Anthropic's own guidance converge: shorter `CLAUDE.md` files have higher adherence. Anthropic injects a system reminder telling Claude to ignore the file if it isn't relevant — the more irrelevant content you stuff in, the more likely the relevant rules get ignored too.

This template targets ~55 lines. Everything conditional or task-specific lives in skills.

### 2. Auto Memory replaces manual error logs

Since Claude Code v2.1.59, Auto Memory writes to `~/.claude/projects/<project>/memory/MEMORY.md` automatically. It captures build commands, debugging insights, conventions — exactly what a manual `errors.log` used to track.

Trade-off: Auto Memory is local-machine and not git-versioned. If your team needs shared learnings, keep a separate `LESSONS.md` file in your project root and reference it from `CLAUDE.md`.

### 3. Skills = unit of conditional behavior

Skills load only when their description matches the current task. The body never enters the context window unless invoked. This is Anthropic's progressive disclosure pattern.

Rule of thumb: if a behavior is needed every session, it goes in `CLAUDE.md`. If it's needed only sometimes, it's a skill.

### 4. Hooks = deterministic enforcement

`CLAUDE.md` and skills are advisory — Claude follows them ~80% of the time. For invariants that must hold 100% of the time (security, compliance), use hooks. They run before tool execution and can deny, allow, or ask deterministically.

This template uses hooks for security only. Style and convention enforcement is left to the user (use `post-write-format` hook as a starting point).

### 5. Hindsight = explicit self-improvement

Claude Code has no native mechanism to evolve its own rules between sessions. The `hindsight` skill closes that loop: at session end, if rules failed, Claude proposes improvements and waits for user approval before modifying anything.

This is the one piece of this template that has no Anthropic-native equivalent yet.

## What we deliberately don't do

- **No automatic CLAUDE.md self-modification** — every rule change goes through user review.
- **No multi-agent orchestration framework** — Anthropic's subagents and agent teams cover this; we don't reinvent.
- **No vendored Anthropic SDK or models config** — this is config only, no runtime code.
- **No telemetry or analytics** — purely local.

## Why OODA?

Boyd's OODA loop predates AI agents by 50 years and was designed for high-stakes decisions under uncertainty. Modern agentic AI faces the same constraint: act on incomplete information, observe results, adapt. Other frameworks (PDCA, ReAct, ReWOO) tend to either over-prescribe or skip the critical "Orient" step where most quality is gained.

## Why INVEST for plans

Anthropic issue #20051 documented that waterfall plans + mid-task context compaction produced 100% implementation hallucination rates. INVEST steps (Independent, Negotiable, Valuable, Estimable, Small, Testable) survive compaction better because each step is a self-contained, validatable unit.
