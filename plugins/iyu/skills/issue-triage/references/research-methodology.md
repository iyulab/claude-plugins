# Solution Research Methodology

When to research solutions and how to present findings in iyu format.

## When to Research

Auto-trigger research when ANY of these conditions are met:

| Trigger | Rationale |
|---------|-----------|
| **Technical Complexity** | Affects 5+ files OR requires architectural changes |
| **Unfamiliar Territory** | <3 similar patterns in codebase (new problem space) |
| **Explicit Request** | Issue mentions "best practice", "latest", "modern approach" |
| **External Dependency** | Involves third-party library/API behavior |
| **Security Critical** | Security vulnerability or sensitive data handling |
| **Performance Critical** | Performance-critical code path |

Skip research when:
- `--no-research` flag is set
- `--quick` flag is set
- Issue is straightforward with clear solution in codebase

## Output Format

Present research findings in this structure:

```
SOLUTION RESEARCH SUMMARY
=========================

RESEARCH CONTEXT
----------------
Trigger: [Why research was initiated]
Query: [Search query used]
Sources Analyzed: [N sources]

FINDINGS
--------

Best Practice (Primary Recommendation):
+----------------------+----------------------------------------------+
| Approach             | [Specific recommended approach]              |
| Source               | [URL - authoritative source]                 |
| Applicability        | [High/Medium/Low] - [why this fits]          |
| Key Insight          | [Most important takeaway]                    |
+----------------------+----------------------------------------------+

Alternative Approaches:
+----------------------+----------------------------------------------+
| Alternative 1        | [Different valid approach]                   |
| Trade-offs           | [Pros vs Cons compared to primary]           |
+----------------------+----------------------------------------------+

SECURITY CONSIDERATIONS (if applicable)
---------------------------------------
- [Security finding from OWASP/security sources]

FINAL RECOMMENDATION
--------------------
+----------------------+----------------------------------------------+
| Recommended Approach | [Specific approach to implement]             |
| Rationale            | [Why this is best for THIS context]          |
| Key References       | [Most useful URLs for implementation]        |
+----------------------+----------------------------------------------+
```

## Integration with Bug Resolution

Research integrates into the bug resolution workflow:

```
Bug Identified
     ↓
Root Cause Found
     ↓
Pattern Detection (find similar bugs)
     ↓
Complexity Check ──→ Low Complexity → Skip Research
     ↓ High
SOLUTION RESEARCH
     ↓
Synthesize Findings
     ↓
Apply to Fix (N + M patterns)
```

## Notes

- Time-box research: 10-15 minutes max
- Prefer official documentation and recent sources (< 2 years)
- Always verify code examples work in your context
