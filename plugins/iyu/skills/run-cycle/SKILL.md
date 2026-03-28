---
name: run-cycle
description: Execute iterative development cycles — scope→implement→review→carry-forward loop
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

Execute iterative development cycles. Complete all cycles sequentially **without interruption**.

## Parameters

- Total cycles: `$0` (default: 5)
- Starting cycle number: `$1` (default: 1)
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

Define this cycle's scope from the roadmap.

**Inherited defects are mandatory scope.** If the previous cycle's Carry-Forward contains actionable items (not human-judgment), they are the FIRST priority of this cycle. New roadmap work comes AFTER inherited defects are resolved. If inherited defects consume the entire cycle, that is acceptable — reduce new scope, not defect resolution.

### STEP 2: Implement

**Research first** when encountering unfamiliar territory, external integrations, or security/performance concerns. Use WebSearch.

Implement the scope. Progress incrementally. This includes fixing inherited defects.

### STEP 3: Review & Evaluate

Objective quality review — examine this cycle's work critically:

- Run the project's test suite, linter, and build. On failure: **fix and re-run immediately**.
- Review the implementation against scope goals — does it meet intent?
- Check for bugs, unhandled edge cases, architecture violations
- Check for latent issues in surrounding code discovered during this cycle's work
- Check for philosophy drift — scope creep, application-level concerns leaking into library

**Every actionable defect found here must be fixed before leaving this step.** Loop: discover → fix → re-verify until no actionable defects remain. Only items requiring human judgment are exempt.

### STEP 4: Carry-Forward

Record **only** what cannot be resolved autonomously:

- **Pending Human Decisions**: Decisions requiring human input (breaking API, major architecture, ambiguous scope)
- **Discovered but out-of-scope**: Issues found in unrelated areas, to be addressed in future cycles
- **Next Recommendation**: What the next cycle should tackle

**Do NOT carry forward defects that could have been fixed in STEP 3.** If you can fix it, fix it now.

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

## Review & Resolution
{Defects found during review and how each was resolved — or "No defects found"}

## Carry-Forward
- Pending Human Decisions: {decisions needing human input, or "None"}
- Discovered out-of-scope: {issues in unrelated areas, or "None"}
- Next Recommendation: {what next cycle should tackle}
```

---

## Execution Rules

1. **No interruptions**: Make all decisions autonomously. Do not ask for confirmation.
2. **Fix what you find**: Defects discovered in review MUST be resolved in the same cycle. Do not defer fixable work.
3. **Inherited defects first**: Carry-Forward from the previous cycle is mandatory scope — resolve before new work.
4. **Self-recovery**: Fix test failures, compilation errors, and continue.
5. **Logs required**: Always write cycle log before next cycle.
6. **Quality first**: Reduce new scope if needed — never reduce defect resolution.
7. **Research actively**: Use WebSearch to gather evidence. No guesswork.
8. **Defect honesty**: Never hide issues. "It works" ≠ "It's good".
9. **Early termination**: If STEP 3 review finds **zero actionable defects** AND no inherited defects remain (only human-judgment items), terminate early — the project is stable.
10. **Human judgment deferral**: For decisions requiring human input (breaking API, major architecture), record in Carry-Forward and continue with everything else.
11. **Continuity chain**: Always read the previous cycle's Carry-Forward before setting scope.
12. **Latent work priority**: Actively seek issues beyond the explicit scope — the best cycles fix things nobody asked about.

## Commit

- Commit **once** after all cycles complete (or on early termination)
- Use built-in `/commit`
- **NEVER bump MAJOR version**

## Start

Begin immediately: Preparation → Cycle 1 → Cycle 2 → ... → Cycle N.
