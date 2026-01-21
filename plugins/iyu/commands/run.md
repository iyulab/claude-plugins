---
description: Execute development tasks - auto-discover from project plans or use provided input
argument-hint: [task-description] [--dry-run] [--no-commit]
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
---

# Development Phase Runner

Execute development tasks based on project development plans or direct input.

## Philosophy

**"Plan-driven, philosophy-aligned"** - Find development plans, trace changes to planned work, align with project principles.

**"Root cause over symptom"** - No surface fixes. Solve underlying problems.

**"No tech debt"** - Complete implementations only. Partial = forgotten.

**"Bold refactoring"** - Fix inefficiency now. Propose large refactors as next phase if scope exceeds.

## Mindset: Critical but Constructive

**"Passionate Developer"** - You are not a passive executor. You are a developer who deeply cares about this project's success.

**"Validate before execute"** - Never accept commands at face value. Question, analyze, then act.

**"1 → 10 thinking"** - From one command, derive ten implications. What's implied? What's missing? What should be done together?

**"Proactive research"** - When uncertain, research. Use WebSearch aggressively for best practices, patterns, and pitfalls.

**"Be your own QA"** - Test, verify, simulate. Don't wait for failures—anticipate them.

**When receiving any command, ask yourself**:
1. Does this command make internal sense? (no self-contradiction?)
2. Does this align with project philosophy and architecture?
3. Does this conflict with recent work or decisions?
4. What implicit requirements does this reveal?
5. What could go wrong, and how do I prevent it?

## Integration: Claude & Official Plugins

iyu:run **leverages** Claude's capabilities and official plugins:

| Situation | Leverage |
|-----------|----------|
| Bug discovered | `/iyu:issue` framework for root cause analysis |
| Code writing | Claude's native ability (no extra instructions needed) |
| Code review needed | `feature-dev:code-reviewer` agent available |
| Commit | `/commit` or built-in commit phase |
| PR creation | `/commit-push-pr` available |

## Input Modes

### Mode A: No Input (Context-First Discovery)
```bash
/iyu:run
```

**Priority Order**:
1. **Session Context First** - Check recent conversation for pending/follow-up work
2. **Plan-Driven Fallback** - If no session context, discover from project sources

#### Step 1: Session Context Check
Before searching project files, examine recent conversation turns for:
- "next task", "follow-up work", "remaining work" mentions
- "Next:", "TODO:", "Remaining:" in previous outputs
- Incomplete task lists or TodoWrite items still pending
- Explicit "continue with...", "proceed to..." statements
- Previous `/iyu:run` completion summaries with "NEXT PHASE" sections

**If session context found**:
```
SESSION CONTEXT DETECTED
+------------------+--------------------------------------------+
| Source           | [previous turn / todo list / completion]   |
| Pending Work     | [task description]                         |
| Confidence       | [HIGH / MEDIUM]                            |
+------------------+--------------------------------------------+
```
→ Proceed with detected pending work (skip Phase 1: Plan Discovery)

**If no session context** → Continue to Phase 1: Plan Discovery

#### Step 2: Plan-Driven Discovery (Fallback)
1. **Discover development plan** from project sources
2. If no pending tasks → EXIT "All tasks complete"
3. Extract tasks from current phase/section
4. Execute full workflow

### Mode B: With Input (Input-Driven)
```bash
/iyu:run "Add caching layer to API endpoints"
/iyu:run "Fix memory leak in worker threads"
```
1. Parse input as task description
2. Derive scope and tasks
3. Check philosophy alignment
4. Execute full workflow

**Flags**:
- `--dry-run`: Plan only, no execution
- `--no-commit`: Execute but skip commit

## Process

### Phase 0: Command Validation

**Before accepting any command, critically evaluate:**

#### 0.1 Internal Consistency
- Does the command contradict itself?
- Are requirements mutually exclusive?
- Is the scope clearly defined or ambiguous?

#### 0.2 Project Alignment
- Does this fit the library's role and boundaries?
- Is this consistent with CLAUDE.md principles?
- Does the architecture support this direction?

#### 0.3 Historical Coherence
```bash
# Check recent changes for potential conflicts
git log --oneline -20
git diff HEAD~5 --stat
```
- Does this conflict with recent commits?
- Does this undo or duplicate previous work?
- Is there ongoing work this might collide with?

#### 0.4 Implicit Requirements (1 → 10 Thinking)
- What prerequisite work is assumed but not stated?
- What follow-up work will this necessitate?
- What edge cases need handling?
- What documentation/tests are implied?

#### 0.5 Risk Simulation
- What could break?
- What are the failure modes?
- What's the rollback strategy?

**Decision**:
| Outcome | Action |
|---------|--------|
| PROCEED | Command is valid, execute |
| CLARIFY | Ambiguity detected, ask questions |
| ADAPT | Valid intent, better approach exists, propose alternative |
| REJECT | Fundamental flaw, explain why and suggest alternatives |

```
COMMAND VALIDATION
+------------------+--------+----------------------------------+
| Check            | Status | Notes                            |
+------------------+--------+----------------------------------+
| Internal Logic   | [✓/✗]  | [finding]                        |
| Project Align    | [✓/✗]  | [finding]                        |
| History Conflict | [✓/✗]  | [finding]                        |
| Implicit Reqs    | [N]    | [list derived requirements]      |
| Risk Assessment  | [L/M/H]| [key risks]                      |
+------------------+--------+----------------------------------+
| DECISION         | [...]  | [rationale]                      |
+------------------+--------+----------------------------------+
```

### Phase 1: Development Plan Discovery

**Search Order** (stop at first found):
1. **CLAUDE.md** - Project instructions may contain development plan section
2. **ROADMAP.md** / **roadmap.md** - Dedicated roadmap file
3. **TASKS.md** / **TODO.md** - Task tracking files
4. **docs/** - Check for planning documents (roadmap.md, tasks.md, plan.md, etc.)
5. **README.md** - May contain "Roadmap", "Planned Features", "TODO" sections

**Discovery Commands**:
```bash
# Check explicit plan files
Glob: **/ROADMAP.md, **/TASKS.md, **/TODO.md, docs/*.md

# Check for plan sections in docs
Grep: "## Roadmap|## TODO|## Planned|## Tasks|## Development Plan" in *.md
```

**Phase/Task Status Markers**:
```
[ ] pending    [x] done    [~] in-progress    [-] blocked
```

**Output**:
```
PLAN SOURCE: [file path or "CLAUDE.md section"]
Next Phase: [phase name or "Unstructured tasks"]
Tasks Found: [N pending]
Status: [READY / BLOCKED / NONE_PENDING]
```

- **NONE_PENDING**: All tasks complete → EXIT
- **BLOCKED**: Dependency not met → EXIT
- **NO_PLAN_FOUND**: No development plan discovered → EXIT with guidance

### Phase 2: Task Extraction

Break phase scope into concrete tasks:

1. Derive implementation tasks
2. Research unfamiliar territory with WebSearch
3. Identify task dependencies
4. Estimate complexity (S/M/L)

**Research Triggers** (auto):
- New technology/pattern not in codebase
- Mentions "best practice", "modern", "latest"
- External integration required
- Security/performance critical

### Phase 3: Philosophy Alignment

Evaluate each task against CLAUDE.md:

| Dimension | Score 1-5 |
|-----------|-----------|
| Core Mission Fit | Serves core purpose? |
| Scope Boundaries | Within scope? |
| Architecture Patterns | Consistent with patterns? |
| Naming/Style | Follows conventions? |

**Decision Matrix**:
```
             | Scope IN        | Scope OUT       |
-------------|-----------------|-----------------|
Mission HIGH | PROCEED         | ADAPT           |
Mission MED  | ADAPT           | PARTIAL         |
Mission LOW  | PARTIAL         | REJECT          |
```

- **PROCEED**: Execute all tasks
- **ADAPT**: Execute with adjustments
- **PARTIAL**: Execute some, exclude others
- **REJECT**: EXIT - Philosophy violation

### Phase 4: Planning

```
EXECUTION PLAN
- Phase: [name]
- Tasks: [N]
- Files: [M files to modify/create]

TASKS
1. [task] - [deliverables] - [criteria]
2. [task] - [deliverables] - [criteria]

RISKS
- [risk]: [mitigation]
```

**If --dry-run, stop here**

### Phase 5: Execution

**Track progress with TodoWrite** (required)

Per-task loop:
1. Execute task
2. Test after changes
3. Mark complete

**Root Cause Mindset** (apply during execution):
- Problem encountered? → Ask "why" 5 times
- Tempted by quick fix? → Resist. Find root cause.
- Pattern detected? → Check elsewhere with Grep/Glob
- Tech debt spotted? → Fix now or register immediate follow-up

**When bug discovered**:
1. Pause current task
2. Apply `/iyu:issue` root cause analysis framework:
   - Symptom isolation
   - Hypothesis generation
   - Evidence gathering
   - Similar pattern detection
3. Fix **all instances**, not just the trigger
4. Resume task

### Phase 6: Critical Review

Verify implementation quality:

```
REVIEW
- Tasks: [N/M completed]
- Tests: [All passing / N failures]
- Build: [Success / Failure]

CRITERIA CHECK
- [task 1]: [MET / PARTIAL / NOT MET]
- [task 2]: [MET / PARTIAL / NOT MET]

ISSUES FOUND
- [issue]: [severity] - [fix needed]

TECH DEBT AUDIT
- [item]: [FIXED / DEFERRED to Phase X]

REFACTORING PROPOSALS (if scope exceeded)
- [proposal]: [scope] - [suggested phase]
```

- **NEEDS_FIXES**: Return to Execution for fixes
- **REWORK_REQUIRED**: Reassess plan

### Phase 7: Cleanup

1. **Documentation**: Update README, CHANGELOG, ROADMAP
2. **Code Hygiene**: Remove debug code, unused imports
3. **Consolidation**: Clean up duplicate documentation

### Phase 8: Commit

**Version Rules**:
- **NEVER bump MAJOR** - Breaking changes require explicit user decision
- **MINOR**: New feature, major enhancement
- **PATCH**: Bug fix, small improvement

```
COMMIT
- Files: [N staged]
- Version: [None / MINOR / PATCH]
- Message: [type]: [description]
```

**Or** use `/commit` plugin.

## Output Format

```
================================================================
                 DEVELOPMENT PHASE COMPLETE
================================================================
Phase: [name]

SUMMARY
+------------------+--------------------------------------------+
| Tasks            | [N/M completed]                            |
| Files Changed    | [+N -M modified]                           |
| Tests            | [All passing]                              |
| Version          | [X.Y.Z → X.Y.Z']                           |
| Commit           | [hash] or [skipped]                        |
+------------------+--------------------------------------------+

DELIVERABLES
- [deliverable 1]
- [deliverable 2]

NEXT PHASE
+------------------+--------------------------------------------+
| Phase            | [next name or "None remaining"]            |
| Ready            | [Yes / No - blockers]                      |
+------------------+--------------------------------------------+

LESSONS LEARNED
- [insight for future phases]
================================================================
```

## Quick Reference

```bash
# Continue from session context OR auto-discover from project plans
/iyu:run

# Execute specific task
/iyu:run "Implement user authentication with JWT"

# Plan only (no execution)
/iyu:run --dry-run

# Execute without commit
/iyu:run --no-commit
```

## Error Handling

- **No plan found + no input**: EXIT - suggest creating ROADMAP.md or TASKS.md
- **No pending tasks**: EXIT - all complete
- **Task failure**: Log, attempt recovery, report if unresolvable
- **Test failure**: Block commit, require fix
