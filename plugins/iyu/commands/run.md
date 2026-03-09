---
description: Execute development tasks — auto-discover from project plans or use provided input
argument-hint: [task-description] [--dry-run] [--no-commit]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
---

# Development Runner

Execute a single development phase. For iterative multi-cycle work, use `/iyu:run-cycle`.

## Input Modes

### Mode A: No Input (Context-First Discovery)

**Priority Order**:
1. **Session Context** — pending/follow-up work from conversation
2. **Plan Discovery** — CLAUDE.md → ROADMAP.md / TASKS.md / TODO.md → docs/ → README.md

**Outcomes**: READY → proceed | NONE_PENDING → exit | BLOCKED → exit with info | NO_PLAN_FOUND → exit with guidance

### Mode B: With Input
```bash
/iyu:run "Add caching layer to API endpoints"
```

**Flags**: `--dry-run` (plan only) | `--no-commit` (skip commit)

## Process

### Phase 1: Scope Discovery

Session context first. If nothing: search project files (stop at first found). If nothing found: exit — do not invent scope.

### Phase 2: Philosophy Alignment

Before execution, evaluate scope against CLAUDE.md / README.md:

| Dimension | Question |
|-----------|----------|
| Core Mission Fit | Serves core purpose? |
| Scope Alignment | Within library responsibility? |
| Pattern Consistency | Consistent with existing patterns? |

|  | Scope IN | Scope OUT |
|--|----------|-----------|
| Mission HIGH | PROCEED | ADAPT |
| Mission MED | ADAPT | PARTIAL |
| Mission LOW | PARTIAL | REJECT |

**Latent discovery**: While reading the codebase for alignment, actively look for related issues, inconsistencies, or improvements that should be addressed alongside the explicit task.

**If --dry-run, stop here.**

### Phase 3: Execution

Per-task: execute → test → complete.

**Root cause mindset**: When problems surface, ask "why" 5 times. Fix all instances, not just the trigger.

### Phase 4: Verify & Commit

All tasks complete, tests passing, build succeeds.

**Version rules**: NEVER bump MAJOR — MINOR for features, PATCH for fixes.

## Error Handling

- **No plan + no input**: Exit with guidance to create ROADMAP.md or provide input
- **No pending tasks**: Exit "All complete"
- **Task failure**: Log, attempt recovery, report if unresolvable
- **Test failure**: Block commit, require fix
