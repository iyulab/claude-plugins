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

**Neither is "how little it changes."** Scope size, diff size, and migration cost are not inputs to
any of the five. An option preferred *because* it touches less is not scoring well on 세련 — 세련
asks what fully solves the problem with the least complexity **left behind**, not what edits the
fewest lines. An option that wins only on smallness is a 근본 **penalty**: that is the shape
technical debt arrives in. In a 0.X.X project it is doubly wrong — there is no compatibility
contract to protect yet, and the same change only costs more the longer it waits.

---

## When a recommendation can't be formed

Sometimes the five lenses don't produce a clean pick. The right response depends on *why* — and two
of the three causes below are **not reasons to withhold a recommendation**. They are reasons to go
and get what is missing, then recommend. Only (a) is a genuine no-recommendation outcome, and it is
reachable only once (b) and (c) have been ruled out.

| Cause | What it looks like | What to do |
|---|---|---|
| **(a) Value conflict** — *the only no-recommendation outcome* | Every candidate is clean on some lenses and indefensible on others, and no reframing dissolves it — an *irreducible* trade-off, not an ordinary disagreement. | Say so explicitly: "no option is defensible across the lenses; the conflict is X vs Y." In `run-cycle`, this is the one exception to *in dubio, pro autonomy* — treat it as L2. In `resume`, name the conflict in the recommendation slot rather than manufacturing a preference. **Only after (b) and (c) are ruled out** — an unresearched decision is not a value conflict, it is an unresearched decision. |
| **(b) Missing external information** — *research, then recommend* | 정석/표준 have nothing to read against — an ecosystem convention, a domain fact, or a property of a dependency isn't known and isn't in this repo. | **Go and settle it.** Name the unknown precisely, then close it: `WebSearch`/`WebFetch` for an ecosystem convention or a library's actual behavior, the file/test/dependent itself for anything in-repo. **Bounded the way `run-cycle` bounds its self-unblock check (~5 min per decision)** and aimed at the *one* unknown that separates the leading options — not a survey. Then recommend on what you found. Report a gap only when the bounded search came back empty, and say what you searched, not just what you still don't know. |
| **(c) Missing internal anchor** — *derive the anchor, recommend it* | 표준/철학 have nothing *of this project's own* to read against — no existing convention for this kind of decision, no stated identity/scope in CLAUDE.md that bears on it. Common in early 0.X.X projects that haven't yet accumulated precedent. | **Propose the anchor.** Read what the project does have — the four dimensions in [philosophy-alignment-guide.md](../mindset/references/philosophy-alignment-guide.md), README, the nearest analogous code — derive a candidate criterion from it, and recommend *that together with* the option it implies: "이 판단의 기준을 X로 세울 것을 권장하고, 그 기준에서는 Y가 옳다." Naming the absence and stopping is not an answer: in a 0.X.X project "선례가 없으니 보류" is the deferral antipattern, and the option taken by default becomes the precedent anyway — just undecided. |

A lens disagreement is ordinary and expected; most decisions have one. (a) is only irreducible when
the trade-off cannot be stated as "give up A to get B" and lived with. **(b) and (c) are not
disagreements — and they are not verdicts either.** They say the lenses have nothing to compare
*yet*. The work they ask for is small and bounded; skipping it and reporting "cannot recommend"
hands the investigation back to the person with the least context on it, which is the one thing
[decision-briefing.md](./decision-briefing.md) exists to prevent.

**The boundary this does not cross.** Researching to ground a recommendation on a decision that is
*already on the table* is judgment over known work. Scoping work nobody has identified yet is not —
that stays `/iyu:backlog-discover`'s job (`resume` rule 9), a name to offer rather than a skill to
invoke. The line is what the research is aimed at, not whether research happens at all.
