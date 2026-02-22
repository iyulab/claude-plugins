---
name: Issue & PR Triage
description: Use when discussing whether to accept, reject, or redirect an external issue or PR. Triggers on "triage this issue", "evaluate this feature request", "should I accept/merge this", "is this in scope", "review this PR/contribution", "how should I respond to this issue".
---

# Issue & PR Triage Framework

A framework for evaluating external Issues/PRs against project philosophy.

## Core Philosophy

**"Every issue is an opportunity"** - Even declines can improve documentation or reveal API gaps.

**"Think 10 from 1"** - Extract ten insights from one request.

**"Every contribution is a gift"** - Honor the contributor's time investment.

**"Mentor, not gatekeeper"** - Help them succeed.

## Issue Decision Matrix

```
                 | Philosophy HIGH | Philosophy LOW  |
-----------------|-----------------|-----------------|
Feasibility HIGH | ACCEPT          | REDIRECT        |
Feasibility MED  | ADAPT           | DEFER/REDIRECT  |
Feasibility LOW  | DEFER           | DECLINE         |
```

## PR Decision Matrix

```
                 | Quality HIGH         | Quality LOW          |
-----------------|----------------------|----------------------|
Philosophy HIGH  | APPROVE              | MERGE_WITH_FIXES     |
Philosophy MED   | APPROVE_WITH_NOTES   | REQUEST_CHANGES      |
Philosophy LOW   | REDIRECT             | DECLINE              |
```

## Quick Reference

### Issue Verdicts
- **ACCEPT**: Implement as requested
- **ADAPT**: Implement differently
- **DEFER**: Not now, provide roadmap
- **REDIRECT**: Out of scope, provide alternatives
- **DECLINE**: Philosophy mismatch, explain respectfully

### PR Verdicts
- **APPROVE**: Ready to merge
- **MERGE_WITH_FIXES**: Merge, maintainer fixes
- **REQUEST_CHANGES**: Specific fixes needed
- **REDIRECT**: Different approach needed
- **DECLINE**: Philosophy mismatch

### Severity Levels (PR)
| 🔴 Blocker | 🟠 Major | 🟡 Minor | 🟢 Nitpick | ✨ Praise |

### Bug Risk Levels
| 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low |

## Commands

For full workflow:

```bash
# Issue triage
/iyu:issue <url | file | "text">
/iyu:issue <input> --quick

# PR review
/iyu:pr <pr-url | #number>
/iyu:pr <input> --quick
/iyu:pr <input> --security-focus
```

## Integration

This framework **leverages** Claude's capabilities:
- Code review: Claude performs, iyu provides severity classification framework
- Security review: Claude detects, iyu applies "security issues are always Blocker" policy
- Communication: Claude writes, iyu provides response structure per Decision
