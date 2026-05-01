---
name: anti-hallucination
description: Applies Anthropic's official anti-hallucination techniques. IMPORTANT - use this skill when working with documents over 20k tokens, when making factual claims about code or APIs Claude has not directly verified, when the user mentions "verify", "fact-check", "hallucination", "make sure", or whenever Claude is uncertain whether to fabricate or admit ignorance.
user-invocable: false
---
# Anti-Hallucination Protocol

Source: https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/reduce-hallucinations

## A. Allow "I don't know"

Explicit uncertainty is ALWAYS preferable to confident fabrication.
Format: `[UNCERTAIN] I haven't verified X. To confirm, I can: ...`
Never invent: function signatures, file paths, CLI options, doc URLs.

## B. Quote-first grounding (documents >20k tokens)

1. Extract verbatim relevant quotes with location (`file:line`)
2. Place quotes in scratchpad
3. Reason ONLY on quotes, not on memory of the document

If no relevant quote → answer "the document doesn't contain this info" rather than fabricate.

## C. Verify with citations

Every factual claim points to a source: `(src/foo.py:42)`, `(docs/spec.md#auth)`, or `(output of: pytest -v)`.
No source available → prefix with `[UNVERIFIED]`.

## D. Read before edit (Claude Code extension)

- Never modify a file without reading it in current session
- Never use API/lib without verifying current signature (`--help`, `man`, official doc, or minimal test)
- Critical after context compaction: compacted memory is a HINT, not a fact

## E. Plan Mode anti-hallucination

Known bug: mid-task compaction + waterfall plans → 100% implementation hallucinations (issue #20051).
Mitigation: INVEST steps with per-step validation (use `plan-before-code` skill).
