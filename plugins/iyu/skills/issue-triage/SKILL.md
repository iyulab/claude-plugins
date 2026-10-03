---
name: issue-triage
description: Supplies decision matrices for accepting, rejecting, or redirecting external issues and PRs. Use when discussing whether to accept, reject, or redirect an external issue or PR. Triggers on "triage this issue", "evaluate this feature request", "should I accept/merge this", "is this in scope", "review this PR/contribution", "how should I respond to this issue".
---

# Issue & PR Triage Framework

Evaluate external Issues/PRs against project philosophy. The goal is not just to decide on the request — it's to **discover latent work** the request reveals.

## Core Philosophy

- **"Every issue is an opportunity"** — Even declines improve documentation or reveal API gaps.
- **"Think 10 from 1"** — One request implies ten insights. What's missing? What should change?
- **"Every contribution is a gift"** — Honor the contributor's time.
- **"Mentor, not gatekeeper"** — Help them succeed.

## Philosophy Alignment

| Dimension | Question |
|-----------|----------|
| Core Mission Fit | Serves project's core purpose? |
| Scope Alignment | Library vs application responsibility? |
| Pattern Consistency | Consistent with existing architecture? |
| User Base Impact | How widely is the root cause shared? Request counts are evidence, not the score |

**Overall**: High (4-5 avg) / Medium (3-3.9) / Low (1-2.9). A breaking change is not scored: pre-1.0
it is an ordinary minor-release tool; at 1.0+ a published-contract change is reported as a version
decision.

## Issue Decision Matrix

```
                 | Philosophy HIGH | Philosophy LOW  |
-----------------|-----------------|-----------------|
Feasibility HIGH | ACCEPT          | REDIRECT        |
Feasibility MED  | ADAPT           | DEFER/REDIRECT  |
Feasibility LOW  | DEFER           | DECLINE         |
```

**Feasibility means real blockers, not effort.** HIGH: nothing blocks it · MED: a slice or adapted
form proceeds now, the rest waits on a named blocker · LOW: a real prerequisite blocks it — an open
design decision, an unavailable external dependency, earlier work on the same surface. Large aligned
work is staged, not deferred; a DEFER names its blocker as the resume condition, never a demand
threshold.

## PR Decision Matrix

```
                 | Quality HIGH         | Quality LOW          |
-----------------|----------------------|----------------------|
Philosophy HIGH  | APPROVE              | MERGE_WITH_FIXES     |
Philosophy MED   | APPROVE_WITH_NOTES   | REQUEST_CHANGES      |
Philosophy LOW   | REDIRECT             | DECLINE              |
```

## Verdicts

**Issues**: ACCEPT / ADAPT / DEFER / REDIRECT / DECLINE
**PRs**: APPROVE / APPROVE_WITH_NOTES / MERGE_WITH_FIXES / REQUEST_CHANGES / REDIRECT / DECLINE

## Severity (PR Review)

| 🔴 Blocker | 🟠 Major | 🟡 Minor | ✨ Praise (required) |

## Bug Risk (Issue Triage)

| 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low |

## Working the verdict

The matrices above give the decision. These carry it out — load one when you reach that step,
not before.

| Step | Reference |
|---|---|
| Drafting the reply to a contributor | [response-templates.md](${CLAUDE_SKILL_DIR}/references/response-templates.md) — one template per verdict |
| Wording review feedback | [tone-rules.md](${CLAUDE_SKILL_DIR}/references/tone-rules.md) — direct, few emojis, no AI-assistant register |
| A bug that needs investigation before a verdict | [research-methodology.md](${CLAUDE_SKILL_DIR}/references/research-methodology.md) |
| Finding the same bug pattern elsewhere | [pattern-detection-guide.md](${CLAUDE_SKILL_DIR}/../mindset/references/pattern-detection-guide.md) |
| Scoring the four philosophy dimensions | [philosophy-alignment-guide.md](${CLAUDE_SKILL_DIR}/../mindset/references/philosophy-alignment-guide.md) |

**"Think 10 from 1" before closing.** Whatever the verdict, ask what the request reveals: a
documentation gap, an API that makes the use case harder than it should be, a missing example, a
structural weakness. The verdict answers the request; this answers why the request happened.
