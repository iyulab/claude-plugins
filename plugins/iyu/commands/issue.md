---
description: Triage external issues with critical evaluation against project philosophy and scope
argument-hint: <issue-url | file-path | "issue text"> [--quick] [--save] [--no-research]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
---

# Issue Triage

Analyze external issues and make decisions aligned with project philosophy. Triage only — do not implement. If implementation is needed, hand off to `/iyu:run`.

## Input

- **URL**: `https://github.com/user/repo/issues/123`
- **File**: `./docs/feature-request.md`
- **Text**: `"Add support for Redis caching"`

**Flags**: `--quick` (decision only, skip deep analysis) | `--save` (save to `./claudedocs/triage-[date]-[title].md`) | `--no-research` (skip web research)

## Process

### Phase 0: Actionability Check (GitHub/GitLab URLs only)

Fetch issue with ALL comments:

```
gh issue view <number> --repo <owner/repo> --comments --json title,body,state,comments,labels,author
```

**SKIP if**: Already resolved, duplicate, spam, or low-quality AI-generated content (no reproduction steps, generic template language, no project-specific context).

**PROCEED if**: Unresolved, still reported, or requesting reopen.

### Phase 1: Deep Understanding

Don't take the request at face value:

- **Surface Request**: What they're literally asking for
- **Underlying Need**: The real problem they're solving
- **Root Cause**: Why did this request emerge? What project gap?
- **Prevention**: What would have made this request unnecessary?

### Phase 1.5-1.8: Bug Deep Dive (bugs only)

If classified as a bug:
- **Root Cause Analysis**: Symptom ≠ cause. Build hypothesis tree, trace cause chain: `[Action] → [Component] → [ROOT CAUSE] → [Symptom]`
- **Similar Pattern Detection**: After identifying root cause, search for the same pattern elsewhere. Classify by risk (Critical/High/Medium/Low).
- **Solution Research**: For complex bugs (5+ files, unfamiliar territory, security/performance), use WebSearch for latest approaches.

### Phase 2: Philosophy Alignment

Read CLAUDE.md / README.md. Evaluate:

| Dimension | Question |
|-----------|----------|
| Core Mission Fit | Serves project's core purpose? |
| Scope Alignment | Library vs application responsibility? |
| Pattern Consistency | Consistent with existing architecture? |
| User Base Impact | Benefits majority or niche? |

**Overall**: High (4-5 avg) / Medium (3-3.9) / Low (1-2.9)

### Phase 3: Feasibility Assessment

Evaluate: Technical Complexity, Breaking Changes, Maintenance Burden, Dependencies.

### Phase 4: Decision

|  | Philosophy HIGH | Philosophy LOW |
|--|-----------------|----------------|
| Feasibility HIGH | ACCEPT | REDIRECT |
| Feasibility MED | ADAPT | DEFER/REDIRECT |
| Feasibility LOW | DEFER | DECLINE |

- **ACCEPT**: Implement as requested
- **ADAPT**: Good idea, implement differently
- **DEFER**: Valuable but not now, provide roadmap
- **REDIRECT**: Out of scope, provide alternative path
- **DECLINE**: Fundamentally misaligned, explain respectfully

### Phase 5: "Think 10 from 1" (skip if --quick)

The most important phase. Extract latent insights beyond the immediate request:

- **Documentation gap**: What wasn't clearly documented?
- **API gap**: Does current API make this use case unnecessarily difficult?
- **Example gap**: What example would have answered this?
- **Architecture signal**: Does this reveal a structural weakness?
- **Preventive actions**: FAQ, error messages, documentation to prevent recurrence

### Phase 6: Response Draft

Structure by decision type and contributor context. Draft a response suitable for posting on GitHub.

### Quick Mode (--quick)

Phases 1-4 only. One-paragraph decision with rationale.
