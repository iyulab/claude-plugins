---
name: resume
description: Opens a work session — reads the continuity docs and recent state, synthesizes where things actually stand, proposes a re-prioritized next scope with any derived prerequisites or objections, and settles the decisions `/iyu:handoff` flagged the way a capable employee would — grounded options, trade-offs, and a recommendation that becomes the provisional decision, recorded at once for the owner to correct rather than answer. Only external blockers, owner-gated acts, and criterion gaps are left waiting on the owner. Then stops — execution is a separate, explicit step.
when_to_use: User-invoked with "세션 시작", "다음 작업 확인", "핸드오프 확인하고 시작", "resume this session". Model-invoked (announce before running, per rule 8) when a fresh session's first message states no explicit task and the continuity root already has a `HANDOFF.md` — the same self-invoke bar `/iyu:handoff` uses, since this skill proposes and decides but never implements. Not for mid-session re-checks (read `HANDOFF.md` directly for that), and not a substitute for `/iyu:run-cycle` — resume always stops short of execution; run-cycle is the separate, explicit step that starts it.
argument-hint: "[focus or scope note]"
allowed-tools: Read, Glob, Grep, Edit, TodoWrite, Bash, WebSearch, WebFetch
---

# Session Resume

Read what `/iyu:handoff` left, synthesize where the work actually stands right now, and settle
anything flagged as undecided — before any real work begins. Work this like a capable employee
preparing to open the next work block, not like someone mechanically continuing where a diff left off:
pull the continuity docs and current repo state together, judge whether the recorded order still holds,
surface what it's missing, and question what looks wrong — then hand back a settled scope and **stop**.
Starting the work is a separate act this skill never takes on its own.

Why it is shaped this way — split from `/iyu:handoff`, pre-deciding instead of asking, asking for
criteria instead of decisions — is in
[references/rationale.md](${CLAUDE_SKILL_DIR}/references/rationale.md).

## Scope

`$ARGUMENTS`, when given, narrows what to confirm (a submodule, "just the decisions"). Without it,
cover the whole continuity root.

## Process

### 1. Resolve the continuity root

Same rule as every other skill in this plugin —
[continuity-docs.md §1](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md). In an umbrella repo,
resolve the root covering what this session is actually about to touch; if that is not yet known,
ask.

### 2. Read — ground the synthesis, don't redo the archaeology

Read `<root>/HANDOFF.md` and `<root>/ROADMAP.md` as they stand. Then ground judgment in current
state, not just the doc text: `git status` / `git log -1` since the last handoff, the tail of
`HISTORY.md` for what actually shipped, `<root>/STRANDS.md`'s `## 중단됨` section (if the file
exists) for anything recently sidelined, and recent memory (`MEMORY.md` and relevant memory files)
touching this root. This is not `/iyu:handoff`'s evidence reconstruction — no cycle-log reading, no
hygiene pass, no migrating anything to `HISTORY.md`. Those stay `/iyu:handoff`'s job; this read grounds
step 3's judgment in what changed since, it does not redo the archaeology.

No `HANDOFF.md` → say so, point at `ROADMAP.md` or `/iyu:backlog-discover` if neither exists, and
stop — there is nothing to resume.

### 3. Synthesize and present In flight + Next

Don't just replay `## In flight` / `## Next` as written — apply judgment to what step 2 surfaced:

- **Flag staleness.** If `## In flight` describes something half-done but the tree is clean, or the
  last commit contradicts what `## Next` assumes, say so before presenting either — a stale doc handed
  over silently defeats the point of resuming from it.
- **Surface a recent interruption.** If `STRANDS.md`'s `## 중단됨` has an entry interrupted within
  roughly the last session (freshest `마지막` entry relative to `HANDOFF.md`'s own last-updated
  date), treat it as an objection: judge whether to resume `{strand}` now or keep the current order,
  and carry that call into step 4 as a decision ("`{strand}` 재개를 X 앞에 둠 — 이유 …, to correct:
  …"), never as a question back to the owner. This is not new discovery
  (rule 9): the strand is already-known, already-scoped work being reordered, not scoped from
  scratch. An entry that has stayed interrupted far longer than one session is not this skill's
  concern — that is `/iyu:backlog-discover`'s `dormant-strand-review`, which judges reignite,
  shrink-and-resume, or retire with evidence rather than a scheduling nudge.
- **Reorder** when the recorded priority no longer fits current state (a dependency landed, a blocker
  resolved, an external deadline shifted) — show the new order next to the recorded one, with the
  reason (step 4 decides it).
- **Derive prerequisites** the plan is missing — a step it silently assumes is already done, a
  dependency it doesn't name. Add these as visible insertions, not silent edits.
- **Object** to anything in `## Next` that no longer looks reasonable given current state — say why,
  and what you'd do instead.

This is judgment over what the continuity docs and current state already contain — not new research.
Discovering work nobody has scoped yet stays `/iyu:backlog-discover`'s job (rule 9); if that's what's
actually needed, recommend it, don't attempt it here.

**Split each list into 코드 작업 / 비코드 작업.** Code work is anything that changes what ships
(source, tests, config, build). Non-code work is everything else the continuity docs track — docs, an
issue draft, a roadmap edit, a release or external-communication step. The presentation split is what
carries the real payload to step 4 — that's where it's read to spot owner-gated acts, which live in
the non-code bucket — so a bucket with nothing in it just reads "None" rather than being dropped.

**`## Next` empty → say so and recommend `/iyu:backlog-discover`.** Same closing move `run-cycle`'s
End-of-Run Report makes when a run ends on `FRONTIER-EXHAUSTED:` with budget left: an empty backlog
isn't this skill's gap to fill — step 3's synthesis reorders and extends what's already scoped, it
does not discover unscoped work from nothing (rule 9) — it's a pointer to the skill that does. A
pointer only: name the recommendation, do not invoke it. Only say this when `## Next` itself is empty;
an empty `## Waiting on you` with items still in `## Next` is step 4's good outcome, not this one.

### 4. Settle what needs deciding — decide it, don't hand it back

Two sources feed this step: handoff's `## Waiting on you` entries, and the reorder / prerequisite /
objection proposals step 3 raised. A proposal from step 3 is decision-class the moment it changes what
ships or in what order — where a decision came from doesn't change how it's handled.

**The default is that you decide.** Handing a decision up as a question gives the owner both the
work and the wait. A recommendation, once formed, *is* the decision: recorded `provisional` in step
5 and presented for correction, not for an answer. What reaches the owner as something to *supply*
is only what you genuinely cannot — a resource from outside, the owner's hand on a gated act, or a
criterion.

For each entry, classify and handle:

- **Resource-blocked** (blocker · tried · unblocks) — re-run the self-unblock check (the same
  "Self-unblock before parking" logic `run-cycle` applies): is the resource *actually* still missing?
  Time has passed since it was parked. Still blocked → it stays in Waiting on you. Resolved → say so
  and drop it.
- **Decision-class** — brief it per
  [decision-briefing.md §2](${CLAUDE_SKILL_DIR}/../_shared/decision-briefing.md): the decision in one
  line, **at least two grounded options** (feasibility and cost from what you read in step 2 or the
  grounding pass below — never invented), the **cross-lens read**
  ([decision-lenses.md](${CLAUDE_SKILL_DIR}/../_shared/decision-lenses.md), only the lenses that
  separate the leading options), and a **named recommendation** with what it locks in. **Then decide
  it**: the recommendation is the provisional decision. Present it as "결정: X — 트레이드오프 …,
  이견 있으면 알려주세요", never as "A와 B 중 어느 쪽으로 할까요?".
  - **Decide ≠ act.** If carrying the decision out needs an act the central policy gates on a human —
    `git push`, publish/release, registering a GitHub issue, a major-version bump — or an act that is
    irreversible outside this repo, the *decision* is still made and recorded; only the *act* goes to
    Waiting on you, in the resource-blocked shape where the owner is the resource: **blocker** = the
    gate · **tried** = decision settled (`→ Decided this session`) · **unblocks** = approval to run
    `<the act>`. Confidence never lifts the gate; the gate never un-makes the decision.
  - The step-3 split (코드/비코드) is how you spot such acts: a code decision reverses through git and
    has none; a non-code decision is where push/publish/registration live.
- **Criterion request** — reachable only *after* the grounding pass, when the decision still will not
  settle because (a) the lenses conflict irreducibly, or (d) a criterion does exist but is ambiguous
  here or, followed faithfully, lands somewhere common sense says is wrong (decision-lenses.md's
  cause table). **Do not ask the owner to pick an option — ask for the criterion.** Name the criterion
  and where it breaks, propose the revised criterion, and **decide under it** (provisional, as
  above): "판단기준 X가 이 지점에서 모호/상식에 반함 → X′로 보완 제안, X′ 기준으로는 Y로 결정. X′를
  확정해 주세요." The decision does not wait for the answer; only its gated act, if any, does.

**Grounding pass — settle the unknown instead of reporting it.** When a recommendation does not form
on the first pass, close the gap before writing anything:

- **Name the one unknown that separates the leading options.** Not everything unknown about the
  decision — the single thing whose answer would move the pick. If nothing would, there is no gap and
  the recommendation was already available.
- **Settle it, bounded (~5 min per entry)**, per decision-lenses.md's cause table — (b) read the
  file/test/dependent or `WebSearch`/`WebFetch` the convention; (c) derive the missing criterion
  from CLAUDE.md/README and philosophy-alignment-guide.md and recommend it with the option it
  implies. Run the cheap command rather than naming it. Only (a) and (d) become criterion requests,
  and only once (b) and (c) are ruled out.
- **If the bounded search came back empty, say what you searched**, not only what is still unknown.

This does not widen the skill (rule 9). Grounding a decision that is *already on the table* is
judgment over known work. Scoping work nobody has identified yet is still `/iyu:backlog-discover`'s
job.

**After this step, Waiting on you holds only resource-blocked entries (external, or an owner-gated
act) and criterion requests.** A decision-class entry never remains there as an open question.
Nothing to decide → "None", and move straight to confirming In flight / Next. Do not manufacture a
decision to fill the section.

### 5. Record immediately, then take feedback

**Record before presenting, and do not wait to record.** Every decision step 4 made goes into
`<root>/HANDOFF.md`'s `## Decided this session` (create the section if absent) in the shape
`/iyu:handoff` uses — decision · trade-off · **to correct: <the reverse action>** — marked
`provisional`, with the lenses that carried it. In the same edit, rewrite `## Waiting on you` to what
step 4 left there: a flag that got decided moves out (its gated act, if any, stays as a
resource-blocked entry pointing at the decision); criterion requests go in. Do this now, not at the
next `/iyu:handoff` — a session that ends first must not lose it.

**A reorder is applied to `## Next` itself, in the same edit** — self-decided or owner-confirmed.
Rewrite that section into the decided order (keeping the 코드/비코드 split), and mark the
`## Decided this session` entry as applied.
[continuity-docs.md §2](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) makes `## Next` the
authoritative statement of what comes next — what `/iyu:run-cycle` Preparation reads as its opening
scope — so a decision recorded only in prose is one a later session can start without ever seeing.

**`ROADMAP.md` is still not this skill's to write (rule 1).** `/iyu:handoff` reads
`## Decided this session` as an inherited fact and carries a reorder into `ROADMAP.md`; an entry
marked applied means applied *to `## Next`* only.

**Feedback is how the criteria get corrected — handle it, don't just transcribe it.** This applies
when an answer arrives later in the same conversation, after step 6 has presented and stopped —
resume does not wait for it.

- **Owner confirms or says nothing** → the provisional decision stands. Silence does not block a
  decision (it was already made); it never authorizes a gated act (rule 3).
- **Owner picks differently from the recommendation** → apply the new pick (update the entry and
  `## Next`), then ask one alignment question instead of silently moving on: **which criterion
  weighed differently — should it be revised, or is this a one-off exception?** Name the lens or
  rule that drove the recommendation so the owner is correcting something specific ("근본을 세련보다
  무겁게 봤는데, 이 프로젝트에선 반대로 둘까요?").
- **A criterion gets confirmed** (from that question, or an answered criterion request) → record it
  in `## Decided this session` as a criterion entry, re-derive any pending decision under it (update
  the entry if the pick changes), and insert a 비코드 `## Next` item to persist it where the
  criterion lives — the project's `CLAUDE.md`/`AGENTS.md`, or, for a plugin-level lens, a
  note in this plugin's own backlog. This skill does not write those files itself (rule 1).
- **One-off exception** → record it as such in the entry, so a later session does not read it as
  precedent.

### 6. Stop — hand off, don't execute

Once In flight / Next is settled (including step 3's proposals), every decision is recorded, and
Waiting on you holds only blockers and criterion requests, the session-opening work is done. **This
skill does not proceed into implementation from here.** Present the settled scope — what's in flight,
what's next in the (possibly reordered) sequence, what got decided (each with its to-correct line),
and what still needs the owner — and stop. Starting the work is a separate, explicit act: the human
instructs it directly, or `/iyu:run-cycle` is invoked. A settled scope is not that instruction. If
the owner answers with feedback instead, handle it per step 5's feedback rules, then stop again.

## Rules

1. **`HANDOFF.md` is the only file this skill writes.** It never migrates `ROADMAP.md` →
   `HISTORY.md`, never touches `ROADMAP.md`, `CLAUDE.md`, or `AGENTS.md`, and never runs
   `/iyu:handoff`'s hygiene pass. Inside `HANDOFF.md` it writes exactly three things (step 5):
   `## Decided this session` entries, `## Next` (a decided reorder, and any criterion-persistence
   item), and `## Waiting on you` (what step 4 left there). Phase-level order in `ROADMAP.md` stays
   `/iyu:handoff`'s to apply.
2. **Ground options and proposals in what was actually read or run.** A step-3 reorder or
   prerequisite needs a stated reason grounded in step 2's read, not a hunch. An unknown that
   *separates the leading options* is **settled by step 4's grounding pass**, not reported as
   unknown. Only an unknown that survives that bounded pass stays "unknown", reported together with
   what was searched.
3. **Decisions don't wait; gated acts do.** A recommendation is decided and recorded `provisional`
   without waiting for a reply. An act the central policy gates on a human (push, publish/release,
   GitHub issue registration, major-version bump) or that is irreversible outside the repo never runs
   on silence — silence is not consent for an *act*.
4. **The owner is asked for resources and criteria, never for a pick.** Waiting on you holds
   resource-blocked entries (including owner-gated acts) and criterion requests only. "A or B?" is
   the one shape a decision may not reach the owner in.
5. **An override is a signal about the criteria.** When the owner picks against the
   recommendation, ask whether the criterion behind it should be revised — do not just record the
   pick.
6. **"None" is a complete outcome.** Nothing flagged and no step-3 proposal → say so; it is the good
   result, not a gap to fill.
7. **Never starts the work itself.** Step 6 ends the skill at a settled scope — implementation begins
   only on a separate explicit instruction or `/iyu:run-cycle`. Reading, running a cheap command, or
   searching to ground a decision is not starting the work.
8. **Model-invoked runs announce first.** Same as `/iyu:handoff` rule 7 — say in one line that a
   resume is running and why, before touching any file.
9. **Synthesis is judgment over known work, not discovery of new work.** Step 3 and step 4's
   grounding pass operate on what is already on the table — the boundary is what the work is aimed
   at, not whether reading or searching happens. Scoping work nobody has identified yet stays
   `/iyu:backlog-discover`'s job; an empty `## Next` gets that skill *named*, never invoked.
