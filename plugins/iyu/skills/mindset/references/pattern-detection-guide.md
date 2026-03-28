# Pattern Detection Guide

Find similar patterns in a codebase when resolving bugs to identify and fix latent defects proactively.

## Philosophy

**"Fix N, Prevent M"** - When you find one bug (N), use it as a signal to find all similar patterns (M) that may have the same latent defect. This transforms reactive bug fixing into proactive quality improvement.

## Process Overview

```
Root Cause Found → Extract Pattern → Search Codebase → Assess Risk → Plan Fix
      ↓                   ↓               ↓              ↓           ↓
 "Null pointer      "obj.prop         15 matches     2 critical   Fix all
  in user.js:45"   without check"     found           5 high      critical+high"
```

## Pattern Types

| Type | Description |
|------|-------------|
| Missing null check | Property access without null guard |
| Incorrect error handling | Empty catch, swallowed exceptions |
| Race condition | Shared state without synchronization |
| API misuse | Wrong method signature or parameters |
| Resource leak | Open without close |

## Risk Assessment

For each found pattern, assess the risk level:

| Risk | Criteria | Action |
|------|----------|--------|
| 🔴 Critical | Same exact pattern, likely same bug | Fix immediately with this PR |
| 🟠 High | Very similar pattern, >70% chance of defect | Include in this fix |
| 🟡 Medium | Related pattern, should be reviewed | Schedule follow-up review |
| 🟢 Low | Loosely related, might be fine | Add to monitoring/tech debt |

**Assessment Questions:**
- Does this pattern have the SAME root cause vulnerability?
- Is it in a code path that gets executed similarly?
- Would the same fix apply here?
- What's the blast radius if this fails?

## Output Format

```
DETECTED PATTERNS
================

Root Cause Pattern: [Description of the bug pattern]
Search Scope: [Directories/files analyzed]
Total Matches: [N patterns found]

+------+------------------+----------------------+---------------------------+
| Risk | Location         | Pattern Match        | Assessment                |
+------+------------------+----------------------+---------------------------+
| 🔴   | src/api/user.js:45 | Missing null check   | Same bug, user data      |
| 🟠   | src/api/order.js:78| Similar null access  | Different entity, same risk|
| 🟡   | src/util/format.js:23| Related null pattern| Utility, less critical   |
| 🟢   | tests/mock.js:12  | Test file pattern    | Not production code      |
+------+------------------+----------------------+---------------------------+

AGGREGATE RISK
--------------
🔴 Critical: 2 patterns - IMMEDIATE ACTION REQUIRED
🟠 High: 5 patterns - Address in this fix
🟡 Medium: 8 patterns - Schedule review
🟢 Low: 3 patterns - Monitor

RECOMMENDATION
--------------
[Fix N+M / Comprehensive refactor / Fix N only with follow-up]

PREVENTIVE FIXES
----------------
For Critical/High patterns:
1. [file:line] - [Specific fix description]
2. [file:line] - [Specific fix description]
```

## Best Practices

1. **Start narrow, expand gradually**: Begin with the immediate directory, then module, then project
2. **Use multiple search strategies**: Syntactic alone misses semantic similarities
3. **Don't over-fix**: Low-risk patterns may be intentional or have different context
4. **Consider test coverage**: Patterns in well-tested code are lower risk
