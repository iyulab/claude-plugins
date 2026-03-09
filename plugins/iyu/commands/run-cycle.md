---
description: Execute iterative development cycles — scope→research→implement→test→evaluate→improve loop
argument-hint: "[total_cycles] [start_cycle]" [--dry-run] [--no-commit]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
---

# Development Cycle Runner

Execute iterative development cycles. Complete all cycles sequentially **without interruption**.

## Parameters

- Total cycles: `$ARGUMENTS[0]` (default: 5)
- Starting cycle number: `$ARGUMENTS[1]` (default: 1)
- `--dry-run`: Preparation + roadmap only (no execution)
- `--no-commit`: Skip final commit

## Preparation

### 1. Conversation Context (HIGHEST PRIORITY)

Check the preceding conversation for scope — explicit tasks, agreed-upon next steps, "continue with..." statements.

**If conversation provides clear scope** → Use directly, skip plan discovery.

### 2. Previous Cycle Logs

```bash
Glob: claudedocs/cycle-logs/cycle-*.md
```

Review the most recent log — especially **Carry-Forward** section. These are inherited obligations.

### 3. Development Plan Discovery

**Only if no scope from conversation or previous cycles.**

Search order (stop at first found):
1. CLAUDE.md — development plan section
2. ROADMAP.md / TASKS.md / TODO.md
3. docs/ — planning documents
4. README.md — "Roadmap", "Planned Features" sections

**If nothing found** → Ask the user. Do not invent scope.

### 4. Philosophy Alignment (once, not per-cycle)

Before any execution, evaluate the full scope against CLAUDE.md / README.md:

| Dimension | Question |
|-----------|----------|
| Core Mission Fit | Serves core purpose? |
| Scope Alignment | Within library responsibility? |
| Pattern Consistency | Consistent with existing patterns? |
| Dependency Direction | No upstream→downstream leakage? |

Adjust, reduce, or reject scope items that score low. This is done **once** at preparation — individual cycles inherit the result.

### 5. Roadmap Establishment

If no roadmap exists, create one at `claudedocs/cycle-logs/ROADMAP.md`:
- Phased plan aligned to total cycle count
- Goals and scope per cycle

**If --dry-run, stop here.**

---

## Per-Cycle Process

### STEP 1: Scope

Define this cycle's scope from the roadmap. If continuing from a previous cycle, address Carry-Forward items first.

### STEP 2: Research & Implement

**Research first** when encountering unfamiliar territory, external integrations, or security/performance concerns. Use WebSearch.

Then implement. Progress incrementally.

### STEP 3: Test & Verify

Run the project's test suite, linter, and build. On failure: fix and re-run.

### STEP 4: Defect Discovery

The core of quality control. Instead of scoring, **find what's wrong**:

- **Bugs**: Incorrect behavior, unhandled edge cases
- **Architecture violations**: Inconsistencies with existing patterns
- **Latent issues**: Problems in surrounding code discovered during this cycle's work — things nobody asked about but should be fixed
- **Philosophy drift**: Scope creep, application-level concerns leaking into library

**If zero defects found** → This is the early termination signal.

### STEP 5: Carry-Forward

Record unresolved defects, architectural discoveries, and latent issues for the next cycle.

---

## Cycle Log

Write `claudedocs/cycle-logs/cycle-{NN}.md` after each cycle:

```markdown
# Cycle {NN}: {Title}
Date: {YYYY-MM-DD}

## Inherited → Addressed
{What was carried from previous cycle and how it was handled, or "First cycle"}

## Scope & Implementation
{What was tackled, files changed, key decisions}

## Defects Found
{List of bugs, violations, latent issues discovered — or "None" for early termination signal}

## Carry-Forward
- Unresolved: {issues to pass to next cycle, or "None"}
- Pending Human Decisions: {decisions needing human input, or "None"}
- Next Recommendation: {what next cycle should tackle}
```

---

## Execution Rules

1. **No interruptions**: Make all decisions autonomously. Do not ask for confirmation.
2. **Self-recovery**: Fix test failures, compilation errors, and continue.
3. **Logs required**: Always write cycle log before next cycle.
4. **Quality first**: Reduce scope if needed to achieve high quality.
5. **Research actively**: Use WebSearch to gather evidence. No guesswork.
6. **Defect honesty**: Never hide issues. "It works" ≠ "It's good".
7. **Early termination**: If STEP 4 finds **zero defects**, terminate early — the project is stable.
8. **Human judgment deferral**: For decisions requiring human input (breaking API, major architecture), record in Carry-Forward and continue.
9. **Continuity chain**: Always read the previous cycle's Carry-Forward before setting scope.
10. **Latent work priority**: Actively seek issues beyond the explicit scope — the best cycles fix things nobody asked about.

## Commit

- Commit **once** after all cycles complete (or on early termination)
- Use built-in `/commit`
- **NEVER bump MAJOR version**

## Start

Begin immediately: Preparation → Cycle 1 → Cycle 2 → ... → Cycle N.
