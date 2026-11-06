---
name: accept
description: Judges the open stage by having an independent evaluator subagent drive the real, running build like a user — scenario by scenario, against the rubric — and record an evidence report and the status fields. Use to get a verdict without building anything; `/iyu:drive` dispatches the same evaluator each round.
argument-hint: "[stage id] [--smoke]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Agent
---

# Accept — an independent verdict on the open stage

The verdict comes from **a separate subagent** that sees only the contract, the build and a skeptical
brief — an agent judging its own work tends to spot the defect and then approve anyway. This skill
dispatches that subagent and relays its result. Contract, terms and field ownership:
**[stages.md](${CLAUDE_SKILL_DIR}/../_shared/stages.md)**.

## Process

1. Resolve `<root>` ([continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §1) and
   read `<root>/stages/stages.json` in the current repository only (a contract elsewhere
   belongs to another product). With no contract or no `open` stage, say so, point to
   `/iyu:charter`, and end. The stage is the id in `$ARGUMENTS`, else the `open` one.
2. Dispatch **one** `Agent` call (`subagent_type: general-purpose`). Its prompt is the full text of
   [references/evaluator.md](${CLAUDE_SKILL_DIR}/references/evaluator.md) followed by absolute paths to
   the contract, the stage id and the evidence directory, plus the contract's `run` command and the
   mode (`full`, or `smoke` with `--smoke`). Pass only the contract and the build.
3. Read the evidence file it names and relay the verdict in a few lines: each scenario's result, each
   rubric score against its threshold, claims that moved, and what could **not** be verified. Report
   `unverified` as `unverified`.

## Standing rules

- Your part is dispatching and relaying; the product, the contract's text and the evidence file belong
  to others (stages.md §4).
- The evaluator sets `status: passed` only when `owner_accepted` is already true (stages.md §5).
  Evaluating before the owner has seen the demo is normal and leaves the stage `open`.
- Re-run after the build changes; an unchanged build gets the same verdict.
