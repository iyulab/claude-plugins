# Why charter is shaped this way

**Why a separate skill from `run-cycle`.** `run-cycle` is an open loop: scope is derived from the
latest output, and it may end when nothing is left to derive. That is right for maintenance and
exploration and wrong for "make this product reach a defined state": nothing in the loop records the
destination, so "the backlog ran dry" gets read as "done". A goal-bound run needs the goal written
down by someone who owns it, in a form a different agent can test.

**Why front-loading questions keeps the autonomy bias.** The questions asked here are the ones
`drive` would otherwise raise one at a time, mid-run, as blockers. Asking them once, early, each with
a recommendation, is what lets `drive` run without stopping. Reversible choices are still made by the
agent and recorded, not asked.

**Why the draft comes before the questions.** Asked one topic at a time with a recommendation
attached, an owner takes the recommendation nearly every time — which says less about agreement than
about the form: a question with a marked answer is a request for confirmation. A whole draft puts
the same recommendations where they can be read against each other and corrected, and leaves the
questions for what no draft can supply. Calibration is the exception that proves it: there the
owner's unprompted score is the data, so the options carry no recommendation.

**Why the owner signs.** The contract is what stops an implementer from passing a stage by moving
the line. The agent that builds may not edit scenarios, thresholds or non-goals (stages.md §4), so
the people who set them have to be in the room once.

**Why only the first stage is detailed.** A planner that specifies everything up front turns an early
mistake into a cascade. Keep later stages to a line and re-open the interview at each boundary, when
the previous stage has taught something and the field has reacted.

**Why calibration by the owner.** A model asked to judge its own or another model's output tends to
approve it. A skeptical evaluator is easier to tune than a self-critical builder, but it must be
tuned against the owner's actual scores, not against a rubric's adjectives.

**Why decisions are collected here.** In long autonomous runs most stalls are an owner decision that
surfaced mid-run. Surfacing them at the start of a stage, with a recommendation, turns "blocked" into
"answered or consciously deferred" before any code depends on them.

**Why the mock's gaps are classed.** A landing page or demo is written at the best quality without
regard to the current build. Each promise it makes is either built, assembled from parts that
already exist, or dropped for this stage. Classing them once turns the mock into a backlog and makes
open-ended discovery unnecessary while a stage is open.

**Prior art this borrows from** (read the originals, not this summary): Anthropic's engineering posts
on long-running agent harnesses (feature list with a single mutable `passes` field; planner kept
high-level; a separate evaluator that drives the running app; contracts agreed before building),
GitHub Spec Kit's *clarify* step (questions before implementation), the walking-skeleton and
skateboard-to-car MVP ladders.
