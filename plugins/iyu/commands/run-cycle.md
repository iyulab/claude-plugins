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
- `--no-commit`: Execute but skip commits

## Preparation

### 1. Conversation Context (HIGHEST PRIORITY)

Before any file search, check the preceding conversation for scope:
- Explicit task descriptions, discussed features/bugs/improvements
- Agreed-upon next steps, "continue with..." statements

**If conversation provides clear scope** → Use directly, skip plan discovery.

### 2. Previous Cycle Logs

```bash
Glob: claudedocs/cycle-logs/cycle-*.md
```

Review the most recent log — especially **Carry-Forward** section (unresolved issues, pending decisions, next scope recommendation). These are your inherited obligations.

### 3. Development Plan Discovery

**Only if no scope from conversation or previous cycles.**

Search order (stop at first found):
1. CLAUDE.md — development plan section
2. ROADMAP.md / TASKS.md / TODO.md
3. docs/ — planning documents
4. README.md — "Roadmap", "Planned Features" sections

**If nothing found** → Ask the user. Do not invent scope.

### 4. Roadmap Establishment

If no roadmap exists, create one at `claudedocs/cycle-logs/ROADMAP.md`:
- Phased plan aligned to total cycle count
- Goals and scope per cycle
- Inter-cycle dependencies

**If --dry-run, stop here.**

---

## Per-Cycle Process (5 Steps)

### STEP 1: Scope & Alignment

Define this cycle's scope, then evaluate philosophy alignment:

| Dimension | Score 1-5 |
|-----------|-----------|
| Core Mission Fit | Does it serve the project's core purpose? |
| Scope Boundaries | Is it within project scope? |
| Architecture Patterns | Consistent with existing patterns? |
| Dependency Direction | No upstream→downstream leakage? |

**Decision**:

|  | Scope IN | Scope OUT |
|--|----------|-----------|
| Mission HIGH | PROCEED | ADAPT scope |
| Mission MED | ADAPT approach | REDUCE scope |
| Mission LOW | RECONSIDER | SKIP |

### STEP 2: Research & Implement

**Research first** when encountering: new technologies, external integrations, security/performance concerns, complex algorithms. Use WebSearch actively.

Then implement. Write tests alongside code. Progress incrementally.

### STEP 3: Test & Verify

Run the project's test suite, linter, and build. On failure: fix and re-run.

### STEP 4: Objective Evaluation

Evaluate on a **1-10 scale**:

| Criterion | Description |
|-----------|-------------|
| Correctness | Feature works? Edge cases handled? |
| Architecture | Consistent design? Appropriate abstractions? |
| Philosophy Alignment | Aligned with project principles? Within scope? |
| Test Quality | Sufficient meaningful tests? Core scenarios covered? |
| Documentation | Self-explanatory code? Necessary docs present? |
| Code Quality | Language idioms? Readability? Maintainability? |

- **Score 7 or below**: Must record specific defects
- **No self-leniency**: "It works" ≠ "It's good"

### STEP 5: Issues & Carry-Forward

Record defects, architectural discoveries, and recommendations for next cycle.

---

## Cycle Log Format

Write `claudedocs/cycle-logs/cycle-{NN}.md` after each cycle:

```markdown
# Cycle {NN}: {Title}
Date: {YYYY-MM-DD}

## Continuity
- Previous: cycle-{NN-1} — {previous title, or "N/A" if first cycle}
- Inherited Issues: {issues carried from previous cycle, or "None"}
- Inherited Decisions: {pending human decisions carried forward, or "None"}
- How Addressed: {how inherited items were handled this cycle}

## Scope
{what this cycle tackled — explicitly note which previous recommendations were addressed}

## Philosophy Alignment
| Dimension | Score |
|-----------|-------|
| Core Mission Fit | /5 |
| Scope Boundaries | /5 |
| Architecture Patterns | /5 |
| Dependency Direction | /5 |

## Research Summary
{findings and sources, or "N/A"}

## Implementation
{summary, files changed, key decisions}

## Test Results
{pass/fail, lint, build status}

## Evaluation
| Criterion | Score | Notes |
|-----------|-------|-------|
| Correctness | /10 | |
| Architecture | /10 | |
| Philosophy Alignment | /10 | |
| Test Quality | /10 | |
| Documentation | /10 | |
| Code Quality | /10 | |
| **Average** | **/10** | |

## Carry-Forward
- Unresolved Issues: {issues to pass to next cycle, or "None"}
- Pending Human Decisions: {accumulated decisions needing human input, or "None"}
- Next Scope Recommendation: {what next cycle should tackle, or "No further cycles needed"}
```

---

## Execution Rules

1. **No interruptions**: Make all decisions autonomously. Do not ask for confirmation.
2. **Self-recovery**: Fix test failures, compilation errors, and continue.
3. **Logs required**: Always write cycle log before next cycle.
4. **Quality first**: Reduce scope if needed to achieve high quality.
5. **Research actively**: Use WebSearch to gather evidence. No guesswork.
6. **Honest evaluation**: Never hide defects or inflate scores.
7. **Early termination**: If STEP 5 finds **zero issues**, terminate early — the project is stable.
8. **Human judgment deferral**: For decisions requiring human input (breaking API changes, major architectural choices), record in **Carry-Forward** and continue with remaining work.
9. **Continuity chain**: Always read the previous cycle's Carry-Forward before setting scope. Inherited issues and decisions must be explicitly addressed or re-deferred with justification.

## Commit Rules

- Message: `cycle-{NN}: {summary}`
- Stage only relevant files (no `git add -A`)
- **NEVER bump MAJOR version** — MINOR for features, PATCH for fixes

## Integration

| Situation | Use |
|-----------|-----|
| Bug discovered | `/iyu:issue` root cause analysis framework |
| Code review needed | `feature-dev:code-reviewer` agent |
| Commit | `/commit` or built-in commit |

## Start

Begin immediately: Preparation → Cycle 1 → Cycle 2 → ... → Cycle N.
