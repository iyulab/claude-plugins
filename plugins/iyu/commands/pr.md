---
description: Review pull requests with project philosophy alignment
argument-hint: <pr-url | pr-number> [--quick] [--save] [--security-focus]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
---

# PR Review

Review PRs aligned with project philosophy. Focus on what Claude wouldn't catch without project context.

## Input

- **URL**: `https://github.com/user/repo/pull/123`
- **PR number**: `#123` (in repo context)

**Flags**: `--quick` (blockers only) | `--save` (save to `./claudedocs/pr-review-[date]-[number].md`) | `--security-focus` (security-focused review)

## Process

### 1. Status Check

```
gh pr view <number> --json state,mergeable,reviewDecision,statusCheckRollup
```

- `merged` / `closed` → SKIP
- `draft` → Brief review
- CI failing / conflicts → WAIT

### 2. Fetch & Understand

```
gh pr view <number> --json title,body,author,files,additions,deletions,commits,comments,reviews
```

Identify: What problem does it solve? What approach? Contributor type (First-time / Returning / Core).

### 3. Review

Classify findings by severity:

| Level | Meaning |
|-------|---------|
| 🔴 Blocker | Must fix — bugs, security, critical logic errors |
| 🟠 Major | Should fix — performance, missing tests, pattern violations |
| 🟡 Minor | Nice to have — naming, docs, minor improvements |
| ✨ Praise | **Must include at least 1** — acknowledge good work |

Security issues are always 🔴 Blocker.

### 4. Philosophy Alignment

The key differentiator. Read CLAUDE.md / README.md. Evaluate:

| Dimension | Question |
|-----------|----------|
| Core Mission Fit | Serves project's core purpose? |
| Scope Alignment | Library vs application responsibility? |
| Pattern Consistency | Consistent with existing architecture? |
| User Base Impact | Benefits majority or niche? |

**Overall**: High (4-5 avg) / Medium (3-3.9) / Low (1-2.9)

**Latent discovery**: Does this PR reveal gaps? Missing tests elsewhere? API design issues? Documentation needs? Record these as insights, not just the PR itself.

### 5. Decision

|  | Quality HIGH | Quality LOW |
|--|--------------|-------------|
| Philosophy HIGH | APPROVE | MERGE_WITH_FIXES |
| Philosophy MED | APPROVE_WITH_NOTES | REQUEST_CHANGES |
| Philosophy LOW | REDIRECT | DECLINE |

- **APPROVE**: Ready to merge
- **APPROVE_WITH_NOTES**: Approve + non-blocking suggestions
- **MERGE_WITH_FIXES**: Approve, maintainer fixes minor issues
- **REQUEST_CHANGES**: Good direction, needs specific fixes
- **REDIRECT**: Different approach needed
- **DECLINE**: Philosophy mismatch, explain respectfully

### 6. Response Draft

Adjust tone by contributor type:
- **First-time**: Welcome + detailed explanation + encouragement
- **Returning**: Thanks + focused feedback
- **Core**: Peer-level discussion

**Tone rules:**
- No excessive emojis. Severity markers (Blocker/Major/Minor) are enough without decorating every sentence.
- Keep it concise — state the issue, suggest the fix. Don't over-explain obvious things.
- Write like a human reviewer, not an AI assistant. Avoid phrases like "Great work!", "I appreciate your effort!", "Thank you so much for this wonderful contribution!" — a simple "Thanks" or "Looks good" is fine.
- Be direct. "This needs a null check" beats "It might be beneficial to consider adding a null check here."

### Quick Mode (--quick)

🔴 Blockers only → APPROVE or REQUEST_CHANGES.
