---
description: Triage external issues with critical evaluation against project philosophy and scope
argument-hint: <issue-url | file-path | "issue text"> [--quick] [--save] [--no-research]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
---

# Issue Triage Command

Analyze external issues and make decisions aligned with project philosophy.

## Input

- **URL**: `https://github.com/user/repo/issues/123`
- **File**: `./docs/feature-request.md`
- **Text**: `"Add support for Redis caching"`

**Flags**:
- `--quick`: Skip phases 5-8, decision only
- `--save`: Save to `./claudedocs/triage-[date]-[title].md`
- `--no-research`: Skip web research

## Process

### Phase 0: Actionability Check (GitHub/GitLab URLs only)

Check if action is needed first. **Read ALL comments**.

```
gh issue view <number> --repo <owner/repo> --comments --json title,body,state,comments,labels,author
```

**Resolution signals** (SKIP):
- Maintainer: "Fixed in...", "Resolved by...", "Closing as..."
- Requester: "Thanks, works now", "Issue resolved"
- Marked as duplicate

**Unresolved signals** (PROCEED):
- "Still happening", "Not fixed", "Same issue"
- Recent comments reporting ongoing problems
- Closed but requesting reopen

**Spam signals** (SKIP):
- Empty issue, "me too" only, promotional content

### Phase 1: Issue Intake

**Surface Request**: What they're literally asking for
**Underlying Need**: The real problem they're solving
**Root Cause**: Why did this request emerge? What project gap?
**Mental Model**: How requester thinks the project should work
**Prevention**: What would have made this request unnecessary?

### Phase 1.5: Bug Classification

Bug detection signals:
- Labels: `bug`, `error`, `fix`, `crash`, `regression`
- Keywords: "error", "broken", "fail", "not working"
- Patterns: Stack traces, error messages, reproduction steps

**If classified as bug** → Proceed to Phase 1.6-1.8
**Otherwise** → Skip to Phase 2

### Phase 1.6: Root Cause Analysis (Bugs only)

**Symptom vs Cause**: User report ≠ actual problem
**Hypothesis Tree**: Generate multiple possible causes, gather evidence for each
**Cause Chain**: `[Action] → [Component] → [ROOT CAUSE] → [Symptom]`

Use Grep/Glob/Read to investigate codebase.

### Phase 1.7: Similar Pattern Detection (Bugs only)

After identifying root cause, search for same pattern elsewhere:

| Risk | Meaning |
|------|---------|
| 🔴 Critical | Same bug, different location |
| 🟠 High | High probability of same latent defect |
| 🟡 Medium | Should review |
| 🟢 Low | Monitor only |

**Search strategies**: Same function names, API patterns, error handling, similar logic flow

### Phase 1.8: Solution Research (Complex bugs only)

**Auto-trigger conditions** (if ANY):
- 5+ files affected or architectural changes needed
- <3 similar patterns in codebase (unfamiliar territory)
- Mentions "best practice", "modern approach"
- Third-party library/API related
- Security or performance critical

Use WebSearch for latest best practices.

### Phase 2: Philosophy Alignment

Evaluate against CLAUDE.md or README.md:

| Dimension | Question | Score |
|-----------|----------|-------|
| Core Mission Fit | Serves project's core purpose? | 1-5 |
| Scope Alignment | Library vs application responsibility? | 1-5 |
| Pattern Consistency | Consistent with existing architecture? | 1-5 |
| User Base Impact | Benefits majority or niche? | 1-5 |

**Overall**: High (4-5) / Medium (3-3.9) / Low (1-2.9)

### Phase 3: Feasibility Assessment

| Factor | Rating |
|--------|--------|
| Technical Complexity | Low / Medium / High |
| Breaking Changes | None / Minor / Major |
| Maintenance Burden | Low / Medium / High |
| Dependencies | None / Dev-only / Runtime |

**Overall Feasibility**: High / Medium / Low

### Phase 4: Decision

```
                 | Philosophy HIGH | Philosophy LOW  |
-----------------|-----------------|-----------------|
Feasibility HIGH | ACCEPT          | REDIRECT        |
Feasibility MED  | ADAPT           | DEFER/REDIRECT  |
Feasibility LOW  | DEFER           | DECLINE         |
```

**Decision Definitions**:
- **ACCEPT**: Fully aligned, implement as requested
- **ADAPT**: Good idea, implement differently (propose variation)
- **DEFER**: Valuable but not now (provide conditions/roadmap)
- **REDIRECT**: Out of scope, provide alternative path
- **DECLINE**: Fundamentally misaligned, explain respectfully

### Phase 5: Task Execution (Skip if --quick or DEFER/REDIRECT/DECLINE)

If ACCEPT or ADAPT:
1. Create implementation plan with TodoWrite
2. Execute code, test, documentation changes
3. Run tests, check for regressions

### Phase 6: Strategic Insight (Skip if --quick)

**"Think 10 from 1"** - Extract deeper insights beyond immediate decision:

| Gap Type | Question |
|----------|----------|
| Documentation | What wasn't clearly documented? |
| API | Does current API make this use case unnecessarily difficult? |
| Example | What example would have answered this? |
| Architecture | Does project structure make this harder? |

**Preventive Actions**: FAQ updates, error message improvements, documentation enhancements

### Phase 7: Knowledge Capture (Skip if --quick)

- CLAUDE.md update needed?
- FAQ entry to add?
- ADR (Architecture Decision Record) to create?

### Phase 8: Response Draft

Structure response by decision type:
- **ACCEPT**: Thanks + implementation plan + welcome contributions
- **ADAPT**: Show understanding + propose variation + request feedback
- **DEFER**: Acknowledge value + explain current priorities + roadmap
- **REDIRECT**: Show understanding + explain scope + provide alternatives
- **DECLINE**: Thanks + specific reasons + suggest alternatives

## Output Format

```
================================================================
                    ISSUE TRIAGE
================================================================
Issue: [title]
Source: [URL / file / text]
Author: @[username]

ACTIONABILITY (GitHub/GitLab only)
+------------------+--------------------------------------------+
| Status           | [Open/Closed]                              |
| Final State      | [Resolved/Unresolved/Disputed]             |
| Actionability    | [PROCEED/SKIP/REVIEW]                      |
| Reason           | [explanation]                              |
+------------------+--------------------------------------------+

UNDERSTANDING
+------------------+--------------------------------------------+
| Surface Request  | [literal request]                          |
| Underlying Need  | [real problem]                             |
| Root Cause       | [project gap]                              |
| Prevention       | [what would have prevented this]           |
+------------------+--------------------------------------------+

CLASSIFICATION
+------------------+--------------------------------------------+
| Type             | [BUG/FEATURE_REQUEST/ENHANCEMENT/OTHER]    |
| Bug Confidence   | [High/Medium/Low/N/A]                      |
| Deep Analysis    | [ENABLED/DISABLED]                         |
+------------------+--------------------------------------------+

ROOT CAUSE ANALYSIS (if bug)
- Symptom: [user report]
- Root Cause: [actual cause]
- Location: [file:line]
- Cause Chain: [Action] → [Component] → [ROOT] → [Symptom]

SIMILAR PATTERNS (if bug)
+------+------------+------------------+----------------------+
| Risk | Location   | Pattern          | Assessment           |
+------+------------+------------------+----------------------+
| 🔴   | [file:ln]  | [pattern]        | [assessment]         |
| 🟠   | [file:ln]  | [pattern]        | [assessment]         |
+------+------------+------------------+----------------------+
Aggregate: 🔴[N] 🟠[N] 🟡[N] 🟢[N]

PHILOSOPHY ALIGNMENT
+------------------+-------+----------------------------------+
| Dimension        | Score | Reasoning                        |
+------------------+-------+----------------------------------+
| Core Mission     | [1-5] | [reason]                         |
| Scope            | [1-5] | [reason]                         |
| Pattern          | [1-5] | [reason]                         |
| User Impact      | [1-5] | [reason]                         |
+------------------+-------+----------------------------------+
| OVERALL          | [avg] | [High/Medium/Low]                |
+------------------+-------+----------------------------------+

FEASIBILITY
+------------------+--------+--------------------------------+
| Factor           | Rating | Notes                          |
+------------------+--------+--------------------------------+
| Complexity       | [L/M/H]| [explanation]                  |
| Breaking Changes | [N/Mi/Mj]| [explanation]                |
| Maintenance      | [L/M/H]| [explanation]                  |
+------------------+--------+--------------------------------+
| OVERALL          | [H/M/L]| [summary]                      |
+------------------+--------+--------------------------------+

DECISION
+------------------+--------------------------------------------+
| Verdict          | [ACCEPT/ADAPT/DEFER/REDIRECT/DECLINE]      |
| Confidence       | [High/Medium/Low]                          |
| Rationale        | [2-3 sentences]                            |
+------------------+--------------------------------------------+

STRATEGIC INSIGHTS (Think 10 from 1)
- Documentation Gap: [finding]
- API Gap: [finding]
- Preventive Actions: [suggestions]

RESPONSE DRAFT
────────────────────────────────────────────────────────────────
[response to post on GitHub]
────────────────────────────────────────────────────────────────

NEXT STEPS
- [ ] [action 1]
- [ ] [action 2]
================================================================
```

## Quick Mode (--quick)

Execute phases 1-4 only, focus on decision:

```
QUICK TRIAGE: [title]
Decision: [ACCEPT/ADAPT/DEFER/REDIRECT/DECLINE]
Rationale: [1-2 sentences]
Response: [brief response]
```

## Examples

```bash
/iyu:issue https://github.com/iyulab/mylib/issues/42
/iyu:issue https://github.com/iyulab/mylib/issues/42 --quick
/iyu:issue ./docs/feature-request.md --save
/iyu:issue "Add support for Redis caching" --no-research
```
