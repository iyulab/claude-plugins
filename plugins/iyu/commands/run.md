---
description: Execute development tasks — auto-discover from project plans or use provided input
argument-hint: [task-description] [--dry-run] [--no-commit]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
---

# Development Phase Runner

Execute development tasks based on project plans or direct input.

## Input Modes

### Mode A: No Input (Context-First Discovery)
```bash
/iyu:run
```

**Priority Order**:
1. **Session Context** — Check recent conversation for pending/follow-up work
2. **Plan Discovery** — If no session context, discover from project sources

### Mode B: With Input
```bash
/iyu:run "Add caching layer to API endpoints"
```

**Flags**: `--dry-run` (plan only) | `--no-commit` (skip commit)

---

## Process

### Phase 1: Scope Discovery

**Session context first** — look for:
- "next task", "follow-up work", "remaining work" mentions
- Incomplete TodoWrite items, explicit "continue with..." statements
- Previous `/iyu:run` completion summaries with "NEXT PHASE" sections

**If no session context** → Search project files (stop at first found):
1. CLAUDE.md — development plan section
2. ROADMAP.md / TASKS.md / TODO.md
3. docs/ — planning documents
4. README.md — "Roadmap", "Planned Features" sections

**Outcomes**:
- READY → Proceed to Phase 2
- NONE_PENDING → EXIT "All tasks complete"
- BLOCKED → EXIT with blocker info
- NO_PLAN_FOUND → EXIT "No plan found — create ROADMAP.md or provide task input"

### Phase 2: Task Extraction & Alignment

Break scope into concrete tasks, then evaluate philosophy alignment:

| Dimension | Score 1-5 |
|-----------|-----------|
| Core Mission Fit | Serves core purpose? |
| Scope Boundaries | Within scope? |
| Architecture Patterns | Consistent with patterns? |
| Naming/Style | Follows conventions? |

**Decision**:

|  | Scope IN | Scope OUT |
|--|----------|-----------|
| Mission HIGH | PROCEED | ADAPT |
| Mission MED | ADAPT | PARTIAL |
| Mission LOW | PARTIAL | REJECT |

**If --dry-run, stop here.**

### Phase 3: Execution

Track progress with TodoWrite (required).

Per-task: execute → test → mark complete.

**Root cause mindset**: When problems surface, ask "why" 5 times. Fix all instances, not just the trigger. When a bug is discovered, apply `/iyu:issue` root cause analysis framework.

### Phase 4: Review & Commit

Verify: all tasks complete, tests passing, build succeeds.

**Version Rules**: NEVER bump MAJOR — MINOR for features, PATCH for fixes.

## Integration

| Situation | Use |
|-----------|-----|
| Bug discovered | `/iyu:issue` root cause analysis framework |
| Code review needed | `feature-dev:code-reviewer` agent |
| Commit | `/commit` or built-in commit |

## Error Handling

- **No plan + no input**: EXIT with guidance to create ROADMAP.md or TASKS.md
- **No pending tasks**: EXIT "All complete"
- **Task failure**: Log, attempt recovery, report if unresolvable
- **Test failure**: Block commit, require fix
