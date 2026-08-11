---
name: run-cycle
description: Executes adaptive iterative development cycles — each cycle is a self-contained plan/execute/verify/reflect loop that reshapes the roadmap and derives emergent follow-on scope from its own output
argument-hint: "[total_cycles]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
hooks:
  Stop:
    - hooks:
        - type: agent
          timeout: 180
          prompt: |
            Decide block/allow from durable on-disk state — the cycle logs ARE the state. Read them with your tools; do not rely on conversation memory, on the hook input alone, or on re-deriving the plan.
            Hook input (JSON): $ARGUMENTS — use its `cwd` as the search root. It does NOT carry the run's cycle budget; step 1 reads that from the logs.
            0. Resolve the log directory from disk — do NOT assume a literal path. Glob `**/cycle-logs/cycle-*.md` (skip `node_modules`, `.git`, build output). Exactly one `cycle-logs/` (commonly `claudedocs/cycle-logs/`) — use it. Several (an umbrella repo tracking several submodules) — take the one holding the most recently modified `cycle-*.md`; that is the run writing now. Every path below is relative to that ONE directory; mixing in a sibling submodule's logs corrupts the count in step 1. **No match at all** — the run has not written cycle 1 yet: treat cycles completed as 0, treat the latest/previous log as absent in steps 2–2b, and continue to step 3 (with no log there is no frontier token, so step 3 blocks — a run that stopped before its first log is never a valid stop). Do NOT allow merely because no directory resolved.
            1. List `cycle-*.md` in the resolved directory and read the **highest-indexed** one's header (`Budget:` / `Start:` / `Status:`). Every log this skill writes carries them from the moment its cycle starts, and they are the only place the hook can learn this run's budget — the hook input carries no invocation arguments. **Cycles completed = logs whose index is >= `Start:` AND whose `Status:` is `complete`** — not the raw file count, and never counting the in-progress log of the cycle running now. One state is NOT budget exhaustion: the newest log has **no `Budget:`/`Start:` header at all**. Such a log predates this scheme, so it belongs to an earlier run and this run has written nothing yet — treat cycles completed as 0 and continue to step 3 (which blocks, since there is no frontier token for this run). Do NOT extend that to a headered, `complete` log at its own budget ceiling: from the hook's side that is indistinguishable from this run finishing cleanly, and blocking there would produce a run that can never end. The narrow window it leaves — a stop between Preparation's start and the stub write, in a repo whose previous run also filled its budget — fails toward allowing, which the user resolves by invoking again; the reverse failure they cannot escape.
            2. Read the latest cycle log. Distinguish TWO kinds of human blocker, they behave oppositely:
               - Run-fatal `HUMAN-NEEDED:` — a constitution conflict / structural invalidation that poisons ALL remaining work. This ends the run.
               - Item-level `BLOCKED-ITEM:` in the Blocked-on-Human ledger — one scope needs a credential or user-only decision, but other work is independent. This PARKS one scope; it does NOT end the run.
               Then note whether any UNBLOCKED autonomous work remains: an unblocked Next-Cycle Scope, an autonomous-eligible Emergent Next Capability, unstarted phase-backlog work not sitting in the ledger, unresolved actionable defects, or an actionable value-ladder signal.
            2a. Frontier token — search the latest log for these markers as literal strings (same way you search for `HUMAN-NEEDED:` / `BLOCKED-ITEM:`; they live in the Emergent Next Capability line, position within it is irrelevant). Exactly one must be present:
               - `FRONTIER-OPEN:` — a follow-on capability was derived; work remains.
               - `FRONTIER-EXHAUSTED:` — derivation ran across all three lenses and produced no autonomous-eligible candidate. Only this token permits the early-exhaustion allow path.
               NEITHER token present = derivation was skipped, which is never a valid reason to stop.
            2b. Ledger continuity check — also read the PREVIOUS cycle log. Both ledgers (Blocked-on-Human, Decisions) are carry-forward state: if the previous log carried an entry and the latest log neither carries it forward nor records its resolution, that entry was silently dropped. A dropped ledger entry makes the latest log an unreliable basis for terminating, so treat it as a log defect.
            3. Respond BLOCK if ALL hold: completed < total budget; no run-fatal `HUMAN-NEEDED:` was emitted; AND ( at least one UNBLOCKED autonomous candidate remains — any of the items in step 2 — OR neither frontier token from step 2a is present, i.e. emergent derivation was skipped — OR step 2b found a dropped ledger entry, in which case the block is to reconstruct it from the previous log ). An item-level `BLOCKED-ITEM:` / Blocked-on-Human entry is NEVER by itself a reason to allow stopping while other unblocked work exists — park it and keep going.
            4. Respond ALLOW if: completed >= total budget; OR a run-fatal `HUMAN-NEEDED:` was emitted; OR every remaining candidate is either done or parked in the Blocked-on-Human ledger (NO unblocked autonomous work remains anywhere) AND the latest log carries `FRONTIER-EXHAUSTED:` AND the value ladder exhausted ("lifecycle verified"). Before responding ALLOW on ANY of these paths, confirm a `RUN-SUMMARY-*.md` exists in the resolved directory covering this run — the End-of-Run Report is required on every termination path. If it is missing, respond BLOCK with "generate the End-of-Run Report first"; that block is satisfied by writing the report.
            Guard: never BLOCK for MORE WORK once completed >= total budget — that is the hard ceiling. The single permitted block at or past the ceiling is the missing End-of-Run Report (step 4), which one turn of writing resolves. The healthy terminal state is "all remaining work is human-blocked or exhausted", NOT "the first human blocker was hit".
            Output contract — respond with JSON and nothing else: ALLOW is `{"ok": true, "reason": "<one line>"}`; BLOCK is `{"ok": false, "reason": "<what to do next — this text becomes the run's next instruction>"}`. "BLOCK"/"ALLOW" above name the two decisions; `ok` is how you report them.
---

# Development Cycle Runner

Execute iterative development cycles. Each cycle is a **self-contained micro-loop** — re-plan, design (if needed), execute, verify, reflect, derive-next. The roadmap is a **phase backlog, not a cycle plan**: only the current cycle is scoped concretely, and each cycle's outcome decides the next cycle's scope. Earlier cycles reshape the backlog based on what they reveal.

Two rules follow from that, and they are the ones runs actually break:

- **The roadmap must not know cycle numbers.** Concrete scope exists for one cycle — this one.
  Everything beyond it is a phase-level direction.
- **STEP 5 must actively derive** what this cycle's output implies next, across the
  user/developer/operator lenses, and gate each candidate autonomous-eligible vs. discussion.
  Skipping this is the early-termination failure users feel as "it only did the initial plan".

Why — the failure modes behind both, the L0–L3 rationale, and the unscoped-`Bash` decision:
**[references/design-rationale.md](${CLAUDE_SKILL_DIR}/references/design-rationale.md)**.

## Durable state over conversation memory

**The cycle logs ARE the memory.** Native context can be compacted mid-run, so a cycle must never
depend on remembering earlier cycles from conversation. Every cycle reconstructs its state from
on-disk artifacts (previous `cycle-*.md`, `ROADMAP.md`, git log). Write logs richly enough that a
fresh context could resume from them with zero conversational history.

## Continuity root — where that durable state lives

**[continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) is the definition** — §1
for resolving the root and what lives in it, §2 for what belongs in each document, §5 for the
language logs and reports are written in. `handoff`, `backlog-discover`, and `telemetry-az` read the
same file, which is what keeps all four landing in one directory. Do not restate those rules here; a
second copy drifts.

Run-specific on top of it:

- Resolve `<root>` **once, in Preparation**, before reading or writing anything.
- This skill owns two artifacts in it: `<root>/cycle-logs/cycle-{NN}.md` and
  `<root>/cycle-logs/RUN-SUMMARY-{YYYY-MM-DD}.md`.
- **Record the resolved root in each cycle log header**, so a fresh context picks it up without
  re-deriving it — and so the Stop hook, which has no session context, reads the same one.

## Parameters

**One parameter: the cycle budget.** `$0` = total cycles (default: **10**). Anything else in
`$ARGUMENTS`, and anything the user wrote alongside the invocation, is **scope context** — it feeds
Preparation step 1, not a flag parser. There are no flags: a run always executes, and always commits.

**The starting cycle number is derived, not passed.** Preparation reads the existing
`<root>/cycle-logs/cycle-*.md`, takes the highest index, and starts at *that + 1* (1 when none
exist). The repo already knows where the last run stopped; asking the caller to restate it only
creates a way to get it wrong.

**Record both in every cycle log header** (`Budget:` / `Start:` — see Cycle Log). The Stop hook has
no session context and receives no invocation arguments, so the logs are the only place it can read
them; omit the lines and it falls back to a default budget and may allow a stop early.

**`N` is a ceiling, not a target.** It bounds how many cycles *may* run — it is not a quota of scopes to fill in advance. Do not pre-partition `N` into `N` scopes. If the roadmap runs dry before `N`, terminate early (see Surplus-Cycle Value Ladder). If more work surfaces than `N` can hold, stop at `N` and carry the rest forward. The right mental model is "I have up to `N` turns," never "I must plan `N` things now."

---

## Preparation (light)

The preparation phase is **thin by design**. Deep analysis belongs to each cycle's STEP 1, where it can be informed by what's actually happening.

### 0. Resolve the continuity root

Apply the resolution rule in **Continuity root** above. Every `<root>/…` path in the rest of this skill is relative to what you resolve here — resolve it before reading or writing anything.

**One-time migration, here and nowhere else**: if resolution found a continuity doc (`ROADMAP.md` / `HANDOFF.md` / `HISTORY.md`) sitting *inside* `cycle-logs/`, move it up to `<root>/` now and note the move in this cycle's Roadmap Revisions. Resolution is what discovers the misplacement, so it is also what corrects it — re-checking every cycle would buy nothing.

### 1. Conversation Context (highest priority)

Check the preceding conversation for scope — explicit tasks, agreed-upon next steps, "continue with..." statements.

Also absorb **corrections to prior self-decisions**: if the human has said an earlier L1 decision was wrong (in this conversation or a prior run's report), capture it now and write it durably into the Decisions Ledger (status → `reverted`) so STEP 0 acts on it and a compaction cannot lose it. Conversation is the fastest channel; the ledger is what makes the correction survive.

### 2. Previous Cycle Logs

```bash
Glob: <root>/cycle-logs/cycle-*.md
```

Review the most recent log's **Carry-Forward** and **Roadmap Revisions** sections. These are inherited obligations and prior re-planning decisions.

**Derive this run's starting cycle number here**: highest existing `cycle-{NN}` index + 1, or 1 if
none exist.

**Then immediately open the first cycle log as a stub** — `<root>/cycle-logs/cycle-{Start}.md`
containing only the header (`Date` / `Root` / `Budget` / `Start` / `Status: in-progress`), before any
cycle work begins. This is not bookkeeping: the Stop hook gets no invocation arguments and can only
learn this run's budget from a log *this run wrote*. Without the stub, a stop in the window before
the first cycle completes leaves the hook reading the **previous** run's log — whose count is
already at or past its own budget — and it would allow the run to end having done nothing. Each
cycle flips its own `Status` to `complete` when its log is finished (STEP 5), and the hook counts
only completed logs.

### 3. Plan Discovery (only if no scope from above)

Stop at first found: CLAUDE.md → AGENTS.md → **`<root>/HANDOFF.md`** → `<root>/ROADMAP.md` (the resolved root from step 0 — the *same* file STEP 5 would create, never a differently-located one) / TASKS.md / TODO.md → docs/ → README.md. If nothing found, ask the user. Do not invent scope.

**`HANDOFF.md` outranks `ROADMAP.md` here, deliberately.** The handoff's "Next" section is the last
session's considered judgment about what to do now, made with knowledge of what it just finished;
the roadmap is phase-level direction that has not been narrowed to a session. When both exist, the
handoff *is* this run's opening scope and the roadmap tells you where it sits. `/iyu:handoff` writes
that section — the two skills meet here.

### 4. Philosophy Alignment (high-level only)

Evaluate the overall goal — not every future cycle — against CLAUDE.md / README.md, using the **four canonical dimensions** of [philosophy-alignment-guide.md](${CLAUDE_SKILL_DIR}/../mindset/references/philosophy-alignment-guide.md) (Core Mission Fit · Scope Alignment · Pattern Consistency · User Base Impact). That guide is the single definition of "the four dimensions" across this plugin — `issue`, `pr`, and `backlog-discover` score against the same four, so do not maintain a divergent set here.

One **run-specific** check rides alongside them, and it is not one of the four: **Dependency Direction** — no upstream→downstream leakage (a consuming project's domain concept must not be pushed into a library it consumes).

Reject scope items that score low **at the overall level**. Per-cycle drift checks (STEP 0) catch localized issues later.

### 5. Phase Backlog (not a cycle plan)

Create `<root>/ROADMAP.md` if step 3 found none (`<root>` from step 0 — if the repo already keeps a roadmap, that one *is* the backlog; do not create a second). It holds **phase-level directions only** — a backlog of goals, not an itinerary of cycles:

- Group work as **phases / goals**, each revisable by per-cycle Derive-Next
- Include known unknowns and investigation needs, not presumed answers
- `ROADMAP.md` holds **remaining** work only — completed phases live in `HISTORY.md` (see Continuity-Doc Hygiene)

**Hard rule — the roadmap must not know cycle numbers.** Do NOT produce a `Cycle 1 = …, Cycle 2 = …` table, and do NOT assign scope to any cycle beyond the first. You cannot know what Cycle 2+ should contain — that is decided by the preceding cycle's STEP 5, by design. A cycle-numbered scope table here is the single failure this skill exists to prevent.

Then scope **only the first cycle of this run**: pick the one most valuable phase to start, and leave the rest of the backlog as undated phases.

---

## Per-Cycle Process

Every cycle runs these six steps in order. Steps are **differentiated by weight** — STEP 0 is always light, STEP 1 runs only when triggered, STEP 4 reflection is always mandatory.

### STEP 0: Re-plan (always, light)

The first thing any cycle does is check whether the plan it inherited is still correct. Open this
cycle's log stub first (header only, `Status: in-progress`) — Preparation already opened the run's
first one; every later cycle opens its own here.

**Scope exactly one cycle — this one.** STEP 0 decides what *this* cycle does, nothing further. Do not lay out cycle 2, 3, … N here: the first cycle is not a planning summit for the whole run, and a cycle-numbered table is forbidden (rule 5). The next cycle's scope is produced by *this* cycle's STEP 5, once you know what this cycle revealed.

**Bounded inputs** (keep this cheap — target <5 minutes):

- Previous cycle's Carry-Forward + Next-Cycle Scope + Roadmap Revisions
- The phase backlog (`ROADMAP.md`) — for direction only, to pick *this* cycle's scope from
- Any changes to CLAUDE.md / README.md since the last cycle (diff only, not full re-read)

**Decisions**:

1. **Re-check the Blocked-on-Human ledger first** — for each parked `BLOCKED-ITEM`, ask "is the blocker now resolved (credential provided, decision made)?" If yes, un-park it — it becomes an eligible candidate again. If still blocked, it stays parked and is skipped as scope this cycle.
2. **Absorb corrections to prior self-decisions** — check the Decisions Ledger (and the preceding conversation) for any `provisional` L1 decision the human has marked `reverted` or asked to change. For each, re-open it as **new scope this cycle, re-evaluated together with whatever was built on top of it** — do not merely swap in the opposite option, since later work may depend on the original choice; treat dependents as part of the scope. A correction given only in conversation must be written into the ledger (status → `reverted`) before acting, so a compaction cannot lose it.
3. **Inherited defects first** — if previous Carry-Forward contains actionable items, they are this cycle's priority scope
4. **This-cycle scope (skip blocked candidates)** — if no inherited next-step exists (e.g. Cycle 1), pick the single most valuable **unblocked** phase from the backlog and scope only it. If the inherited Next-Cycle Scope is itself blocked (needs a credential / user-only decision), do NOT terminate — park it as a `BLOCKED-ITEM` and **fall through** to the next unblocked candidate (another backlog phase, a Carry-Forward defect, or an autonomous-eligible Emergent Next Capability). Only when *no* unblocked candidate exists anywhere does the run reach its terminal state (see rule 9).
5. **Drift check** — 1–2 sentence judgment: has anything in the project invalidated the inherited next step?
6. **Trigger check** — see below

**Output**: This cycle's scope only (an unblocked candidate), either as-inherited or adjusted.

### Trigger matrix

| Trigger | Signal | Action |
|---------|--------|--------|
| 🔴 HARD STOP *(run-fatal)* | Inherited plan conflicts with the project constitution (CLAUDE.md / philosophy / architecture), OR architecture change invalidates 3+ future cycles, OR critical dependency deprecated — a blocker that **poisons all remaining work** | **Constitutional conflict → amendment, not override**: name the conflict (planned scope *X* vs. constitution clause *Y*), then escalate with the two resolutions — revise the scope to fit, OR amend the governing doc (propose a concrete CLAUDE.md/design-doc diff). Log blocker in Carry-Forward, emit a single line `HUMAN-NEEDED: <one-line reason>`, then **generate the End-of-Run Report** (it must exist on this path too) and **terminate the whole run**. Reserve this for genuine structural invalidation — a merely-blocked single scope is 🔵 BLOCKED below, not HARD STOP. Do not silently proceed against the constitution, and do not unilaterally override it. |
| 🔵 BLOCKED *(item-level, does NOT terminate)* | *This* scope needs something only a human can supply — an external credential/dependency, or a product/API decision only the user can make — but the blocker is **local to this scope** and leaves other work workable | **Self-unblock first, then park — never terminate.** See "Self-unblock before parking" below: a blocker is only real once you have tried to resolve it yourself. What survives moves to the **Blocked-on-Human** ledger (Carry-Forward) with `BLOCKED-ITEM: <scope> — <one-line reason + what was already tried + what would unblock it>` (NOT `HUMAN-NEEDED`), then **fall through to the next unblocked candidate** — a backlog phase, a Carry-Forward defect, or an autonomous-eligible Emergent Next Capability — and continue the run. The run terminates on item-level blockers only when *every* remaining candidate is likewise blocked or exhausted (see termination rule 9). |
| 🟠 RE-PLAN | Roadmap order/split needs change, but overall goals remain valid | Adjust roadmap autonomously, record in **Roadmap Revisions** log section |
| 🟡 SCOPE ADJUST | This cycle's scope needs trimming or expansion only | Adjust inline, proceed to STEP 1 |
| ⚪ NONE | Plan still valid | Proceed with inherited scope |

HARD STOP is **deliberately narrow**: it kills the whole run, so it is only for structural invalidation that poisons all remaining work. **If in doubt between RE-PLAN and HARD STOP, choose RE-PLAN; between 🔵 BLOCKED-item and 🔴 HARD STOP, choose 🔵 BLOCKED** — ending the whole run on a *local* blocker while other work remains is precisely the early-termination failure this skill exists to prevent.

### Self-unblock before parking (mandatory precondition of 🔵 BLOCKED)

A capable delegate does not hand back a task the moment it looks blocked — they first check whether the thing they are waiting for is already available. Parking is only legitimate for a blocker that **survived an attempt to remove it**. Before writing any `BLOCKED-ITEM`, run this bounded (~5 min) check:

1. **Is the resource actually missing?** Look, don't assume — env vars, config files, existing fixtures/mocks, `gh auth status`, a local package source, an existing test double. "I would need X" is not evidence that X is absent (rule 7.5).
2. **Is the decision already made?** A "user-only decision" is not open if CLAUDE.md / README / an architecture doc / an accepted issue / a prior Decisions-Ledger entry already answers it. Follow the existing decision instead of re-asking it.
3. **Can a useful slice proceed?** Split the scope: implement and verify the part that does not touch the blocker (the logic behind an unavailable credential, the offline path, the interface plus a test double). Park only the residue, not the whole scope.
4. **Is it really L2?** If the "decision only the user can make" turns out reversible, it is **L1** — decide it, record it `provisional`, and keep going (in dubio, pro autonomy).

Record what was tried in the ledger entry. An entry that cannot say what was attempted is an *assumed* blocker, not a proven one — and assumed blockers are how a run stalls with budget left.

### Decision leveling (overlay on the constructs above)

Every decision a cycle faces sits at one of four levels, keyed on **stakes × reversibility** (two-way vs. one-way door) — escalate what is irreversible or theirs-alone, self-decide what is reversible. ([why](${CLAUDE_SKILL_DIR}/references/design-rationale.md))

| Level | Test (stakes × reversibility) | Handling | Maps to |
|-------|-------------------------------|----------|---------|
| **L0** | pure taste/convention, no real trade-off | decide silently, not reported | inline autonomy |
| **L1** | a real trade-off exists but the choice is **reversible** (two-way door) | pick the best option (five co-equal lenses, rule 2.5), **proceed now**, record `provisional` in the **Decisions Ledger** for later confirm/reverse | rule 2.5 + Decisions Ledger |
| **L2** | **irreversible / expensive to undo, or only a human can decide** — but other work is independent | park & batch, do not block the run | 🔵 BLOCKED-ITEM / Pending Human Decisions |
| **L3** | run-fatal: poisons all remaining work | escalate & terminate | 🔴 HARD STOP (`HUMAN-NEEDED:`) |

**In dubio, pro autonomy.** Ambiguous between **L1** and **L2** → **choose L1**: decide it, record it `provisional`, let the end-of-run report surface it for correction. Same bias as "if in doubt, choose RE-PLAN / choose 🔵 BLOCKED", one rung further. **The one exception:** if the five lenses *irreducibly conflict* — no option is defensible across them — that is itself an L2 signal; escalate rather than force a pick. L1 never gates termination.

### STEP 1: Design (conditional)

**Skip if ALL true** (and record "skipped — pattern-following change" in the log):

- Scope is an isolated, pattern-following change
- Identical patterns already exist in the codebase
- No new external dependencies or API changes
- No performance/security implications

**Otherwise**:

1. **Codebase survey** — trace call paths, map existing patterns and conventions
2. **External research** — WebSearch for best practices, library docs, known pitfalls. Do not guess.
3. **Approach decision** — if multiple viable approaches exist, compare trade-offs and pick one with a 1-line rationale

Record findings briefly in the cycle log. Do not pad this step when skip conditions hold.

### STEP 2: Execute

Implement the scope. Progress incrementally. **Inherited defects are fixed first**, before new roadmap work.

**Root cause mindset**: When problems surface, ask "why" until the real cause emerges. Fix all instances of a pattern, not just the symptom that triggered investigation.

### STEP 3: Verify

- **Define "done" before checking it** — restate this cycle's scope as concrete, checkable acceptance criteria (which test passes, which behavior holds, which output appears). Verify against *that*, not against a self-assessed "looks done".
- Run the project's test suite, linter, and build
- **Drive the real thing when the change is user-facing.** If the cycle touched UI, app flow, or CLI
  output, a green test suite is not the same as the feature working. Exercise it on its actual
  surface — a browser-automation MCP if the session has one, the CLI, the running service — and say
  what you observed. No such surface available: record "skipped — no runnable surface" and move on.
  Never add a dependency to satisfy this. STEP 4 asks you to judge user-facing quality; this is
  where you get the evidence to judge it with.
- **Evidence, not assertion** — completion is proven by actual command output (test/build results), never by claiming it works. The top failure mode of long-running agents is marking work complete without verifying it. If you cannot show the passing evidence, it is not done.
- On failure: **fix and re-run immediately** within this cycle — do not defer
- If a failure exposes a trigger-class issue (HARD STOP / RE-PLAN), loop back to STEP 0 rather than forcing progress

### STEP 4: Reflect & Evaluate (always, mandatory)

Objective quality review. This is the step that makes cycles cumulative rather than sequential.

**Perspective**: Evaluate as someone who didn't write this — a contributor, reviewer, or end user seeing the result for the first time. Internal consistency is necessary but not sufficient; external coherence is what reveals the issues an author cannot see.

Assess six dimensions:

1. **Scope fit**: Does the implementation meet the cycle's intent?
2. **Latent defects**: Bugs, unhandled edges, architecture violations in or around the changes
3. **Structural improvement opportunities**: Better patterns, refactoring candidates, orphan code/files/docs found during the cycle
4. **Philosophy drift**: Scope creep, library/application boundary leakage, pattern deviation
5. **Roadmap impact & emergent scope**: Two questions, not one. (a) Does this cycle's outcome change what *existing* phases should do? (b) What does the capability just built *naturally imply next* — the follow-on a user would expect, the case a developer sees left brittle, the safeguard an operator would demand? Capture both; (b) is the raw material STEP 5 turns into derived scope, and skipping it is what makes cycles terminate prematurely.
6. **User-facing quality** *(when changes touch UI, API contracts, CLI output, or app flow)*: Usability, interaction coherence, convention alignment, flow correctness relative to user mental models. Reference standards concisely when they anchor a finding objectively (e.g., "violates REST uniform interface", "missing affordance — Nielsen #1", "keyboard trap — WCAG 2.1.2").

**Defect vs. improvement distinction**:
- **Defects** (bugs, broken edges, violations) → fix before leaving STEP 4. Loop: discover → fix → re-verify.
- **Structural improvements** (better patterns, refactoring candidates) → do NOT fix silently; carry to STEP 5 as proposals for human decision.
- **Orphans** (unused code, unreferenced files, stale docs) → remove immediately, note in cycle log.

Only items requiring human judgment on defects are exempt from STEP 4 fixes (breaking API, major architecture, ambiguous scope).

### STEP 5: Derive Next

This step has two jobs: (a) record what cannot be resolved autonomously, and (b) **actively derive** the scope the cycle's own output now makes possible. (b) is the engine that prevents premature termination — never skip it because the roadmap "looks done".

- **Carry-Forward (actionable)**: Things to address next cycle
- **Emergent Next Capability (derive from multiple lenses, don't wait)**: The cycle's output is itself a source of scope. Derive candidates by asking, from each stakeholder lens, *"given what was just built, what does it naturally imply next?"*
  - **User lens** — what would a user now expect, want, or hit? (the missing case, the obvious convenience, the input that breaks it — e.g. after single-file upload: "an empty/oversized file crashes it", "the real workflow obviously needs several files", "drag-and-drop")
  - **Developer / maintainer lens** — does the new surface fit the project's **philosophy and boundaries**? what did it leave brittle, duplicated, or untested? (this lens also *vetoes* candidates that breach declared scope — see gate)
  - **Operator lens** — what does running this in production now require? (input validation, resource limits, an observability hook, an unhandled failure mode)

  Then classify **every** candidate through the **derivation gate** — this *is* the answer to "autonomous, or discussion?":
  - **Autonomous-eligible** (→ becomes a Next-Cycle Scope / value-ladder candidate) when ALL hold: its *absence would be felt as incompleteness or a defect*; it stays within the project's **declared role and established patterns**; and it carries **no real trade-off** (pattern-following, additive, low-risk).
  - **Discussion / proposal-only** (→ Structural Improvement Proposals or Pending Human Decisions; **never** taken as autonomous scope) when it opens a **new product direction**, introduces a **new interaction paradigm, dependency, or surface** the project has not committed to, or involves a **trade-off only a human / product owner should weigh**. Propose with rationale — do not self-decide.
  - Worked examples of both: [design-rationale.md](${CLAUDE_SKILL_DIR}/references/design-rationale.md).
  - **Frontier exhausted** — a valid, expected outcome: the capability is genuinely complete and any further extension would be scope creep or needs human direction.

  **Write the outcome as a token, not as prose.** The Emergent Next Capability line's **value** is one of exactly two markers — the Stop hook searches for them as literal strings, the same way it searches for `HUMAN-NEEDED:` and `BLOCKED-ITEM:`:
  - `FRONTIER-OPEN: <candidate> [autonomous|discussion]` — at least one follow-on was derived.
  - `FRONTIER-EXHAUSTED: <why, across all three lenses>` — derivation ran and produced no autonomous-eligible candidate. **Only this token permits early termination.**

  Neither token present means derivation was skipped, which is never a valid reason to stop.
- **Decisions Ledger (L1 self-decisions — persists and accumulates, does NOT terminate)**: Every reversible self-decision made this cycle that carried a *real trade-off* (rule 2.5, L1). Each entry: `id · decision · alternatives considered · the trade-off · cross-lens rationale · cost-to-reverse · status`. New entries start `provisional`. **Copy every unconfirmed entry forward** and re-check it at STEP 0 for human corrections (`reverted`). Unlike Blocked-on-Human, this ledger *never gates termination* — the run does not wait on confirmation; it proceeds on provisional decisions and lets the human confirm or reverse them after the fact (that after-the-fact surface is the End-of-Run Report). L0 taste-only choices are NOT recorded here.
- **Blocked-on-Human (ledger — persists and accumulates, does NOT terminate)**: Concrete scopes that hit an *item-level* blocker this cycle — a needed external credential/dependency, or a decision only the user can make — where the blocker is local to that scope and other work stays workable — and only after the **self-unblock check** failed to remove it. Each entry records the scope, the blocker, **what was already tried**, and **what would unblock it**. **Copy every unresolved entry forward to the next cycle** (like Carry-Forward defects) and re-check it at STEP 0. This ledger only grows; it never ends the run. The run terminates only when *every* remaining candidate is in this ledger (nothing unblocked left) or the frontier + ladder are exhausted. Distinct from Pending Human Decisions: those are advisory proposals; this is a *parked, un-runnable scope* that governs termination.
- **Structural Improvement Proposals**: Refactoring candidates and better patterns found in STEP 4 — with rationale and recommended approach. Human decides when/whether to act.
- **Pending Human Decisions**: Breaking API, major architecture, ambiguous scope, and every *discussion-class* emergent candidate above
- **Roadmap Revisions**: If STEP 4's roadmap-impact judgment said "yes" — record the change to `ROADMAP.md` (phase level) and log it
- **Release placement**: If the backlog carries a push/publish/release item, apply
  [release-cadence.md](${CLAUDE_SKILL_DIR}/../_shared/release-cadence.md) §2 and move it to the phase
  boundary it belongs to — remaining work that touches the same consumer-facing surface means the
  release goes *after* it, since publishing mid-phase buys a version the next few items obsolete and
  each pushed pipeline spends a shared CI budget. The outcome is a **reordered `ROADMAP.md`** with a
  one-line reason at the marker (§4), not a note. Log the move under Roadmap Revisions
- **Continuity-doc hygiene (every cycle, unconditional)**: Apply **Continuity-Doc Hygiene** (section below) — migrate every completed phase/item found in `ROADMAP.md` (and `HANDOFF.md`, if the project keeps one) to `HISTORY.md`, and keep the handoff current + next only. Runs even when nothing else in the roadmap changed.
- **Next-Cycle Scope**: This is where the next cycle is actually planned — concretely, for **one** cycle only. Draw it from three sources in priority order: (1) inherited / this-cycle Carry-Forward defects, (2) mid-cycle discoveries (a problem too large for this cycle, or one deserving its own), (3) the highest-value **autonomous-eligible Emergent Next Capability**. Only when all three are empty — feature frontier explicitly judged exhausted — does Next-Cycle Scope become "none", handing off to the value ladder. Do **not** scope cycle+2 and beyond — those stay phase-level in the backlog until their predecessor's STEP 5 reaches them.

**Do NOT carry forward defects that could have been fixed in STEP 4.** If you can fix it, fix it now.

**Close the log**: fill in every section above, then flip the header's `Status:` to `complete`. The
Stop hook counts completed logs only — a cycle whose log still says `in-progress` reads as the cycle
running now, which is exactly right while it is, and wrong the moment the cycle is actually done.

---

## Continuity-Doc Hygiene

Apply **[continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §3** in full at
every STEP 5 — migrate completed work out of `ROADMAP.md` into `HISTORY.md`, rewrite `HANDOFF.md` to
current + next, keep the `> History:` link, treat a still-long doc as a wrong-layer signal. `handoff`
runs the same pass; that is why it lives in one file.

Two things specific to running it inside a cycle: `HISTORY.md` entries carry this run's `(cycle-NN)`
as their reference, and hygiene **never gates termination** — it is doc upkeep inside STEP 5 and the
doc-sync floor, not a completion criterion, and it adds nothing to the Stop-hook logic.

---

## Cycle Log

Each cycle's log is **opened as a header-only stub when the cycle begins** and completed when it
ends — the first one in Preparation, every later one at the start of its own STEP 0. `Status:` flips
to `complete` only when the sections below are filled in; the Stop hook counts completed logs and
reads `Budget:`/`Start:` from the newest one, so a log that exists from the moment a cycle starts is
what keeps the hook anchored to *this* run.

`<root>/cycle-logs/cycle-{NN}.md`:

```markdown
# Cycle {NN}: {Title}
Date: {YYYY-MM-DD}
Root: {resolved continuity root, e.g. `claudedocs/`}
Budget: {total cycles N for this run}
Start: {starting cycle number for this run}
Status: {in-progress | complete}

## Re-plan
{Trigger detected (if any) and scope decision — or "Plan valid, inherited scope"}

## Scope & Implementation
{What was tackled, files changed, key design decisions}

## Verification & Defect Resolution
{Test/build status, defects discovered and resolved — or "No defects found"}

## Reflection
{Scope fit, philosophy drift, roadmap impact — evaluated from an external perspective. User-facing findings (if applicable): usability, flow, convention issues with standards reference.}

## Carry-Forward
- Actionable: {items for next cycle, or "None"}
- Decisions Ledger (L1 self-decisions): {reversible decisions made this cycle that carried a real trade-off — each with alternatives, the trade-off, cross-lens rationale, cost-to-reverse, status=provisional; carried forward until the human confirms/reverts, or "None". Non-terminating.}
- Blocked-on-Human (ledger): {parked scopes, each with blocker + what was already tried (self-unblock check) + what would unblock it — carried forward every cycle until resolved, or "None". These accumulate; they do NOT terminate the run.}
- Structural Improvement Proposals: {refactoring candidates with rationale, or "None"}
- Pending Human Decisions: {decisions needing human input + discussion-class emergent candidates, or "None"}
- Emergent Next Capability: `FRONTIER-OPEN:` {follow-on(s) derived across user/developer/operator lenses, each tagged autonomous / discussion} — OR — `FRONTIER-EXHAUSTED:` {why, across all three lenses}. {Exactly one marker, written verbatim: never blank, never untokenized prose — the Stop hook searches this log for the literal string.}
- Roadmap Revisions: {phase-level changes made to ROADMAP.md, plus completed items migrated to HISTORY.md, or "None"}
- Next-Cycle Scope: {concrete scope for the next single cycle — from Carry-Forward defects, mid-cycle discoveries, or the top autonomous-eligible Emergent Next Capability. "None" only when the frontier is explicitly exhausted. Do not scope further ahead.}
```

---

## Surplus-Cycle Value Ladder

When primary roadmap work finishes and cycles remain, a passionate maintainer does not down tools — they harden, document, and accelerate. Most agentic loops terminate the moment the task compiles; this skill instead treats the **remaining cycle budget as an investment fund for the full software lifecycle**.

This is the project-specific judgment a generic harness cannot supply, and it is our distinctive contribution — so it stays inside the minimal-intervention boundary: surplus cycles never exceed the requested budget `N`, never preempt defect resolution, and follow the same STEP 1→4 discipline (including "structural changes are proposals, not silent edits").

**Climb in order. Within each track, act only where the project shows a concrete gap (a signal) — do not invent work.**

| Track | Rungs (in order) | Signal that justifies a rung |
|-------|------------------|------------------------------|
| **① Main loop** *(always first)* | plan → execute → verify → cleanup | Open roadmap items, inherited Carry-Forward, **or an autonomous-eligible Emergent Next Capability (STEP 5)** remain |
| **② 내공 / Durable value** | research/learning capture → structural refactoring → documentation & asset-ization | Undocumented surface, drifted docs, repeated patterns begging extraction, lessons worth recording |
| **③ 방어선 / Stability** | test/coverage & monitoring gaps → security & compliance → error-handling & resilience | Untested critical path, missing input validation, unhandled failure mode, no observability hook |
| **④ 가속기 / Efficiency** | CI/DevOps/platform → DX improvements | Manual repetitive steps, slow/flaky pipeline, awkward local setup |

**Execution guard (keeps minimal-intervention intact):**
- **Additive & low-risk → do it** this cycle (doc-sync, filling a test gap, adding validation, a small CI fix). Run it through STEP 2→4 and log it as a `[ladder:②/③/④]` cycle.
- **Invasive or opinionated → propose in Derive-Next**, do not perform (large refactors, dependency swaps, new infra, security architecture). Human decides.
- **Regression back-flow** — if any surplus track surfaces a defect or regression, drop the surplus work and return to the main loop (track ①, STEP 2). Defects always outrank surplus value; resume climbing only once the regression is resolved.
- Track ② rung "documentation" is the floor: even when nothing else applies, a stale-doc sweep (README, `docs/`, CLAUDE.md, CHANGELOG, examples) plus the continuity-doc lean check (Continuity-Doc Hygiene) is always in-scope surplus work.

**Terminate early only when** the ladder surfaces no *unblocked* signal the remaining budget can act on, on top of the conditions in **rule 9(d)** — which is the normative home for the termination test; do not restate it here. Log which rungs were climbed and which were proposed.

## Execution Rules

1. **No interruptions within a cycle**: Decide autonomously. Do not ask for confirmation mid-cycle.
2. **HARD STOP (run-fatal) vs. item-level block — terminate only on run-fatal**: A **run-fatal HARD STOP** (constitution conflict / structural invalidation that poisons all remaining work) emits `HUMAN-NEEDED: <reason>`, generates the **End-of-Run Report** (required on this path too), then terminates the whole run — do not force progress. An **item-level blocker** (one scope needs a credential or a user-only decision, but other work is independent) emits `BLOCKED-ITEM: <scope> — <reason + what was tried>` after the self-unblock check and does **not** terminate; rule 9 governs what happens next.
2.5. **Option-question self-resolution (L0/L1)**: When a non-blocker decision has multiple reasonable options, do NOT ask the user — self-decide and proceed. Weigh the five **co-equal** lenses *together* (this is NOT a priority order): 근본/structural fit, 정석/balanced-canonical, 표준/convention, 세련/elegant-minimal, 철학/project-philosophy alignment — defined once in **[decision-lenses.md](${CLAUDE_SKILL_DIR}/../_shared/decision-lenses.md)**. Pick the option best across them as a whole. If the choice is pure taste with no real trade-off (**L0**), decide silently. If a real trade-off exists but the choice is reversible (**L1**), record it in the **Decisions Ledger** as `provisional` — decision, alternatives, the trade-off, the cross-lens rationale, and cost-to-reverse — so the End-of-Run Report can surface it for confirmation or correction; do not stop or wait on it. If the five lenses *irreducibly conflict* (no option is defensible across them), that is an escalation signal — treat it as L2 (Pending Human Decision), not a forced pick. Reserve `HUMAN-NEEDED:` (whole-run terminate) for **run-fatal** blockers only — an unrecoverable error or a structure-invalidating change that poisons all remaining work. A **required external credential/dependency, or a decision only the user can make, that blocks just this scope** is an item-level `BLOCKED-ITEM:` — park it and keep the run going on other work; it contributes to termination only when it is the *last* unblocked candidate.
3. **Fix what you find**: STEP 4 **defects** (bugs, broken edges) MUST be resolved in the same cycle. **Structural improvements** go to Carry-Forward as proposals — do not refactor silently. **Orphans** (unused code, stale docs) are removed immediately and noted in the log.
4. **Inherited defects first**: Previous Carry-Forward actionables are mandatory at STEP 0.
5. **Roadmap is a phase backlog, not a cycle plan**: It holds phase-level directions only — never a cycle-numbered scope table. Concrete scope exists for one cycle at a time (this one); the next cycle is scoped by this cycle's STEP 5. Revise the backlog when evidence requires and log revisions explicitly.
6. **Quality over scope**: Reduce new scope if needed — never reduce defect resolution or reflection depth.
7. **Research actively**: WebSearch before guessing. Record sources.
7.5. **No invention**: Data you did not directly observe (a command's output, a file's contents, a test result) stays "unknown" — never present a guess as fact. When something is unknown and matters, state it and take the step that would observe it rather than assuming.
8. **Defect honesty**: Record issues openly. "It works" ≠ "It's good".
9. **No idle early stop — park blockers, push unblocked work, quit last** *(normative home for the termination test — the trigger matrix, rule 2, and the value ladder all defer here)*: While cycles remain, termination is the last resort, reached in this order. (a) **Emergent derivation (STEP 5)** — derive the natural next capability from what you just built, across the user/developer/operator lenses; if a candidate passes the derivation gate, write `FRONTIER-OPEN:` and that *is* the next cycle (main loop, track ①). (b) Only once the log carries `FRONTIER-EXHAUSTED:` do you climb the **Surplus-Cycle Value Ladder** (durable value → stability → efficiency), acting where the project shows a concrete signal; doc-sync (README, `docs/`, CLAUDE.md, CHANGELOG, examples) is its always-applicable floor. (c) **Item-level human blockers never terminate the run** — park each `BLOCKED-ITEM` in the Blocked-on-Human ledger, carry it forward, and keep pushing every *unblocked* candidate (backlog phase, Carry-Forward defect, autonomous emergent capability, ladder signal). (d) Terminate early only once **no unblocked autonomous work remains anywhere** — every backlog phase, Carry-Forward item, autonomous-eligible emergent capability, and ladder signal is either done or parked in the ledger — AND the log carries `FRONTIER-EXHAUSTED:` AND the ladder surfaces no actionable *unblocked* signal. Log that judgment (and the full ledger of parked blockers) explicitly, and generate the **End-of-Run Report** before terminating. Throughout: additive/low-risk work is done in-cycle (STEP 2→4); invasive/opinionated or discussion-class work is proposed in Derive-Next, never self-decided.
10. **Continuity chain**: Always read the previous cycle's Carry-Forward, Next-Cycle Scope, and Roadmap Revisions before STEP 0. The previous cycle's Next-Cycle Scope is this cycle's starting scope.
11. **Latent work priority**: The best cycles surface structural improvements nobody thought to ask about — propose them in Derive-Next with rationale. Do not fold them silently into scope.
12. **Cost discipline**: STEP 0 is bounded (~5 min). If drift check seems to require deep analysis, that is a RE-PLAN signal — handle it explicitly rather than letting STEP 0 bloat.

## End-of-Run Report

At run end — on **every** termination path (budget reached, HARD STOP, or early exhaustion) — synthesize one **report to the human** before the final commit. This is the "delegate reports back to their manager" moment: what got done, what was decided autonomously and can still be corrected, and what was escalated because it was not the delegate's to decide. Write it to `<root>/cycle-logs/RUN-SUMMARY-{YYYY-MM-DD}.md` (a run-level artifact, distinct from per-cycle logs — beside them so the Stop hook finds it in the directory it already resolved) **and** surface the same three parts in the final chat response. It is unconditional — a run has no mode in which the report is skipped.

Three parts — draw them straight from the ledgers the cycles already maintained; this is a report, not a re-derivation:

1. **Progress / achievements** — what shipped this run, with STEP 3 evidence (test counts, build/lint result). Assertions are not evidence (rule 7.5).
2. **Deferred decisions (L2 — escalated, awaiting you)** — the Pending Human Decisions plus the full Blocked-on-Human ledger. Present them per **[decision-briefing.md](${CLAUDE_SKILL_DIR}/../_shared/decision-briefing.md)**: a *resource-blocked* entry keeps the short blocked · what-was-tried · what-would-unblock form (§1), while a *decision-class* entry is **briefed** (§2) — the decision in one line, ≥2 observed options (one usually "defer"), the cross-lens read of how the leading ones differ, and a named recommendation with **what it locks in**. These are the decisions the run did not make because they were irreversible or yours alone; handing them over as bare questions puts the analysis back on the person furthest from the work. This is a *report-time* synthesis of ledgers that already exist — the per-cycle `BLOCKED-ITEM:` entry format is unchanged (§3), since those entries govern termination and must stay cheap to write. Nothing to defer is a valid and good outcome: write "None" rather than promoting an L1 decision to fill the section.
3. **Self-made decisions (L1 — done, reversible, confirm or correct)** — the Decisions Ledger: each `provisional` decision with its trade-off and a one-line **"to correct: <the reverse action>"**. The human confirms (→ `confirmed`) or reverts (→ `reverted`, picked up by next run's STEP 0). Presenting these — not hiding them — is what makes proceed-first-correct-later safe.

One closing line, **only when the run ended on `FRONTIER-EXHAUSTED:` with budget still unspent**: the run stopped because the backlog is dry, not because the budget ran out — recommend running `/iyu:backlog-discover` to refill it before the next run. This is a pointer for the human, not an invocation: the two skills stay independent (`run-cycle` only consumes `ROADMAP.md`, `backlog-discover` only feeds it), and nothing here merges anything.

If a `RUN-SUMMARY-{date}.md` already exists (a resumed or same-day run), append a new run block rather than overwriting. `TREND.md`-style indexing is out of scope — one file per day is enough.

## Commit

Before the single end-of-run commit, run a **lightweight release-readiness check**. It *verifies and packages* — it never performs a release.

**Checklist** (items the project lacks are N/A — skip them, do not invent them):

1. **Version consistency** — if any version-bearing file changed this run, confirm all agree (e.g. `plugin.json`, `marketplace.json`, README badges, package manifest, intended tag). A mismatch is a defect: fix it before committing.
2. **Changelog** — if the project keeps a CHANGELOG / release notes, confirm this run's changes are recorded. A missing entry is additive/low-risk: add it now.
3. **Docs** — confirm the doc-sync floor (ladder ②) ran and reported consistent, and that continuity docs are lean (no completed items left in `ROADMAP.md`/`HANDOFF.md`; completed work indexed in `HISTORY.md`); do not re-run the sweep here.
4. **Evidence** — package the actual STEP 3 verification output (test counts, build result, lint status). Assertions are not evidence (rule 7.5); if you cannot show the output, it is not verified.

Record the outcome as a `## Release Readiness` block in the final cycle log:

```markdown
## Release Readiness
- Version: {all version files agree at X.Y.Z, or "n/a"}
- Changelog: {entry present for this run, or "n/a"}
- Docs: {doc-sync verified consistent; continuity docs lean}
- Evidence: {e.g. `npm test` 142 passed; build ok; lint clean}
- Tag/publish: deferred to human/CI (not performed)
```

Then:

- Generate the **End-of-Run Report** (above) first — it is the run's report-to-human and must exist before the code is committed
- **Commit boundary — default once per run, split only when the single diff stops being reviewable.** One commit after all cycles complete (or on HARD STOP / early termination) is the default, and it is the right default: the governing policy is anti-fragmentation (bundle into logical units; do not let commit count balloon). But a long run collapses many verified states into one unreviewable diff with **no rollback boundary between cycles** — a regression introduced in cycle K and caught in K+3 has no commit edge to revert to. So when the run is long enough that a reader could not review the diff in one pass, split on **verified-cycle boundaries** (each cycle's passing STEP 3 is already a clean point), grouping inseparable cycles together. Never split below a verified cycle, and never commit an unverified state
- Commit with `git` directly, following the project's message convention. If the session has a
  commit skill available (`/commit` ships in some plugin sets, not in Claude Code itself), use it
  instead of hand-rolling the message
- **Do NOT perform the release** — no tagging, publishing, or pushing. A run ends at a commit; taking
  the work out is a separate, human-initiated decision (`/iyu:ship`, or the project's own path)
  because pushing spends CI budget and publishing cannot be undone. If the run left the project at a
  point worth releasing, say so in the End-of-Run Report and stop there
- **NEVER bump MAJOR version**

## Start

Begin: Preparation → the first cycle of this run (derived index) → the next → … until the budget `N`
is spent, or HARD STOP / early termination.
