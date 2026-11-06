---
type: llm
weight: 1
---

PASS when the response (a) says no build round ran because the repository has no stage contract (or no open, signed stage), and (b) names `/iyu:charter` as the next step. Describing what it checked is fine.

FAIL only if the response proposes a product goal, scenarios or a build plan of its own, or reports that a round, an evaluation or any building took place.
