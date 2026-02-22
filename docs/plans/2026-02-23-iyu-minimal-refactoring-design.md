# iyu Plugin Refactoring: Minimal Instructions, Maximum Extension

## Problem

The iyu plugin (v1.5.2) over-instructs Claude on things it already does natively, burying genuine domain value in 546-line command files. The plugin should teach Claude what's *different* about this project's workflow, not how to develop software.

## Design Principles

1. **Remove**: Anything Claude already does (read project, run tests, follow conventions)
2. **Keep**: Anything Claude can't infer (decision matrices, philosophy scoring, cycle log structure)
3. **Strengthen**: Cycle-to-cycle continuity (Continuity + Carry-Forward pattern)
4. **DRY**: Extract shared philosophy to one auto-skill

## Changes

### 1. New: `skills/mindset/SKILL.md` (~30 lines)

- `user-invocable: false` — auto-loaded, no `/command` exposed
- Contains shared "Critical but Constructive" philosophy
- Replaces 4x duplicated philosophy sections

### 2. Refactor: `commands/run-cycle.md` (546 → ~200 lines)

**Remove**: Project context reading, test command tables, coding convention reminders, 6 of 8 ASCII templates, philosophy section
**Keep**: 5-step cycle structure, philosophy alignment scoring, evaluation criteria, execution rules, early termination, human judgment deferral
**Strengthen**: Cycle log format with Continuity/Carry-Forward sections

### 3. Refactor: `commands/run.md` (386 → ~150 lines)

**Remove**: Phase 0 (Command Validation), philosophy section, detailed execution instructions, cleanup details
**Keep**: Input modes, plan discovery, philosophy alignment matrix, integration table

### 4. Trim: `commands/issue.md` and `commands/pr.md`

**Remove**: Philosophy/mindset sections
**Fix**: Add `Bash` to pr.md allowed-tools
**Keep**: All domain-specific content (matrices, severity, contributor types)

### 5. Strengthen: Agents

**Current**: Thin wrappers ("Follow /iyu:issue process")
**New**: Self-contained with embedded core logic, no command dependency

### 6. Narrow: `skills/issue-triage/SKILL.md`

**Current**: 22 trigger phrases including generic ones
**New**: ~10 maintainer-specific triggers, remove "root cause analysis", "detect patterns" etc.

### 7. Fix: Version consistency

- iyu README.md: 1.4.1 → 1.6.0
- Root README.md: 1.4.0 → 1.6.0
- plugin.json + marketplace.json: 1.5.2 → 1.6.0

## Cycle Log Continuity Design

```markdown
# Cycle {NN}: {Title}

## Continuity
- Previous: cycle-{NN-1} — {title}
- Inherited Issues: [issues carried from previous cycle]
- Inherited Decisions: [pending human decisions carried forward]

## Scope
{scope — explicitly note how previous cycle recommendations were addressed}

## Implementation & Results
{summary, test results, evaluation scores}

## Carry-Forward
- Unresolved Issues: [issues to pass to next cycle]
- Pending Human Decisions: [accumulated decisions needing human input]
- Next Scope Recommendation: [what next cycle should tackle]
```
