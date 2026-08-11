---
name: handoff
description: Closes out a work session — records where things stand, migrates completed work out of the continuity docs into the history index, derives and stages the next scope, and surfaces the decisions that are waiting on a human. Produces the document a fresh session (or another person) resumes from, so nothing depends on the current conversation surviving.
when_to_use: User-invoked with "세션 종료를 위한 정리", "HANDOFF/ROADMAP 업데이트", "다음 작업범위 제안", "로드맵 최신화", "wrap up and hand off". Model-invoked (announce before running, per Rule 7) only on a concrete signal that the session is actually ending — the user is closing out or the context window is nearly exhausted — or when HANDOFF.md/ROADMAP.md are visibly stale against what git log shows happened. Not for mid-task pauses, and never as a substitute for asking what to do next.
argument-hint: "[focus or scope note]"
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, Bash
---

# Session Handoff

Write down what the next session needs and nothing else. The output is judged by one test:
**could someone with no access to this conversation pick up the work from these files alone?**

Work this like a capable **team lead** closing out the week. `run-cycle` is the employee who
executes a scope and reports back; this skill is the lead who says where the work stands, what the
team does next, and — for the calls that are the owner's to make — hands up **options with a
recommendation**, not questions (step 6).

## Why this exists separately

`/iyu:run-cycle` already closes out its own runs — but only its own. Most sessions are not cycle
runs, and they end the same way: work happened, the roadmap no longer matches reality, decisions are
pending, and the next scope lives only in a conversation that is about to disappear.

This skill is that closeout, detached from the cycle machinery. It shares its definitions with
`run-cycle` rather than restating them: **[continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md)**
is the single source for where the documents live, what belongs in each, the hygiene pass, and how
next scope is derived, and
**[release-cadence.md](${CLAUDE_SKILL_DIR}/../_shared/release-cadence.md)** is the single source for
where release work sits in the order. Read both first — this file only adds what is specific to
closing a session.

## Scope

`$ARGUMENTS`, when given, narrows what to cover (a submodule, a phase, "just the decisions").
Without it, cover the whole session.

## Process

### 1. Resolve the continuity root

Per [continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §1. Resolve before
reading or writing anything. In an umbrella repo, pick the root covering the code this session
touched — and if the session touched several submodules, write one handoff per root rather than
merging them into whichever was resolved first.

### 2. Reconstruct what happened — from evidence, not memory

The conversation may already be compacted, and it is not the record. Read the actual traces:

- `git log` / `git status` / `git diff --stat` since the session started
- The existing `HANDOFF.md` and `ROADMAP.md` — what did they claim, and is it still true?
- The most recent `cycle-logs/cycle-*.md`, if the project runs cycles — its Carry-Forward, ledgers,
  and Next-Cycle Scope are inherited obligations, not history
- Any `<root>/issues/` drafts written this session

**Unobserved data stays "unknown".** A handoff asserting a test passed, when no one ran it, is worse
than one saying "unverified" — the next session builds on it. If something matters and is unknown,
say so and name the command that would settle it.

### 3. Apply the hygiene pass

Per [continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §3, in full: migrate
every completed item out of `ROADMAP.md` (including pre-existing leftovers) into `HISTORY.md`,
rewrite `HANDOFF.md` to current + next only, keep the `> History:` link.

This is the step that makes the skill worth running repeatedly. The docs converge toward
remaining-work-only on their own, without anyone scheduling a cleanup.

### 4. Derive the next scope

Per [continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §4 — carry-forward
defects, then mid-session discoveries, then emergent scope across the user / developer / operator
lenses, then the backlog. Tag each candidate **autonomous-eligible** or **discussion**.

Scope concretely for *one* next session, not five. Anything further out stays a phase-level
direction in `ROADMAP.md`. Concrete scope for sessions you cannot yet know about is the same failure
`run-cycle` guards against with its no-cycle-numbers rule.

Step 5 then decides where the *rest* sits — deriving the next item and ordering the remainder are
different jobs, and skipping the second is how a release ends up scheduled mid-phase.

### 5. Re-order what remains

Deriving *what* comes next is only half of it. The other half is **what order the rest sits in** —
and the item that most often ends up in the wrong place is the release.

Apply **[release-cadence.md](${CLAUDE_SKILL_DIR}/../_shared/release-cadence.md)** in full:

- **§2, the placement test** — for any push/publish/release item in the backlog, check what remains
  that would touch the same consumer-facing surface. Work still pending on that surface means the
  release belongs *after* it: publishing mid-phase buys a version the next few items obsolete, and
  every pushed pipeline spends a shared CI budget. Finished work that consumers are waiting on
  pushes the other way. When the two genuinely conflict, that is a decision for step 6's
  "Waiting on you", not one to settle here.
- **§3** — follow the project's declared cadence; if there is none, infer it from tags and release
  history and **say that you inferred it**.
- **§4** — the outcome is an **edit to the order in `ROADMAP.md`/`HANDOFF.md`**, with a one-line
  reason at the marker (`— after Phase 3; Phase 3 changes the same CLI output`). A paragraph of
  reasoning is advice the next session skips; a reordered list is what it reads first.

The same test applies to ordinary items when one obviously blocks another, but the release is the
recurring case: it is easy to add "release" the moment work feels done, and then it sits in the
middle of a phase that will change the same surface again.

**Report what moved.** A silently reordered backlog is indistinguishable from drift. And reorder
only — adding, dropping, or rescoping items is separate work with its own rules.

### 6. Surface the decisions — briefed, not just listed

Two lists, kept apart because they behave differently:

- **Waiting on a human** — irreversible or human-only **decisions**, plus anything **blocked on a
  resource** (a credential, an access grant, an external dependency).
- **Decided along the way** — reversible choices made during the session that carried a real
  trade-off. Each with its alternatives, the trade-off, and a one-line **"to correct: <the reverse
  action>"**. Presenting these is what makes deciding-then-reporting safe rather than sneaky. Pure
  taste choices are not recorded.

Before writing any "waiting on you" entry, run the self-unblock check: is the resource *actually*
missing (look, don't assume), and does a governing doc, an accepted issue, or a prior decision
already answer the question? An assumed blocker parks work that could have proceeded.

Then brief them. A capable team lead does not hand the owner a question — they hand over the
options, what each costs and buys, and which one they would pick and why, because the owner's job is
to decide, not to re-derive the analysis.

Apply **[decision-briefing.md](${CLAUDE_SKILL_DIR}/../_shared/decision-briefing.md)** in full: the
two entry shapes (§1 — resource-blockers stay short, decision-class gets briefed), the four parts
(§2), and the guards (§3). Three of those guards decide how this section reads:

- **Grounded options.** Feasibility and cost come from the tree you read in step 2. Rule 4's *do not
  implement* still holds — reading to ground an option is not starting the work — and rule 2 governs
  what you cannot observe: unknown stays "unknown", with the command that would settle it.
- **Recommendable + reversible → not here.** It belongs under **Decided this session**. The briefing
  format makes escalation comfortable; that is exactly why it must not become the default.
- **Nothing to decide → say "None".** If everything remaining can be carried autonomously, that is
  the finding, and it is a good one. Never manufacture a decision to fill the section.

If the project already uses decision IDs (`HD-01`, `D-03`, …), continue that numbering rather than
starting a scheme of your own.

## Output

`<root>/HANDOFF.md`, rewritten:

```markdown
# HANDOFF
> History: [HISTORY.md](HISTORY.md)

**Updated**: {YYYY-MM-DD} · **Root**: {resolved root}

## In flight
{What is half-done right now, and where exactly it stopped. "None" if the session ended clean.}

## Next
{Concrete scope for the next session — from carry-forward, discoveries, or an autonomous-eligible
emergent candidate. Anchored to a ROADMAP phase. One session's worth.}

## Waiting on you
{"None" — the right answer whenever everything left can be carried autonomously — or entries in the
two shapes below: the first decision-class, the second resource-blocked.}

### {HD-01} {the decision, in one line}
- **Options**
  - **A. {option}** — {consequence, grounded in what you read}
  - **B. {option}** — {consequence}
  - **C. Defer** — {what happens meanwhile}
- **Cross-lens read**: {only the lenses that separate the options — e.g. "B is 세련하지만 표준에서
  벗어남: the ecosystem does A"}
- **Recommendation**: {A} — {reason, 1-2 sentences}. **Locks in**: {what becomes hard to undo}.

### {HD-02} {what is blocked}
- **Blocker**: {the missing credential / access / dependency}
- **Tried**: {what was actually attempted}
- **Unblocks it**: {the specific thing you need}

## Decided this session
{Reversible self-made decisions: decision · trade-off · to correct. Or "None".}

## State of play
{Build/test/lint status with the actual output, or explicitly "unverified". Branch, uncommitted
work, anything a fresh clone would not reveal.}
```

Plus: `ROADMAP.md` with completed work removed (hygiene pass) **and its remaining phases in the
order step 5 settled on**, and `HISTORY.md` with the completed work appended.

Then report the same five sections in chat — the file is for the next session, the response is for
the person reading now. "Waiting on you" is the section that person actually acts on, so carry the
options, the cross-lens read, and the recommendation into the response too; a chat summary that
compresses a briefed decision back into "needs your input" undoes step 6.

## Rules

1. **Remaining work only.** Completed work belongs in `HISTORY.md`. Every run enforces this, not
   just runs where something was completed.
2. **Evidence over assertion.** Test/build claims carry their output or are marked unverified.
3. **Do not commit.** Writing the handoff is not a checkpoint to commit — the human decides when to
   commit, and often wants the handoff diff visible while deciding. Report what is uncommitted
   instead.
4. **Do not implement.** If step 2 surfaces a defect, record it — fixing it starts a new session's
   work and leaves the handoff describing a state that no longer exists.
5. **Recommend, don't ask — but only where a decision exists.** A decision-class entry leaves with
   options and a recommendation; a bare question is an incomplete entry. An **empty** section is a
   complete one: if nothing left needs the human, "None" is the finding, not a slot to fill. And if
   you can recommend it *and* it is reversible, it belongs in "Decided this session", not here.
6. **One root per handoff.** In an umbrella repo, several submodules touched means several handoffs,
   each in its own root.
7. **Model-invoked runs announce first.** When this skill starts without an explicit user invocation
   (`/iyu:handoff`), say in one line that a handoff is running and why, *before* touching any file —
   the rewrite is reversible, but a silent one still surprises whoever is reading the conversation.
