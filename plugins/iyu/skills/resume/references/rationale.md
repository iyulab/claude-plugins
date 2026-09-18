# resume — why it is shaped this way

Explanation for `resume/SKILL.md`. The skill body holds the instructions; this file holds the reasons,
so the body stays under the re-attach cut that auto-compaction applies to every skill.

## Why this exists separately from `/iyu:handoff`

`/iyu:handoff` used to also brief pending decisions — but a briefing is analysis aimed at whoever
resumes, and doing it at close means it is produced once and then sits, possibly staling, until
someone actually acts on it. Point of use beats point of production. `/iyu:handoff` now stops at
*naming* what's undecided (one line per decision, in `## Waiting on you`); `resume` does the
*briefing and the deciding*, grounded in the repo as it stands right now, at the moment someone is
actually about to act on it — and it is the only place a decision gets written back the instant it's
made, so a session that ends before the next `/iyu:handoff` doesn't lose it.

## Why decisions are pre-decided, not handed up

A capable employee opening the day does not walk into the owner's office with a list of questions.
They walk in with "these are the calls on the table, here are the options and trade-offs, this is
what I decided and why — tell me if I got any of it wrong." Handing a decision up as a question —
even a well-briefed one — gives the owner the work *and* the waiting: nothing moves until they
answer, and the person with the least context on the work does the choosing.

So a recommendation, once it exists, **is** the decision. It is recorded `provisional` at once, and
the owner's role changes from *choosing* to *correcting*. That is only safe because of two things the
skill keeps intact:

- **Deciding is separated from acting.** A decision is a line in `HANDOFF.md` — reversible by editing
  it. What is not reversible is the *act* some decisions lead to: `git push`, publishing a release,
  registering a GitHub issue, a major-version bump, anything that leaves the repo. The central policy
  gates those on a human, and no skill can relax that. So the decision is made; only the act waits.
  "Silence is not consent" still governs every such act — it just no longer governs the decision.
- **Every provisional decision carries its reverse action** (`to correct:`), so correcting costs one
  sentence.

What is left for the owner is what an employee genuinely cannot supply: a resource from outside
(a credential, an access grant, the owner's own hand on a gated act) — and a **criterion**.

## Why the owner is asked for a criterion, not a decision

When a decision will not settle — the lenses conflict irreducibly, or the governing criterion is
ambiguous, or following it lands somewhere common sense says is wrong — the missing thing is not the
owner's *pick*. It is the owner's *rule*. Asking "A or B?" gets one answer to one decision and the
same stall next time. Asking "the criterion here is X, and it breaks at this point — I propose X′,
under which the answer is B; confirm X′?" fixes the class, not the instance. The skill still decides
(under the proposed criterion), so nothing waits on the answer unless an act does.

This is not an escape hatch from research. A criterion request is reachable only after the bounded
grounding pass has run: an unresearched decision is not a criterion defect, it is an unresearched
decision.

## Why an override triggers an alignment question

When the owner picks something other than the recommendation, the useful information is not only the
pick — it is *why the recommendation was wrong*. Either a criterion the skill applied is off (and it
will be wrong the same way next time), or this case is a genuine exception. Recording only the pick
throws that signal away; asking "which criterion weighed differently — revise it, or one-off?" keeps
it. Over sessions, that is how the skill's judgment converges on the owner's instead of being
overridden one decision at a time.

The confirmed revision is not written into `CLAUDE.md`/`AGENTS.md` by `resume` itself (rule 1: it
writes only `HANDOFF.md`). It lands as a 비코드 item in `## Next`, so the next working session
persists it to wherever the criterion lives — the same route every other doc change takes.
