# Why drive is shaped this way

**One scenario per round.** A model asked to finish a whole product in one pass tries to, runs out
of context part-way, and declares victory early. One failing, named thing per round keeps the unit
of progress small enough to verify and small enough to revert.

**The evaluator is not the builder.** Self-evaluation is lenient: the same agent that wrote the code
spots the defect and then argues itself out of it. Splitting the roles — and briefing the evaluator
to be skeptical and to drive the running build — is easier to tune than making a builder self-critical.
The builder passes the evaluator only the contract and the build, so the verdict cannot lean on the
builder's account.

**The evaluator runs when there is a pass to confirm, not every round.** Newer models verify their own
work well, and a separate verification step on every edit adds cost without adding quality. What a
separate evaluator still buys is an acceptance gate the builder cannot talk past: it alone writes
`passes`. So the builder runs its own checks each round, and the evaluator is dispatched when a round
claims a new pass and once before the demo.

**The builder cannot write `passes`.** The mutable surface of the contract is deliberately tiny and
owned by the evaluator. "Done" is then a property of the artifact, not of the transcript.

**Stall is measured, not felt.** "No rise in scenarios passing + rubric items at threshold, for
`stall_rounds` rounds" is a number the contract carries. It turns "keep going until it is good" into
a bound, which is what makes "push to the end" safe to run unattended.

**Escalation is one question with evidence.** An escalation that arrives as a list of options and a
shrug moves the stall to the owner. One question, the evidence, the recommendation and what it unlocks
is cheap to answer — which is the point of asking late and rarely.

**Autonomy bias is kept.** Reversible decisions are made and recorded, not asked. What reaches the
owner mid-run is only what the charter could not know and a person must supply.

**No `backlog-discover` while a stage is open.** Discovery widens; the stage narrows. New ideas are
cheap to park and expensive to follow.

## Known gap: no stop hook (v1)

`run-cycle` enforces "do not stop early" with a Stop hook that reads logs and matches literal tokens.
`drive` has none: stopping before the stage passes relies on this skill's text. A hook would have to
follow the plugin's rules for hooks (a `command` script, literal tokens, hook-dryrun fixtures, reading
and never writing) and is a separate piece of work. Until then, an early stop shows up as a stage whose
latest evidence is `fail` or `unverified` with `status` still `open` — `resume` surfaces exactly that.
