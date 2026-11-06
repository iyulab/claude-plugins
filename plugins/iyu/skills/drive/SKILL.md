---
name: drive
description: Pushes the open stage of a product to its agreed satisfaction bar — implement one failing scenario at a time, have an independent evaluator judge the running build, repeat until the stage passes or needs something only the owner can supply, then show the owner a demo. Use after `/iyu:charter` has a signed stage contract.
argument-hint: "[stage id]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash, Agent, Task, Skill, AskUserQuestion
---

# Drive — finish the stage, not the backlog

This skill answers one question: **is the open stage done?** It ends when the stage passes, or when it
needs something only the owner can supply. Running out of ideas is not an ending, and new scope goes to
`parking.md`. Contract, terms, field ownership and what "passed" means:
**[stages.md](${CLAUDE_SKILL_DIR}/../_shared/stages.md)**. Why it is shaped this way, and the known
gap (no stop hook yet): [references/rationale.md](${CLAUDE_SKILL_DIR}/references/rationale.md).

## Standing instructions — they hold for the whole run

- **Keep working until the stage passes, and stop only when you can't go on without the owner.** A
  compaction or `/clear` is not such a point: keep `stages.json`, the evidence files, `parking.md` and
  local commits current, and after a reset rebuild your position from them and `git log`, then continue.
- **The evaluator sets `passes`, claim states and `status: passed`.** You build; it judges.
- **Build the behavior a scenario stands for, for every valid input** — not code shaped to the
  script's exact values or the evaluator's path. If a scenario looks wrong, raise it with the owner,
  with evidence; the contract changes only through `/iyu:charter`.
- **Out-of-stage discoveries go to `parking.md`** (one line: what, why it matters) and stay there for
  the stage boundary.
- **Releases stay with the owner**: commit locally; push, publish and version bumps are a separate act
  ([release-cadence.md](${CLAUDE_SKILL_DIR}/../_shared/release-cadence.md)).

## Before the first round

1. Resolve `<root>` ([continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §1); read
   `<root>/stages/stages.json` in the current repository only (a contract elsewhere
   belongs to another product). With no contract, no `open` stage, or no owner sign-off recorded in
   `charter-notes.md`, stop and point to `/iyu:charter` — the goal is the owner's to set.
2. Make sure the contract's `run` command works from a clean checkout. If there is none, create the
   smallest script that builds and starts the product and record it as a contract question for the
   owner (the evaluator needs it either way).
3. Read the owner's recorded answers in `charter-notes.md`. An `open` owner decision blocks only the
   scenarios that depend on it; those scenarios are parked, and the rest proceed.
4. Use the contract's `budget`, or the defaults in stages.md §9.
5. If `bar.calibration` is `pending`, then once the build first produces real output, show it to the
   owner with `AskUserQuestion`, ask for a score per rubric item, and record the scores with the quote
   (stages.md §4) before the first evaluation.

## The round — repeat until the stage passes or you escalate

**R0 — smoke.** First round of each session: start the product with `run` and walk the primary
scenario yourself. Fix anything that worked before and fails now before new work.

**R1 — pick one.** From the newest evidence, take one failing scenario or one rubric item below its
threshold — the one that unblocks the most others, else the lowest id.

**R2 — plan, then build.** Write five lines to `<root>/stages/evidence/<stage>-<NN>-plan.md`: what will
change, which scenario or rubric item it targets, how the evaluator can tell. The evaluator may check
more than this, never less. Make the smallest change that could pass it, **through the stage's seam**
(stages.md §7): replace mock with real behind the contract rather than beside it, and run the
contract's tests and dependency-direction checks. A change that needs the seam contract itself to move
is an owner question. Run a real check that exercises the change — the tests it reaches, the build, or
the changed command; a check that failed to start does not count — and commit locally, one intent per
commit.

**R3 — evaluate, independently, when there is a pass to confirm.** After a round you believe makes a
scenario or rubric item pass (and once more before the demo), dispatch one `Agent`
(`subagent_type: general-purpose`) whose prompt
is the text of [the evaluator brief](${CLAUDE_SKILL_DIR}/../accept/references/evaluator.md) followed by
absolute paths to the contract, the stage id and the evidence directory, plus the `run` command and the
mode (`full`). Give it only the contract and the build — not how you built it or what you expect to
pass. Rounds that claim no new pass (investigation, a failed attempt) skip R3; the evaluator is the
acceptance gate, not a re-check of every edit.

**R4 — decide.** If R3 ran, read the evidence file; a defect it names is the next pick. Progress
(stages.md §9) counts only evaluator-confirmed passes: `stall_rounds` rounds in a row without a rise,
or `max_rounds` reached → escalate (below). Otherwise → R1.

## When every machine-checkable condition passes

All scenarios pass, every threshold is met, every claim is `works` on a `full` evaluation. Then:

1. Prepare the **demo**: the one command to run it, what to click or type, and evidence the owner can
   open without setup — screenshots or a recording under `<root>/stages/evidence/`.
2. Ask the owner once, with `AskUserQuestion`: **pass** or **adjust**. Notes on *adjust* become the
   next rounds' picks; a note that changes what the stage asks for is a contract change for
   `/iyu:charter`.
3. On *pass*: set `owner_accepted: true` with the quote in `charter-notes.md`, dispatch the evaluator
   once more (`full`) so it sets `status: passed`, invoke `/iyu:handoff`, and recommend `/iyu:charter`
   for the next stage. The next stage starts with its own interview.

## Escalating — one question, with evidence

Escalate when every remaining scenario is blocked or the stall rule fires. Write a few lines: what the
stage still lacks (link the evidence file), what was tried and why it did not raise progress, the
**single question** that would unblock it with your recommendation, and which scenarios it opens. Then
invoke `/iyu:handoff`, which records the question under `## Waiting on you`, and end the run;
`/iyu:resume` briefs it next session.

Output language: [continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §5.
