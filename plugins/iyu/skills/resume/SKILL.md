---
name: resume
description: Opens a work session — reads the continuity docs and recent state, synthesizes where things actually stand, proposes a re-prioritized next scope with any derived prerequisites or objections, and briefs the decisions `/iyu:handoff` flagged with grounded options and a recommendation. Records what gets decided immediately, then stops — execution is a separate, explicit step.
when_to_use: User-invoked with "세션 시작", "다음 작업 확인", "핸드오프 확인하고 시작", "resume this session". Model-invoked (announce before running, per rule 6) when a fresh session's first message states no explicit task and the continuity root already has a `HANDOFF.md` — the same self-invoke bar `/iyu:handoff` uses, since this skill proposes and decides but never implements. Not for mid-session re-checks (read `HANDOFF.md` directly for that), and not a substitute for `/iyu:run-cycle` — resume always stops short of execution; run-cycle is the separate, explicit step that starts it.
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

## Why this exists separately

`/iyu:handoff` used to also brief pending decisions — but a briefing is analysis aimed at whoever
resumes, and doing it at close means it is produced once and then sits, possibly staling, until
someone actually acts on it. Point of use beats point of production. `/iyu:handoff` now stops at
*naming* what's undecided (one line per decision, in `## Waiting on you`); this skill does the
*briefing*, grounded in the repo as it stands right now, at the moment someone is actually about to
act on it — and it is the only place a decision gets written back the instant it's made, so a session
that ends before the next `/iyu:handoff` doesn't lose it.

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
  date), mention it as an objection-style flag — "want to resume `{strand}` now, or keep the current
  order?" — using the same reasoning as any other objection in this step. This is not new discovery
  (rule 9): the strand is already-known, already-scoped work being reordered, not scoped from
  scratch. An entry that has stayed interrupted far longer than one session is not this skill's
  concern — that is `/iyu:backlog-discover`'s `dormant-strand-review`, which judges reignite,
  shrink-and-resume, or retire with evidence rather than a scheduling nudge.
- **Reorder** when the recorded priority no longer fits current state (a dependency landed, a blocker
  resolved, an external deadline shifted) — present the proposed order next to the recorded one, with
  the reason.
- **Derive prerequisites** the plan is missing — a step it silently assumes is already done, a
  dependency it doesn't name. Add these as proposed insertions, not silent edits.
- **Object** to anything in `## Next` that no longer looks reasonable given current state — say why,
  and what you'd do instead.

This is judgment over what the continuity docs and current state already contain — not new research.
Discovering work nobody has scoped yet stays `/iyu:backlog-discover`'s job (rule 9); if that's what's
actually needed, recommend it, don't attempt it here.

**Split each list into 코드 작업 / 비코드 작업.** Code work is anything that changes what ships
(source, tests, config, build). Non-code work is everything else the continuity docs track — docs, an
issue draft, a roadmap edit, a release or external-communication step. The presentation split is what
carries the real payload to step 4 — that's where it's read to judge reversibility — so a bucket with
nothing in it just reads "None" rather than being dropped.

**`## Next` empty → say so and recommend `/iyu:backlog-discover`.** Same closing move `run-cycle`'s
End-of-Run Report makes when a run ends on `FRONTIER-EXHAUSTED:` with budget left: an empty backlog
isn't this skill's gap to fill — step 3's synthesis reorders and extends what's already scoped, it
does not discover unscoped work from nothing (rule 9) — it's a pointer to the skill that does. A
pointer only: name the recommendation, do not invoke it. Only say this when `## Next` itself is empty;
an empty `## Waiting on you` with items still in `## Next` is step 4's good outcome, not this one.

### 4. Brief what needs deciding

Two sources feed this step: handoff's `## Waiting on you` entries, and the reorder / prerequisite /
objection proposals step 3 raised. A proposal from step 3 is decision-class the moment it changes what
ships or in what order — apply the same handling to both sources; where a decision came from doesn't
change how it's handled.

For each entry in `## Waiting on you`, and each step-3 proposal that rises to decision-class:

- **Resource-blocked** (blocker · tried · unblocks) — re-run the self-unblock check (the same
  "Self-unblock before parking" logic `run-cycle` applies): is the resource *actually* still missing?
  Time has passed since it was parked. Still blocked → present as-is. Resolved → say so and drop it.
- **Decision-class** (a one-line flag, unbriefed) — brief it now, in full, per
  [decision-briefing.md §2](${CLAUDE_SKILL_DIR}/../_shared/decision-briefing.md): the decision in one
  line, **at least two grounded options** (feasibility and cost from what you just read in step 2, or
  from the grounding pass below — never invented), the **cross-lens read**
  ([decision-lenses.md](${CLAUDE_SKILL_DIR}/../_shared/decision-lenses.md), only the lenses that
  separate the leading options), and a **named recommendation** with what it locks in.
  **The recommendation is not optional — run the grounding pass below before ever leaving it empty.**
  **Judge reversibility by the step-3 split.** A code decision reverses through the ordinary channel
  (git revert / edit again) — most read L1 once a recommendation exists. A non-code decision is
  reversible only if undoing it costs nothing beyond editing a doc; anything the central policy
  already gates on a human — `git push`, registering a GitHub issue, a major-version bump,
  publish/release — stays L2 no matter how confident the recommendation is, because reversing it means
  undoing an action outside this repo, not editing a file in it.
  **Recommendable + reversible → do not brief it as a decision.** Decide it yourself, proceed, and
  record it in step 5 as a self-made choice instead (decision-briefing.md's guard). **Surface it
  anyway** — one line alongside the briefing, decision · trade-off · **to correct: <the reverse
  action>**, the same shape `run-cycle`'s End-of-Run Report part 3 uses for its Decisions Ledger. This
  is confirm-not-approval: say it, record it (step 5), and move on — do not wait on a reply the way a
  decision-class entry does (rule 3 is unaffected, only 다른점 있는지 gets a look).

**Grounding pass — settle the unknown instead of reporting it.** A briefing whose recommendation slot
reads "cannot recommend" hands the investigation back to the person with the least context on it,
which is the one thing `decision-briefing.md` exists to prevent. So when a recommendation does not
form on the first pass, close the gap before writing the briefing:

- **Name the one unknown that separates the leading options.** Not everything unknown about the
  decision — the single thing whose answer would move the pick. If nothing would, there is no gap and
  the recommendation was already available.
- **Settle it, bounded (~5 min per decision-class entry)** — the same bound `run-cycle` puts on its
  self-unblock check, and for the same reason: an unbounded check is how a session-opener turns into
  a research session. Read the file, the test, the dependents, the dependency's actual source; run
  the cheap command rather than naming it; `WebSearch`/`WebFetch` an ecosystem convention or a
  library's real behavior; read
  [philosophy-alignment-guide.md](${CLAUDE_SKILL_DIR}/../mindset/references/philosophy-alignment-guide.md)
  plus CLAUDE.md/README when what's missing is the project's own criterion.
- **Then recommend on what you found** — and when the missing piece was the project's *criterion*
  (cause (c)), recommend the criterion itself alongside the option it implies. See
  [decision-lenses.md](${CLAUDE_SKILL_DIR}/../_shared/decision-lenses.md)'s cause table: (b) and (c)
  end in a recommendation, and **(a) — an irreducible value conflict — is the only case that does
  not**, reachable only once (b) and (c) are ruled out.
- **If the bounded search came back empty, say what you searched**, not only what is still unknown.
  That is a finding; "unknown" alone is not.

This does not widen the skill (rule 9). Grounding a decision that is *already on the table* is
judgment over known work — the same category as step 3's reordering. Scoping work nobody has
identified yet is still `/iyu:backlog-discover`'s job.

Nothing flagged and no step-3 proposal rose to decision-class → say "None" and move straight to
confirming In flight / Next. Do not manufacture a decision to fill the section.

### 5. Wait, then record immediately

Unlike `/iyu:handoff` and `/iyu:run-cycle`, this skill's entire point is to pause here — present the
briefing, then wait for the human's pick on every decision-class entry (silence is not consent). A
step-4 self-made choice does not wait — it was already decided and surfaced; write it in immediately,
the same as a decision-class answer.

The moment an answer lands (or a self-made choice was surfaced), write it into
`<root>/HANDOFF.md`'s `## Decided this session` section (create the section if absent) in the same
shape `/iyu:handoff` uses: decision · trade-off · **to correct: <the reverse action>**. This covers
both sources — a handoff decision answered, and a step-3 reorder/prerequisite/objection confirmed. Do
this now, not at the next `/iyu:handoff` — that is the entire reason this step exists separately from
the briefing itself.

**A reorder is also applied to `## Next` itself, in the same edit — whether the human confirmed it
or step 4 self-decided it.** Rewrite that section
into the agreed order (keeping the 코드/비코드 split), and mark the entry in
`## Decided this session` as already applied. A self-decided reorder is the common case, not the
exception — leaving *those* recorded-but-unapplied would reopen the window this step exists to close.
Recording the decision without applying it leaves
`HANDOFF.md` asserting an order the same file has just been told is wrong — and
[continuity-docs.md §2](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) makes `## Next` the
authoritative statement of what comes next, which is what `/iyu:run-cycle` Preparation reads as its
opening scope. A decision recorded only in prose is one a later session can start without ever
seeing.

**`ROADMAP.md` is still not this skill's to write (rule 1).** Phase-level order stays
`/iyu:handoff`'s: when it next runs it reads `## Decided this session` as an inherited fact (its step
2) and carries the reorder into `ROADMAP.md`. An entry marked applied means applied *to `## Next`* —
`/iyu:handoff` still has to apply it to `ROADMAP.md`, and should not re-apply it to `## Next`.

### 6. Stop — hand off, don't execute

Once In flight / Next is confirmed (including any step 3 proposals) and every decision-class entry is
answered or explicitly deferred, the session-opening work is done. **This skill does not proceed into
implementation from here.** Present the settled scope — what's in flight, what's next in the
(possibly reordered) sequence, and what got decided — as the deliverable, and stop. Starting the work
is a separate, explicit act: the human instructs it directly in this same conversation, or
`/iyu:run-cycle` is invoked to actually execute. A confirmed scope is not that instruction, and this
skill never supplies it on its own.

## Rules

1. **`HANDOFF.md` is the only file this skill writes.** It never migrates `ROADMAP.md` →
   `HISTORY.md`, never touches `ROADMAP.md` at all, and never runs `/iyu:handoff`'s hygiene pass.
   Inside `HANDOFF.md` it writes exactly two things (step 5): the `## Decided this session` entry,
   and — when a reorder was confirmed — the `## Next` order that entry decides. Phase-level order in
   `ROADMAP.md` stays `/iyu:handoff`'s to apply.
2. **Ground options and proposals in what was actually read or run.** A step-3 reorder or
   prerequisite needs a stated reason grounded in step 2's read, not a hunch. An unknown that
   *separates the leading options* is **settled by step 4's grounding pass**, not reported as
   unknown — run the command instead of naming it. Only an unknown that survives that bounded pass
   stays "unknown", and it is reported together with what was searched.
3. **Silence is not consent.** A decision-class entry waits for an answer; do not proceed on the
   recommendation without one.
4. **"None" is a complete outcome.** If nothing was flagged and step 3 raised no proposal, say so — it
   is the good result, not a gap to fill.
5. **Never starts the work itself.** Step 6 ends the skill at a settled, confirmed scope —
   implementation begins only on a separate explicit instruction or `/iyu:run-cycle`, never
   automatically once decisions are answered. Reading, running a cheap command, or searching to
   ground a proposal or an option is not starting the work; nothing past step 6 is this skill's job.
6. **Model-invoked runs announce first.** Same as `/iyu:handoff` rule 7 — say in one line that a
   resume is running and why, before touching any file.
7. **Code vs non-code splits both presentation and the reversibility read.** Step 3 shows In
   flight/Next as 코드 작업 / 비코드 작업; step 4 reuses that split for its L1/L2 judgment — a code
   decision defaults toward self-decide once a recommendation exists, while a non-code decision that
   touches an action central policy already gates on a human (push, GitHub issue registration, a
   major-version bump, publish/release) stays briefed no matter how confident the recommendation is.
8. **An empty `## Next` gets a pointer, not an invocation.** Recommend `/iyu:backlog-discover` by
   name and stop there — resume does not call it, the same non-merging boundary `run-cycle`'s closing
   line keeps toward the same skill.
9. **Synthesis is judgment over known work, not discovery of new work.** Step 3's reordering,
   prerequisite-derivation, and objections operate on what the continuity docs and current repo state
   already contain. **The boundary is what the work is aimed at, not whether reading or searching
   happens** — step 4's grounding pass may read files, run cheap commands, and search the web to
   settle a decision *already on the table*, and that is still judgment over known work. Scoping work
   nobody has identified yet stays `/iyu:backlog-discover`'s job (rule 8's pointer) — resume
   recommends it, it does not attempt it.
