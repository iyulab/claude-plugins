# Backlog Discovery — design rationale

Why `/iyu:backlog-discover` has the shape it does. Read this when changing the skill's structure;
the skill body itself carries only the summary.

## Why this shape

The two development skills play different roles on purpose. `run-cycle` acts as a **capable
employee**: given a scope, it executes, verifies, and reports back. This skill acts as the
**capable owner-manager** — the one who cares about the project as something they are
answerable for. A manager does two things an executor does not: they decide *what deserves
attention next*, and they **keep what already exists in good order**. The second half is easy
to lose: a discovery skill that only looks forward will happily propose new capabilities
while the dependencies rot, the quickstart breaks, and the CI config drifts out of sync with
reality. Hence `stewardship-check` (관리 점검) as a short-cadence lane and the first rung of
the deepen ladder.

Concretely, a generic "brainstorm new features" prompt either runs the same handful of ideas
every time (stale) or invents ungrounded scope (mindset violation — "no invention", no
autonomous new product direction). This skill instead:

1. Draws from a **fixed, named menu** (the playbook) so activities are legible and
   repeatable, not reinvented per run.
2. **Tracks cadence per activity** in a persistent state file, so a quarterly activity
   doesn't re-run every invocation and a stale half-yearly one doesn't get forgotten.
3. **Self-diagnoses** which emergent (deliberately provocative) session to run from
   observable symptoms in the project's own history — not a random pick.
4. **Never auto-merges.** Every discovered item — however well-argued — lands in a
   proposal document. A human decides what enters `ROADMAP.md`. This is a stricter bar
   than `run-cycle`'s in-cycle "autonomous-eligible" fast path, because this skill's
   discoveries are external and speculative (web trends, competitor features, deliberately
   engineered provocations) rather than a narrow "what does the diff I just wrote imply."
5. **Inspects, not only imagines.** `stewardship-check` actively runs the project's own
   dependency, config, doc, and repo-hygiene checks each sprint. Forward-looking research and
   backward-looking upkeep are both the owner's job, and the upkeep half is the one that
   silently decays if nobody schedules it.
6. **Judges, not just collects.** Handing over 40 tagged findings is not a finished job —
   it moves the whole burden of "what matters, in what order, and why" onto the reader.
   P6 closes that gap: a state-of-the-product **diagnosis**, an evidence-grounded
   **importance ranking**, and a dependency-ordered **staging** toward the vision. Judgment
   is still a proposal, never a decision — ranking an item is not merging it (rule 1).

## Relationship to `run-cycle`

The two skills are deliberately independent. `run-cycle` only ever *consumes* `ROADMAP.md`; this
skill only ever *proposes additions* to it and never writes it. Neither invokes the other — when a
run terminates on `FRONTIER-EXHAUSTED:` with budget left, its report *recommends* this skill to the
human, which is a pointer, not a call.
