---
name: run-cycle
description: Execute adaptive iterative development cycles — each cycle is a self-contained plan/execute/verify/reflect loop that may reshape the roadmap
argument-hint: "[total_cycles] [start_cycle]" [--dry-run] [--no-commit]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Check if all planned development cycles are complete.
            The skill was invoked with arguments: $ARGUMENTS
            If cycles remain incomplete or carry-forward defects are unresolved, respond with block.
            If all cycles are done or early termination conditions are met, allow.
---

# Development Cycle Runner

Execute iterative development cycles. Each cycle is a **self-contained micro-loop** — re-plan, design (if needed), execute, verify, reflect, derive-next. The initial roadmap is **directional, not binding**: later cycles may reshape it based on what earlier cycles reveal.

## Why this shape

A single upfront N-cycle plan followed by sequential execution is indistinguishable from one large implementation — the "cycle" structure adds no discovery value. Real iterative work requires each cycle to:

1. Re-check assumptions made at the start
2. Absorb what previous cycles learned
3. Be able to **change the plan** when reality diverges

The structure below keeps per-cycle overhead bounded while leaving room for mid-flight re-planning.

## Unscoped Bash rationale

`allowed-tools` includes `Bash` without scope. Development execution requires arbitrary build/test/lint/git commands across unknown projects — scoping would require per-project edits. Accepted deliberately; narrow-surface skills (`issue`, `pr`) use `Bash(gh *)` instead.

## Parameters

- Total cycles: `$0` (default: 5)
- Starting cycle number: `$1` (default: 1)
- `--dry-run`: Preparation + directional roadmap only
- `--no-commit`: Skip final commit

---

## Preparation (light)

The preparation phase is **thin by design**. Deep analysis belongs to each cycle's STEP 1, where it can be informed by what's actually happening.

### 1. Conversation Context (highest priority)

Check the preceding conversation for scope — explicit tasks, agreed-upon next steps, "continue with..." statements.

### 2. Previous Cycle Logs

```bash
Glob: claudedocs/cycle-logs/cycle-*.md
```

Review the most recent log's **Carry-Forward** and **Roadmap Revisions** sections. These are inherited obligations and prior re-planning decisions.

### 3. Plan Discovery (only if no scope from above)

Stop at first found: CLAUDE.md → ROADMAP.md / TASKS.md / TODO.md → docs/ → README.md. If nothing found, ask the user. Do not invent scope.

### 4. Philosophy Alignment (high-level only)

Evaluate the overall goal — not every future cycle — against CLAUDE.md / README.md:

| Dimension | Question |
|-----------|----------|
| Core Mission Fit | Serves core purpose? |
| Scope Alignment | Within library responsibility? |
| Pattern Consistency | Consistent with existing patterns? |
| Dependency Direction | No upstream→downstream leakage? |

Reject scope items that score low **at the overall level**. Per-cycle drift checks (STEP 0) catch localized issues later.

### 5. Directional Roadmap

Create `claudedocs/cycle-logs/ROADMAP.md` if missing:

- High-level phased goals — not detailed per-cycle scope
- Marked as **directional**, revisable by per-cycle Derive-Next
- Include known unknowns and investigation needs, not presumed answers

**If --dry-run, stop here.**

---

## Per-Cycle Process

Every cycle runs these six steps in order. Steps are **differentiated by weight** — STEP 0 is always light, STEP 1 runs only when triggered, STEP 4 reflection is always mandatory.

### STEP 0: Re-plan (always, light)

The first thing any cycle does is check whether the plan it inherited is still correct.

**Bounded inputs** (keep this cheap — target <5 minutes):

- Previous cycle's Carry-Forward + Roadmap Revisions
- Current state of the directional roadmap
- Any changes to CLAUDE.md / README.md since the last cycle (diff only, not full re-read)

**Decisions**:

1. **Inherited defects first** — if previous Carry-Forward contains actionable items, they are this cycle's priority scope
2. **Drift check** — 1–2 sentence judgment: has anything in the project invalidated the next planned step?
3. **Trigger check** — see below

**Output**: This cycle's scope, either as-planned or adjusted.

### Trigger matrix

| Trigger | Signal | Action |
|---------|--------|--------|
| 🔴 HARD STOP | Philosophy fundamentally violated by inherited plan, OR architecture change invalidates 3+ future cycles, OR critical dependency deprecated | Log blocker in Carry-Forward, **terminate run-cycle**, escalate to human |
| 🟠 RE-PLAN | Roadmap order/split needs change, but overall goals remain valid | Adjust roadmap autonomously, record in **Roadmap Revisions** log section |
| 🟡 SCOPE ADJUST | This cycle's scope needs trimming or expansion only | Adjust inline, proceed to STEP 1 |
| ⚪ NONE | Plan still valid | Proceed with inherited scope |

HARD STOP is **deliberately narrow**. Agent autonomy covers RE-PLAN and SCOPE ADJUST; human judgment is reserved for structural invalidation. If in doubt between RE-PLAN and HARD STOP, choose RE-PLAN and record the reasoning — the next cycle can escalate further if needed.

### STEP 1: Design (conditional)

**Skip if ALL true** (and record "skipped — pattern-following change" in the log):

- Scope is an isolated, pattern-following change
- Identical patterns already exist in the codebase
- No new external dependencies or API changes
- No performance/security implications

**Otherwise**:

1. **Codebase survey** — trace call paths, map existing patterns and conventions
2. **External research** — WebSearch for best practices, library docs, known pitfalls. Do not guess.
3. **Approach decision** — if multiple viable approaches exist, compare trade-offs and pick one with a 1-line rationale

Record findings briefly in the cycle log. Do not pad this step when skip conditions hold.

### STEP 2: Execute

Implement the scope. Progress incrementally. **Inherited defects are fixed first**, before new roadmap work.

**Root cause mindset**: When problems surface, ask "why" until the real cause emerges. Fix all instances of a pattern, not just the symptom that triggered investigation.

### STEP 3: Verify

- Run the project's test suite, linter, and build
- On failure: **fix and re-run immediately** within this cycle — do not defer
- If a failure exposes a trigger-class issue (HARD STOP / RE-PLAN), loop back to STEP 0 rather than forcing progress

### STEP 4: Reflect & Evaluate (always, mandatory)

Objective quality review. This is the step that makes cycles cumulative rather than sequential.

Assess four dimensions:

1. **Scope fit**: Does the implementation meet the cycle's intent?
2. **Latent defects**: Bugs, unhandled edges, architecture violations in or around the changes
3. **Philosophy drift**: Scope creep, library/application boundary leakage, pattern deviation
4. **Roadmap impact**: Does this cycle's outcome change what future cycles should do?

**Every actionable defect found here is fixed before leaving STEP 4.** Loop: discover → fix → re-verify. Only items requiring human judgment are exempt (breaking API, major architecture, ambiguous scope).

### STEP 5: Derive Next

Record **only** what cannot be resolved autonomously, or what reshapes future cycles:

- **Carry-Forward (actionable)**: Things to address next cycle
- **Pending Human Decisions**: Breaking API, major architecture, ambiguous scope
- **Roadmap Revisions**: If STEP 4's roadmap-impact judgment said "yes" — record the change to `ROADMAP.md` and log it
- **Next Recommendation**: What the next cycle should prioritize

**Do NOT carry forward defects that could have been fixed in STEP 4.** If you can fix it, fix it now.

---

## Cycle Log

Write `claudedocs/cycle-logs/cycle-{NN}.md` after each cycle:

```markdown
# Cycle {NN}: {Title}
Date: {YYYY-MM-DD}

## Re-plan
{Trigger detected (if any) and scope decision — or "Plan valid, inherited scope"}

## Scope & Implementation
{What was tackled, files changed, key design decisions}

## Verification & Defect Resolution
{Test/build status, defects discovered and resolved — or "No defects found"}

## Reflection
{Scope fit, philosophy drift assessment, roadmap impact judgment}

## Carry-Forward
- Actionable: {items for next cycle, or "None"}
- Pending Human Decisions: {decisions needing human input, or "None"}
- Roadmap Revisions: {changes made to ROADMAP.md, or "None"}
- Next Recommendation: {what next cycle should tackle}
```

---

## Execution Rules

1. **No interruptions within a cycle**: Decide autonomously. Do not ask for confirmation mid-cycle.
2. **HARD STOP escalation is allowed**: When a HARD STOP trigger fires, terminate and report — do not force progress.
3. **Fix what you find**: STEP 4 defects MUST be resolved in the same cycle. Do not defer fixable work.
4. **Inherited defects first**: Previous Carry-Forward actionables are mandatory at STEP 0.
5. **Roadmap is directional**: Revise it when evidence requires. Log revisions explicitly in Carry-Forward.
6. **Quality over scope**: Reduce new scope if needed — never reduce defect resolution or reflection depth.
7. **Research actively**: WebSearch before guessing. Record sources.
8. **Defect honesty**: Record issues openly. "It works" ≠ "It's good".
9. **Early termination**: If STEP 4 finds zero actionable defects AND no inherited defects remain AND roadmap is stable, terminate early.
10. **Continuity chain**: Always read the previous cycle's Carry-Forward and Roadmap Revisions before STEP 0.
11. **Latent work priority**: The best cycles fix things nobody asked about — surface them in Reflection.
12. **Cost discipline**: STEP 0 is bounded (~5 min). If drift check seems to require deep analysis, that is a RE-PLAN signal — handle it explicitly rather than letting STEP 0 bloat.

## Commit

- Commit **once** after all cycles complete (or on HARD STOP / early termination)
- Use built-in `/commit`
- **NEVER bump MAJOR version**

## Start

Begin: Preparation → Cycle 1 → Cycle 2 → ... → Cycle N (or until HARD STOP / early termination).
