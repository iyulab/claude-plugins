---
name: run-cycle
description: Executes adaptive iterative development cycles — each cycle is a self-contained plan/execute/verify/reflect loop that reshapes the roadmap and derives emergent follow-on scope from its own output
argument-hint: "[total_cycles] [start_cycle]" [--dry-run] [--no-commit]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, TodoWrite, WebFetch, WebSearch, Bash
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Decide block/allow from durable on-disk state — the cycle logs ARE the state. Do not rely on conversation memory or re-derive the plan.
            Invocation arguments: $ARGUMENTS (total cycle budget, optional start cycle).
            1. List claudedocs/cycle-logs/cycle-*.md — the count is cycles completed.
            2. Read the latest cycle log. Distinguish TWO kinds of human blocker, they behave oppositely:
               - Run-fatal `HUMAN-NEEDED:` — a constitution conflict / structural invalidation that poisons ALL remaining work. This ends the run.
               - Item-level `BLOCKED-ITEM:` in the Blocked-on-Human ledger — one scope needs a credential or user-only decision, but other work is independent. This PARKS one scope; it does NOT end the run.
               Then note whether any UNBLOCKED autonomous work remains: an unblocked Next-Cycle Scope, an autonomous-eligible Emergent Next Capability, unstarted phase-backlog work not sitting in the ledger, unresolved actionable defects, or an actionable value-ladder signal — and whether the feature frontier was explicitly judged exhausted or left blank (blank = derivation skipped, never a valid stop).
            3. Respond BLOCK if ALL hold: completed < total budget; no run-fatal `HUMAN-NEEDED:` was emitted; AND ( at least one UNBLOCKED autonomous candidate remains — any of the items in step 2 — OR the latest log left the feature frontier neither named nor explicitly judged exhausted, i.e. emergent derivation was skipped ). An item-level `BLOCKED-ITEM:` / Blocked-on-Human entry is NEVER by itself a reason to allow stopping while other unblocked work exists — park it and keep going.
            4. Respond ALLOW if: completed >= total budget; OR a run-fatal `HUMAN-NEEDED:` was emitted; OR every remaining candidate is either done or parked in the Blocked-on-Human ledger (NO unblocked autonomous work remains anywhere) AND the feature frontier is explicitly judged exhausted AND the value ladder exhausted ("lifecycle verified").
            Guard: never BLOCK once completed >= total budget — that is the hard ceiling. The healthy terminal state is "all remaining work is human-blocked or exhausted", NOT "the first human blocker was hit".
---

# Development Cycle Runner

Execute iterative development cycles. Each cycle is a **self-contained micro-loop** — re-plan, design (if needed), execute, verify, reflect, derive-next. The roadmap is a **phase backlog, not a cycle plan**: only the current cycle is scoped concretely, and each cycle's outcome decides the next cycle's scope. Earlier cycles reshape the backlog based on what they reveal.

## Why this shape

A single upfront N-cycle plan followed by sequential execution is indistinguishable from one large implementation — the "cycle" structure adds no discovery value. Real iterative work requires each cycle to:

1. Re-check assumptions made at the start
2. Absorb what previous cycles learned
3. Be able to **change the plan** when reality diverges
4. **Derive the follow-on its own output now implies** — work that could not have been specified before the cycle existed

The structure below keeps per-cycle overhead bounded while leaving room for mid-flight re-planning.

### Observed failure mode this skill exists to prevent

The seductive trap — observed in real runs — is to label a plan "directional" while filling it with a **cycle-numbered scope table** (Cycle 1 = X, Cycle 2 = Y, … Cycle N = Z). That is not a directional roadmap; it is a binding N-cycle plan wearing a directional label, and it collapses the multi-turn structure back into a single turn. **The roadmap must not know cycle numbers.** Concrete scope exists for exactly one cycle at a time — the one you are in. Everything beyond it is a phase-level direction, not an assigned cycle. The scope of cycle K+1 is *not yours to decide now*; it is decided by cycle K's STEP 5, by design — because only then do you know what cycle K revealed.

This is **just-in-time scoping**: plan one cycle, run it, let it tell you the next.

### Scope is discovered, not only inherited

Just-in-time scoping has a second half that is easy to miss: the cycle's *own output is a source of the next cycle's scope*. A capability, once built, naturally implies follow-on work that could not have been named before it existed — you build single-file upload, and only then do "validate the upload", "accept multiple files", "handle the empty/oversized case" become concrete. **Failing to derive this emergent scope is the early-termination failure mode the user feels as "it only did the initial plan and quit":** a cycle finds no defects, sees a stable roadmap, writes "Next-Cycle Scope: none", and stops — even though the capability it just built is visibly incomplete to any user, developer, or operator of it.

So every cycle's STEP 5 must **actively derive** what its output implies next, from multiple stakeholder lenses (user / developer / operator), and decide per candidate whether it is *autonomous-eligible* or a *human-discussion proposal*. This is not scope creep, because the autonomy bound is strict (see the derivation gate in STEP 5): only pattern-following completion that stays within the project's **declared role** is taken as autonomous scope. Anything that opens a new product direction, a new dependency/paradigm, or a genuine trade-off is routed to proposals for human decision — never self-decided. "Frontier exhausted" remains a legitimate, expected terminal state; it just has to be a *stated judgment*, not an empty blank.

## Unscoped Bash rationale

`allowed-tools` includes `Bash` without scope. Development execution requires arbitrary build/test/lint/git commands across unknown projects — scoping would require per-project edits. Accepted deliberately; narrow-surface skills (`issue`, `pr`) use `Bash(gh *)` instead.

## Durable state over conversation memory

This skill runs on the **host agent's native loop and context management** — it does NOT wrap itself in an external reset loop. But native context can be compacted or summarized mid-run, so a cycle must never depend on remembering earlier cycles from conversation alone. **The cycle logs ARE the memory.** Every cycle reconstructs its state from on-disk artifacts (previous `cycle-*.md`, `ROADMAP.md`, git log), so the run survives any native compaction transparently. Write logs richly enough that a fresh context could resume from them with zero conversational history. This is the minimal-intervention stance: don't rebuild context machinery the harness already owns — just keep durable state complete enough to survive it.

## Parameters

- Total cycles: `$0` (default: 5)
- Starting cycle number: `$1` (default: 1)
- `--dry-run`: Preparation + phase backlog only
- `--no-commit`: Skip final commit

**`N` is a ceiling, not a target.** It bounds how many cycles *may* run — it is not a quota of scopes to fill in advance. Do not pre-partition `N` into `N` scopes. If the roadmap runs dry before `N`, terminate early (see Surplus-Cycle Value Ladder). If more work surfaces than `N` can hold, stop at `N` and carry the rest forward. The right mental model is "I have up to `N` turns," never "I must plan `N` things now."

---

## Preparation (light)

The preparation phase is **thin by design**. Deep analysis belongs to each cycle's STEP 1, where it can be informed by what's actually happening.

### 1. Conversation Context (highest priority)

Check the preceding conversation for scope — explicit tasks, agreed-upon next steps, "continue with..." statements.

### 2. Previous Cycle Logs

```bash
Glob: claudedocs/cycle-logs/cycle-*.md
```

Review the most recent log's **Carry-Forward** and **Roadmap Revisions** sections. These are inherited obligations and prior re-planning decisions.

### 3. Plan Discovery (only if no scope from above)

Stop at first found: CLAUDE.md → AGENTS.md → ROADMAP.md / TASKS.md / TODO.md → docs/ → README.md. If nothing found, ask the user. Do not invent scope.

### 4. Philosophy Alignment (high-level only)

Evaluate the overall goal — not every future cycle — against CLAUDE.md / README.md:

| Dimension | Question |
|-----------|----------|
| Core Mission Fit | Serves core purpose? |
| Scope Alignment | Within library responsibility? |
| Pattern Consistency | Consistent with existing patterns? |
| Dependency Direction | No upstream→downstream leakage? |

Reject scope items that score low **at the overall level**. Per-cycle drift checks (STEP 0) catch localized issues later.

### 5. Phase Backlog (not a cycle plan)

Create `claudedocs/cycle-logs/ROADMAP.md` if missing. It holds **phase-level directions only** — a backlog of goals, not an itinerary of cycles:

- Group work as **phases / goals**, each revisable by per-cycle Derive-Next
- Include known unknowns and investigation needs, not presumed answers

**Hard rule — the roadmap must not know cycle numbers.** Do NOT produce a `Cycle 1 = …, Cycle 2 = …` table, and do NOT assign scope to any cycle beyond the first. You cannot know what Cycle 2+ should contain — that is decided by the preceding cycle's STEP 5, by design (see "Observed failure mode" above). A cycle-numbered scope table here is the single failure this skill exists to prevent.

Then scope **only Cycle 1**: pick the one most valuable phase to start, and leave the rest of the backlog as undated phases.

**If --dry-run, stop here.**

---

## Per-Cycle Process

Every cycle runs these six steps in order. Steps are **differentiated by weight** — STEP 0 is always light, STEP 1 runs only when triggered, STEP 4 reflection is always mandatory.

### STEP 0: Re-plan (always, light)

The first thing any cycle does is check whether the plan it inherited is still correct.

**Scope exactly one cycle — this one.** STEP 0 decides what *this* cycle does, nothing further. Do not lay out cycle 2, 3, … N here: the first cycle is not a planning summit for the whole run, and a cycle-numbered table is forbidden (see "Observed failure mode"). The next cycle's scope is produced by *this* cycle's STEP 5, once you know what this cycle revealed.

**Bounded inputs** (keep this cheap — target <5 minutes):

- Previous cycle's Carry-Forward + Next-Cycle Scope + Roadmap Revisions
- The phase backlog (`ROADMAP.md`) — for direction only, to pick *this* cycle's scope from
- Any changes to CLAUDE.md / README.md since the last cycle (diff only, not full re-read)

**Decisions**:

1. **Re-check the Blocked-on-Human ledger first** — for each parked `BLOCKED-ITEM`, ask "is the blocker now resolved (credential provided, decision made)?" If yes, un-park it — it becomes an eligible candidate again. If still blocked, it stays parked and is skipped as scope this cycle.
2. **Inherited defects first** — if previous Carry-Forward contains actionable items, they are this cycle's priority scope
3. **This-cycle scope (skip blocked candidates)** — if no inherited next-step exists (e.g. Cycle 1), pick the single most valuable **unblocked** phase from the backlog and scope only it. If the inherited Next-Cycle Scope is itself blocked (needs a credential / user-only decision), do NOT terminate — park it as a `BLOCKED-ITEM` and **fall through** to the next unblocked candidate (another backlog phase, a Carry-Forward defect, or an autonomous-eligible Emergent Next Capability). Only when *no* unblocked candidate exists anywhere does the run reach its terminal state (see rule 9).
4. **Drift check** — 1–2 sentence judgment: has anything in the project invalidated the inherited next step?
5. **Trigger check** — see below

**Output**: This cycle's scope only (an unblocked candidate), either as-inherited or adjusted.

### Trigger matrix

| Trigger | Signal | Action |
|---------|--------|--------|
| 🔴 HARD STOP *(run-fatal)* | Inherited plan conflicts with the project constitution (CLAUDE.md / philosophy / architecture), OR architecture change invalidates 3+ future cycles, OR critical dependency deprecated — a blocker that **poisons all remaining work** | **Constitutional conflict → amendment, not override**: name the conflict (planned scope *X* vs. constitution clause *Y*), then escalate with the two resolutions — revise the scope to fit, OR amend the governing doc (propose a concrete CLAUDE.md/design-doc diff). Log blocker in Carry-Forward, emit a single line `HUMAN-NEEDED: <one-line reason>`, **terminate the whole run**. Reserve this for genuine structural invalidation — a merely-blocked single scope is 🔵 BLOCKED below, not HARD STOP. Do not silently proceed against the constitution, and do not unilaterally override it. |
| 🔵 BLOCKED *(item-level, does NOT terminate)* | *This* scope needs something only a human can supply — an external credential/dependency, or a product/API decision only the user can make — but the blocker is **local to this scope** and leaves other work workable | **Park, don't terminate.** Move this scope to the **Blocked-on-Human** ledger (Carry-Forward), emit `BLOCKED-ITEM: <scope> — <one-line reason + what would unblock it>` (NOT `HUMAN-NEEDED`), then **fall through to the next unblocked candidate** — a backlog phase, a Carry-Forward defect, or an autonomous-eligible Emergent Next Capability — and continue the run. The run terminates on item-level blockers only when *every* remaining candidate is likewise blocked or exhausted (see termination rule 9). |
| 🟠 RE-PLAN | Roadmap order/split needs change, but overall goals remain valid | Adjust roadmap autonomously, record in **Roadmap Revisions** log section |
| 🟡 SCOPE ADJUST | This cycle's scope needs trimming or expansion only | Adjust inline, proceed to STEP 1 |
| ⚪ NONE | Plan still valid | Proceed with inherited scope |

HARD STOP is **deliberately narrow** and **run-fatal**: it terminates the entire run, so it is reserved for structural invalidation that poisons all remaining work. A 🔵 BLOCKED item only parks one scope and the run continues on other work. Agent autonomy covers RE-PLAN and SCOPE ADJUST. If in doubt between RE-PLAN and HARD STOP, choose RE-PLAN; if in doubt between 🔵 BLOCKED-item and 🔴 HARD STOP, choose 🔵 BLOCKED — ending the whole run on a *local* blocker while other work remains is precisely the early-termination failure this skill exists to prevent.

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
  - **Autonomous-eligible** (→ becomes a Next-Cycle Scope / value-ladder candidate) when ALL hold: its *absence would be felt as incompleteness or a defect*; it stays within the project's **declared role and established patterns**; and it carries **no real trade-off** (pattern-following, additive, low-risk). *Worked examples:* the codebase already has a drag-drop pattern elsewhere → extending it to the new surface is autonomous; adding validation to a new upload path is autonomous.
  - **Discussion / proposal-only** (→ Structural Improvement Proposals or Pending Human Decisions; **never** taken as autonomous scope) when it opens a **new product direction**, introduces a **new interaction paradigm, dependency, or surface** the project has not committed to, or involves a **trade-off only a human / product owner should weigh**. *Worked examples:* introducing drag-drop where no such pattern exists yet; "multi-file" when it would change the product's data model. Propose with rationale — do not self-decide.
  - **Frontier exhausted** — a valid, expected outcome: the capability is genuinely complete and any further extension would be scope creep or needs human direction. **State this explicitly** (it is what lets the run terminate); an empty blank is treated as "derivation skipped", not "exhausted".
- **Blocked-on-Human (ledger — persists and accumulates, does NOT terminate)**: Concrete scopes that hit an *item-level* blocker this cycle — a needed external credential/dependency, or a decision only the user can make — where the blocker is local to that scope and other work stays workable. Each entry records the scope, the blocker, and **what would unblock it**. **Copy every unresolved entry forward to the next cycle** (like Carry-Forward defects) and re-check it at STEP 0. This ledger only grows; it never ends the run. The run terminates only when *every* remaining candidate is in this ledger (nothing unblocked left) or the frontier + ladder are exhausted. Distinct from Pending Human Decisions: those are advisory proposals; this is a *parked, un-runnable scope* that governs termination.
- **Structural Improvement Proposals**: Refactoring candidates and better patterns found in STEP 4 — with rationale and recommended approach. Human decides when/whether to act.
- **Pending Human Decisions**: Breaking API, major architecture, ambiguous scope, and every *discussion-class* emergent candidate above
- **Roadmap Revisions**: If STEP 4's roadmap-impact judgment said "yes" — record the change to `ROADMAP.md` (phase level) and log it
- **Next-Cycle Scope**: This is where the next cycle is actually planned — concretely, for **one** cycle only. Draw it from three sources in priority order: (1) inherited / this-cycle Carry-Forward defects, (2) mid-cycle discoveries (a problem too large for this cycle, or one deserving its own), (3) the highest-value **autonomous-eligible Emergent Next Capability**. Only when all three are empty — feature frontier explicitly judged exhausted — does Next-Cycle Scope become "none", handing off to the value ladder. Do **not** scope cycle+2 and beyond — those stay phase-level in the backlog until their predecessor's STEP 5 reaches them.

**Do NOT carry forward defects that could have been fixed in STEP 4.** If you can fix it, fix it now.

---

## Cycle Log

Write `claudedocs/cycle-logs/cycle-{NN}.md` after each cycle:

```markdown
# Cycle {NN}: {Title}
Date: {YYYY-MM-DD}

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
- Blocked-on-Human (ledger): {parked scopes with blocker + what would unblock each — carried forward every cycle until resolved, or "None". These accumulate; they do NOT terminate the run.}
- Structural Improvement Proposals: {refactoring candidates with rationale, or "None"}
- Pending Human Decisions: {decisions needing human input + discussion-class emergent candidates, or "None"}
- Emergent Next Capability: {follow-on(s) derived from this cycle's output across user/developer/operator lenses, each tagged autonomous / discussion — OR "Frontier exhausted: <why>". Never leave blank.}
- Roadmap Revisions: {phase-level changes made to ROADMAP.md, or "None"}
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
- Track ② rung "documentation" is the floor: even when nothing else applies, a stale-doc sweep (README, `docs/`, CLAUDE.md, CHANGELOG, examples) is always in-scope surplus work.

**Terminate early only when** primary work is done AND no *unblocked* defects/Carry-Forward remain AND the roadmap is stable AND **the feature frontier is explicitly judged exhausted** (STEP 5 emergent derivation, across all three lenses, produced no autonomous-eligible capability) AND the ladder surfaces no *unblocked* signal the remaining budget can act on AND **every remaining candidate is either complete or parked in the Blocked-on-Human ledger** (no unblocked autonomous work is left anywhere). "Frontier exhausted" must be a *stated judgment* in the log, never an unfilled blank — an empty Emergent Next Capability line means derivation was skipped, which is not a valid reason to stop. Item-level `BLOCKED-ITEM` scopes accumulate in the ledger and are reported at run end; a blocker on one scope never terminates the run while any other scope is still workable. Log which rungs were climbed and which were proposed.

## Execution Rules

1. **No interruptions within a cycle**: Decide autonomously. Do not ask for confirmation mid-cycle.
2. **HARD STOP (run-fatal) vs. item-level block — terminate only on run-fatal**: A **run-fatal HARD STOP** (constitution conflict / structural invalidation that poisons all remaining work) emits `HUMAN-NEEDED: <reason>` and terminates the whole run — do not force progress. An **item-level blocker** (one scope needs a credential or a user-only decision, but other work is independent) does NOT terminate: emit `BLOCKED-ITEM: <scope> — <reason>`, park it in the Blocked-on-Human ledger, and continue with the next unblocked candidate. Ending the whole run on a *local* blocker while other work remains is the early-stop failure this skill exists to prevent.
2.5. **Option-question self-resolution**: When a non-blocker decision has multiple reasonable options, do NOT ask the user. Self-decide by this priority and proceed: 근본/structural fit > 정석/balanced > 표준/convention > 세련/minimal change > project-philosophy alignment. Log the options and the chosen rationale in one line. Reserve `HUMAN-NEEDED:` (whole-run terminate) for **run-fatal** blockers only — an unrecoverable error or a structure-invalidating change that poisons all remaining work. A **required external credential/dependency, or a decision only the user can make, that blocks just this scope** is an item-level `BLOCKED-ITEM:` — park it and keep the run going on other work; it contributes to termination only when it is the *last* unblocked candidate.
3. **Fix what you find**: STEP 4 **defects** (bugs, broken edges) MUST be resolved in the same cycle. **Structural improvements** go to Carry-Forward as proposals — do not refactor silently. **Orphans** (unused code, stale docs) are removed immediately and noted in the log.
4. **Inherited defects first**: Previous Carry-Forward actionables are mandatory at STEP 0.
5. **Roadmap is a phase backlog, not a cycle plan**: It holds phase-level directions only — never a cycle-numbered scope table. Concrete scope exists for one cycle at a time (this one); the next cycle is scoped by this cycle's STEP 5. Revise the backlog when evidence requires and log revisions explicitly.
6. **Quality over scope**: Reduce new scope if needed — never reduce defect resolution or reflection depth.
7. **Research actively**: WebSearch before guessing. Record sources.
7.5. **No invention**: Data you did not directly observe (a command's output, a file's contents, a test result) stays "unknown" — never present a guess as fact. When something is unknown and matters, state it and take the step that would observe it rather than assuming.
8. **Defect honesty**: Record issues openly. "It works" ≠ "It's good".
9. **No idle early stop — park blockers, push unblocked work, quit last**: While cycles remain, termination is the last resort, reached in this order. (a) **Emergent derivation (STEP 5)** — derive the natural next capability from what you just built, across the user/developer/operator lenses; if a candidate passes the derivation gate, that *is* the next cycle (main loop, track ①). (b) Only when the feature frontier is explicitly judged exhausted do you climb the **Surplus-Cycle Value Ladder** (durable value → stability → efficiency), acting where the project shows a concrete signal; doc-sync (README, `docs/`, CLAUDE.md, CHANGELOG, examples) is its always-applicable floor. (c) **Item-level human blockers never terminate the run** — park each `BLOCKED-ITEM` in the Blocked-on-Human ledger, carry it forward, and keep pushing every *unblocked* candidate (backlog phase, Carry-Forward defect, autonomous emergent capability, ladder signal). (d) Terminate early only once **no unblocked autonomous work remains anywhere** — every backlog phase, Carry-Forward item, autonomous-eligible emergent capability, and ladder signal is either done or parked in the ledger — AND the feature frontier and ladder are explicitly judged to surface no actionable *unblocked* signal. Log that judgment (and the full ledger of parked blockers) explicitly. Throughout: additive/low-risk work is done in-cycle (STEP 2→4); invasive/opinionated or discussion-class work is proposed in Derive-Next, never self-decided.
10. **Continuity chain**: Always read the previous cycle's Carry-Forward, Next-Cycle Scope, and Roadmap Revisions before STEP 0. The previous cycle's Next-Cycle Scope is this cycle's starting scope.
11. **Latent work priority**: The best cycles surface structural improvements nobody thought to ask about — propose them in Derive-Next with rationale. Do not fold them silently into scope.
12. **Cost discipline**: STEP 0 is bounded (~5 min). If drift check seems to require deep analysis, that is a RE-PLAN signal — handle it explicitly rather than letting STEP 0 bloat.

## Commit

Before the single end-of-run commit, run a **lightweight release-readiness check** (skip entirely on `--no-commit` / `--dry-run`). It *verifies and packages* — it never performs a release.

**Checklist** (items the project lacks are N/A — skip them, do not invent them):

1. **Version consistency** — if any version-bearing file changed this run, confirm all agree (e.g. `plugin.json`, `marketplace.json`, README badges, package manifest, intended tag). A mismatch is a defect: fix it before committing.
2. **Changelog** — if the project keeps a CHANGELOG / release notes, confirm this run's changes are recorded. A missing entry is additive/low-risk: add it now.
3. **Docs** — confirm the doc-sync floor (ladder ②) ran and reported consistent; do not re-run it here.
4. **Evidence** — package the actual STEP 3 verification output (test counts, build result, lint status). Assertions are not evidence (rule 7.5); if you cannot show the output, it is not verified.

Record the outcome as a `## Release Readiness` block in the final cycle log:

```markdown
## Release Readiness
- Version: {all version files agree at X.Y.Z, or "n/a"}
- Changelog: {entry present for this run, or "n/a"}
- Docs: {doc-sync verified consistent}
- Evidence: {e.g. `npm test` 142 passed; build ok; lint clean}
- Tag/publish: deferred to human/CI (not performed)
```

Then:

- Commit **once** after all cycles complete (or on HARD STOP / early termination)
- Use built-in `/commit`
- **Do NOT perform the release** — no tagging, publishing, or pushing; that stays with the human / CI
- **NEVER bump MAJOR version**

## Start

Begin: Preparation → Cycle 1 → Cycle 2 → ... → Cycle N (or until HARD STOP / early termination).
