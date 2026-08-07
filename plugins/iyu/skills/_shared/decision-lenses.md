# Decision lenses — the five axes an option is judged on

**This file is the single definition** of the lenses used to compare options. Two consumers read it
for two different purposes, and the lenses are the same in both:

- `run-cycle` rule 2.5 — to **self-decide** a reversible (L1) choice and proceed without asking.
- `handoff` step 6 — to **brief** an irreversible or human-only (L2) choice: the options, how each
  reads across the lenses, and which one is recommended.

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

## Irreducible conflict is a signal, not a tie to break

When no option is defensible across the five — every candidate is clean on some lenses and
indefensible on others, and no reframing dissolves it — that conflict is **itself** an escalation
signal. Do not force a pick to keep moving.

- In `run-cycle`, this is the one exception to *in dubio, pro autonomy*: treat it as L2.
- In `handoff`, say so explicitly in the recommendation slot — "no option is defensible across the
  lenses; the conflict is X vs Y" — rather than manufacturing a preference.

A lens disagreement is ordinary and expected; most decisions have one. It is only *irreducible* when
the trade-off cannot be stated as "give up A to get B" and lived with.
