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

## Why P2.5 loads prior proposals

P9 merge is manual, so most proposed items are *never adopted* — they are neither in `ROADMAP.md`
nor retired. Without a dedupe basis, every run rediscovers the same gaps from scratch and the
proposal pile grows without any of the documents referring to each other. The skill already solved
that problem once, for technology candidates (`appropriate-tech`'s recorded `기각`/`보류` verdicts,
rule 9); P2.5 + P4 extend the same discipline to ordinary items.

## Why the dry-backlog ladder became a full sweep, not a rewrite of the cost concern

The original ladder stopped at the first lane producing material, reasoning that deeper lanes cost
more and recoup slower. That reasoning is still correct **in steady state** — most invocations are
cadence-gated and should not touch all twenty activities. It stopped being correct specifically at
the dry-backlog trigger, because that trigger *is* the signal that the shallow, cheap lanes
(dogfooding's always-floor, whatever cadence happens to be due) already came back thin — continuing
to optimize for "cheapest lane that satisfies" at that exact point converts the deepen-signal into a
minimum-effort exit. The fix is a mode split, not a repeal: dry-backlog forces the full ①–④ +
`vision-gap` sweep; every other invocation still obeys cadence and the original cost reasoning holds
unchanged. This is why the fix lives in the ladder's *trigger condition*, not in its per-lane cost
ordering — the ordering (cheapest first) is still the right order to run the four lanes *in*, once
running all of them is the decision.

## Why `STRANDS.md` is a new artifact instead of mined from `git log` / cycle-logs each run

`backlog-discover`'s existing symptom heuristics already mine `git log` and cycle-logs for some
signals (e.g. "장기 방향이 흐릿하다"'s repeated-phase-name check). Detecting a stuck-in-flight or
quietly-abandoned strand needs the same kind of signal, but cheaply and reliably across many
sessions — re-deriving "which strand did each of the last N cycles serve, and when did the active
one change" from raw git/cycle-log text each run gets more expensive and more fragile as project
history grows, and duplicates work `run-cycle` already does at STEP 5 (it already knows which
`ROADMAP.md` phase, or which ad-hoc reason, this cycle served). Writing a two-line-per-transition
ledger once, at the point that already has the answer, is the same "one skill writes, another reads"
precedent `telemetry-az` already established for `<root>/telemetry/`.

## Why `allowed-tools` includes unscoped Bash

Matching `run-cycle`: activities span arbitrary project-specific commands (outdated/audit tooling,
`gh issue list`, `git log` mining, registry lookups) across unknown project types, and scoping would
require per-project edits. This skill is read-mostly, so the blast radius is smaller than
`run-cycle`'s — the justification is the same.

## Relationship to `run-cycle`

The two skills are deliberately independent. `run-cycle` only ever *consumes* `ROADMAP.md`; this
skill only ever *proposes additions* to it and never writes it. Neither invokes the other — when a
run terminates on `FRONTIER-EXHAUSTED:` with budget left, its report *recommends* this skill to the
human, which is a pointer, not a call.
