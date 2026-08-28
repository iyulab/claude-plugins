# Decision lenses — the five axes an option is judged on

**This file is the single definition** of the lenses used to compare options. Two consumers read it
for two different purposes, and the lenses are the same in both:

- `run-cycle` rule 2.5 — to **self-decide** a reversible (L1) choice and proceed without asking.
- `resume` step 4 — to **brief** an irreversible or human-only (L2) choice that `handoff` flagged: the
  options, how each reads across the lenses, and which one is recommended.

Same vocabulary, opposite outcomes. Which purpose applies is decided *before* this file is opened,
by reversibility — not by how interesting the decision is.

---

## The five lenses

They are **co-equal**. This is a list, not a priority order: an option is judged by how it reads
across all five *together*, not by winning the first one.

| Lens | The question it asks |
|---|---|
| **근본 / structural fit** | Does this address the root cause, or the surface symptom? Where does it leave the structure — cleaner, or with a new seam to maintain? |
| **정석 / balanced-canonical** | Is this the textbook way to do it in this context, or a clever shortcut that will need explaining forever? |
| **표준 / convention** | What do the ecosystem, the language, and *this repo's own existing code* already do? A local convention outranks a global one. |
| **세련 / elegant-minimal** | What is the smallest thing that fully solves it? Does it remove more than it adds? |
| **철학 / project-philosophy alignment** | Does it fit the project's stated identity, scope, and patterns? Scored by the four dimensions in [philosophy-alignment-guide.md](../mindset/references/philosophy-alignment-guide.md) — core mission fit, scope alignment, pattern consistency, user-base impact. |

**Technical debt is not a sixth lens** — it shows up inside 근본 and 세련. An option that solves it
now and costs later reads well on one and badly on the other; say that, rather than adding an axis.

---

## When a recommendation can't be formed

Sometimes the five lenses don't produce a clean pick. The right response depends on *why* — these
are three different failures, not one, and treating them the same either forces a pick nobody can
defend or stalls on research nobody asked for.

| Cause | What it looks like | What to do instead of guessing |
|---|---|---|
| **(a) Value conflict** | Every candidate is clean on some lenses and indefensible on others, and no reframing dissolves it — an *irreducible* trade-off, not an ordinary disagreement. | Say so explicitly: "no option is defensible across the lenses; the conflict is X vs Y." In `run-cycle`, this is the one exception to *in dubio, pro autonomy* — treat it as L2. In `resume`, name the conflict in the recommendation slot rather than manufacturing a preference. |
| **(b) Missing external information** | 정석/표준 have nothing to read against — an ecosystem convention, a domain fact, or a property of a dependency isn't known and isn't in this repo. | Name precisely what's unknown and what would settle it (a search query, a doc to check, a spike). Offer it as a next step the human can direct — `resume`/`run-cycle` point at the gap, they don't fill it themselves (neither carries `WebSearch`, and filling it would cross `resume` rule 9's known-work-only boundary). A skill whose own scope already covers research (e.g. `backlog-discover`) is a name to offer, not an instruction to invoke. |
| **(c) Missing internal anchor** | 표준/철학 have nothing *of this project's own* to read against — no existing convention in the repo for this kind of decision, no stated identity/scope in CLAUDE.md that bears on it. Common in early 0.X.X projects that haven't yet accumulated precedent. | Say so before attempting a recommendation: "이 판단을 위한 기준이 아직 없다." Treat establishing that criterion — a convention, a stated project stance — as the thing to settle *first*, and surface it as what's actually being asked, rather than picking an option that would silently become the precedent by default. |

A lens disagreement is ordinary and expected; most decisions have one. (a) is only irreducible when
the trade-off cannot be stated as "give up A to get B" and lived with. (b) and (c) are not
disagreements at all — the lenses have nothing to compare yet, and forcing a pick manufactures a
precedent nobody actually decided on.
