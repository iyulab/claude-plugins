---
name: charter
description: Interviews the owner to set a product's goal and writes the stage contract — an ordered ladder of stages that each work on their own, with scenarios an observer can watch, a calibrated satisfaction bar, the promises each stage must keep, and every owner decision that could block it. Use before `/iyu:drive`, and again at each stage boundary.
argument-hint: "[scope, or the stage to re-open]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, WebSearch, WebFetch, AskUserQuestion
---

# Charter — set the goal before pushing toward it

This skill draws the finish line `drive` pushes toward, **with the owner**, and stops. Its only output
is the contract defined in **[stages.md](${CLAUDE_SKILL_DIR}/../_shared/stages.md)** — read that first
for the fields and terms. Why the interview is front-loaded, why only the first stage is detailed, and
why this keeps the plugin's autonomy bias:
[references/rationale.md](${CLAUDE_SKILL_DIR}/references/rationale.md).

Ask the owner for what only the owner has: the goal, what "good enough" looks like, what to leave out,
and the irreversible or externally owned decisions. Make reversible choices yourself and record them
([decision-lenses.md](${CLAUDE_SKILL_DIR}/../_shared/decision-lenses.md)).

## Process

### 1. Resolve the root and the mode

Resolve `<root>` ([continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §1). Then:

- **No `<root>/stages/stages.json`** → *first charter*: full interview for the first stage, one-line
  sketches for the rest. In an existing codebase, record what already works in `charter-notes.md` as the baseline; it becomes a
  `passed` stage only through an evaluation.
- **A stage is `passed` and the next is `upcoming`** → *boundary charter*: read that stage's evidence,
  `parking.md`, and whatever the owner brings from the field (demo feedback, user or sales reactions);
  interview for the next stage only.
- **A stage is `open`** → the contract is signed. Change it only when the owner asks; show the diff.

### 2. Ground yourself before asking

Read `CLAUDE.md` / `README.md`, any mock, landing page or demo, the roadmap and handoff, and the code.
Note what already works, what the mock promises, and what the mock needs that the build lacks. Skip
any question the repo already answers. Research what can be researched (comparable products,
standards, parts the project or its organisation already has) so each question arrives with options
and a recommendation.

### 3. Interview — up to three rounds of `AskUserQuestion`, four questions each, recommendation first

1. **Goal and ladder** — what the finished product is for, who uses it, the stages in order. Test each
   stage: *could someone use this today, on its own?* Merge a stage that is only a layer of the next.
2. **The open stage in detail** — what a user can do (3–5 things), the surface it is watched on, the
   scenarios as scripts with the expected *visible* result (see the example in stages.md §3), and the
   non-goals.
3. **The bar** — a rubric with a threshold per item, and **calibration**: show the owner two or three
   real or sketched outputs and record their scores, so the evaluator's eye matches theirs. With no
   output yet, record `"calibration": "pending"`; `drive` asks the owner to score the first real output
   before its first evaluation.
4. **Promises and gaps** — the claims the mock makes for this stage (stages.md §6), and for each gap:
   build it, assemble it from existing parts, or fold it.
5. **Decisions that could block this stage** — design choices, new dependencies, legal or cost calls,
   anything external. Collect them all now, each with options, a recommendation, and the stage it opens.
6. **How it runs and how long to push** — the one command that builds and starts the product (`run`;
   if none exists, note that `drive` creates it first) and the `budget` (stages.md §9 defaults unless
   the owner sets others).
7. **The seam** — draft the contracts and invariants where the mock or UI meets the core (stages.md
   §7); the owner reviews one or two pages.

Stop interviewing once the open stage can be watched and judged. Remaining unknowns become
`owner_decisions` or a sketch line.

### 4. Write, then ask for the signature

Write `stages.json` and `charter-notes.md` (the owner's answers quoted, each recommendation marked
taken or overridden). Present one screen: goal, ladder, the open stage's scenarios and bar, the open
decisions. The contract is signed when the owner says so in the conversation: record the quote, set
the first stage `open`, and stop. Recommend `/iyu:drive` as the next step.

## Standing rules

- This skill writes the contract and the notes, and nothing else — product code waits for `drive`.
- Exactly one stage is `open`; the others are `upcoming` with a sketch.
- The contract carries order only — no dates, durations or cycle numbers.
- Output language: [continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §5.
