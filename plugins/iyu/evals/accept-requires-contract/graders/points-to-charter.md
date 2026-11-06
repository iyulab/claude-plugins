---
type: llm
weight: 1
---

PASS when the response (a) says nothing was evaluated because the repository has no stage contract or no open stage, and (b) names `/iyu:charter` as the next step. Describing what it checked is fine.

FAIL only if the response reports a verdict, a score, or a pass/fail result for any scenario.
