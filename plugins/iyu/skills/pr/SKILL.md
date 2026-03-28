---
name: pr
description: Review pull requests with project philosophy alignment
argument-hint: <pr-url | pr-number> [--quick] [--save] [--security-focus]
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep, WebFetch, WebSearch, TodoWrite, Bash(gh *)
---

# PR Review

Review PRs aligned with project philosophy. Focus on what Claude wouldn't catch without project context.

## Input

- **URL**: `https://github.com/user/repo/pull/123`
- **PR number**: `#123` (in repo context)

**Flags**: `--quick` (blockers only) | `--save` (save to `./claudedocs/pr-review-[date]-[number].md`) | `--security-focus` (security-focused review)

## PR Data

- Status: !`gh pr view $0 --json state,mergeable,reviewDecision,statusCheckRollup`
- Details: !`gh pr view $0 --json title,body,author,files,additions,deletions,commits,comments,reviews`
- Diff: !`gh pr diff $0`

## Process

### 1. Status Check

From the pre-loaded status data:
- `merged` / `closed` → SKIP
- `draft` → Brief review
- CI failing / conflicts → WAIT

### 2. Understand

From the pre-loaded details:
Identify: What problem does it solve? What approach? Contributor type (First-time / Returning / Core).

### 3. Review

Classify findings by severity:

| Level | Meaning |
|-------|---------|
| Blocker | Must fix — bugs, security, critical logic errors |
| Major | Should fix — performance, missing tests, pattern violations |
| Minor | Nice to have — naming, docs, minor improvements |
| Praise | **Must include at least 1** — acknowledge good work |

Security issues are always Blocker.

### 4. Philosophy Alignment

Read CLAUDE.md / README.md. Evaluate using the [philosophy-alignment-guide.md](../mindset/references/philosophy-alignment-guide.md):

| Dimension | Question |
|-----------|----------|
| Core Mission Fit | Serves project's core purpose? |
| Scope Alignment | Library vs application responsibility? |
| Pattern Consistency | Consistent with existing architecture? |
| User Base Impact | Benefits majority or niche? |

**Overall**: High (4-5 avg) / Medium (3-3.9) / Low (1-2.9)

**Latent discovery**: Does this PR reveal gaps? Missing tests elsewhere? API design issues? Documentation needs?

### 5. Decision

|  | Quality HIGH | Quality LOW |
|--|--------------|-------------|
| Philosophy HIGH | APPROVE | MERGE_WITH_FIXES |
| Philosophy MED | APPROVE_WITH_NOTES | REQUEST_CHANGES |
| Philosophy LOW | REDIRECT | DECLINE |

For decision examples, see [decision-examples.md](../mindset/references/decision-examples.md).

### 6. Response Draft

Adjust tone by contributor type:
- **First-time**: Welcome + detailed explanation + encouragement
- **Returning**: Thanks + focused feedback
- **Core**: Peer-level discussion

For tone rules, see [tone-rules.md](references/tone-rules.md).

### Quick Mode (--quick)

Blockers only → APPROVE or REQUEST_CHANGES.
