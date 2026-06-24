---
name: run-cycle
description: Executes adaptive iterative development cycles — each cycle is a self-contained plan/execute/verify/reflect loop that may reshape the roadmap
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
            2. Read the latest cycle log's Carry-Forward / Next-Cycle Scope: note any unresolved actionable defects, whether a Next-Cycle Scope was named, and whether the lifecycle value ladder still has an actionable signal.
            3. Respond BLOCK only if ALL hold: completed < total budget; no HARD STOP / HUMAN-NEEDED line was emitted; and at least one of (the latest log named a Next-Cycle Scope or the phase backlog has unstarted work, unresolved actionable defects remain, the value ladder still has an actionable signal).
            4. Respond ALLOW if: completed >= total budget; OR a HARD STOP / HUMAN-NEEDED was emitted; OR the latest log records early termination with the ladder exhausted ("lifecycle verified").
            Guard: never BLOCK once completed >= total budget — that is the hard ceiling.
---

# Development Cycle Runner

Execute iterative development cycles. Each cycle is a **self-contained micro-loop** — re-plan, design (if needed), execute, verify, reflect, derive-next. The roadmap is a **phase backlog, not a cycle plan**: only the current cycle is scoped concretely, and each cycle's outcome decides the next cycle's scope. Earlier cycles reshape the backlog based on what they reveal.

## Why this shape

A single upfront N-cycle plan followed by sequential execution is indistinguishable from one large implementation — the "cycle" structure adds no discovery value. Real iterative work requires each cycle to:

1. Re-check assumptions made at the start
2. Absorb what previous cycles learned
3. Be able to **change the plan** when reality diverges

The structure below keeps per-cycle overhead bounded while leaving room for mid-flight re-planning.

### Observed failure mode this skill exists to prevent

The seductive trap — observed in real runs — is to label a plan "directional" while filling it with a **cycle-numbered scope table** (Cycle 1 = X, Cycle 2 = Y, … Cycle N = Z). That is not a directional roadmap; it is a binding N-cycle plan wearing a directional label, and it collapses the multi-turn structure back into a single turn. **The roadmap must not know cycle numbers.** Concrete scope exists for exactly one cycle at a time — the one you are in. Everything beyond it is a phase-level direction, not an assigned cycle. The scope of cycle K+1 is *not yours to decide now*; it is decided by cycle K's STEP 5, by design — because only then do you know what cycle K revealed.

This is **just-in-time scoping**: plan one cycle, run it, let it tell you the next.

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

1. **Inherited defects first** — if previous Carry-Forward contains actionable items, they are this cycle's priority scope
2. **This-cycle scope** — if no inherited next-step exists (e.g. Cycle 1), pick the single most valuable phase from the backlog and scope only it
3. **Drift check** — 1–2 sentence judgment: has anything in the project invalidated the inherited next step?
4. **Trigger check** — see below

**Output**: This cycle's scope only, either as-inherited or adjusted.

### Trigger matrix

| Trigger | Signal | Action |
|---------|--------|--------|
| 🔴 HARD STOP | Inherited plan conflicts with the project constitution (CLAUDE.md / philosophy / architecture), OR architecture change invalidates 3+ future cycles, OR critical dependency deprecated | **Constitutional conflict → amendment, not override**: name the conflict (planned scope *X* vs. constitution clause *Y*), then escalate with the two resolutions — revise the scope to fit, OR amend the governing doc (propose a concrete CLAUDE.md/design-doc diff). Log blocker in Carry-Forward, emit a single line `HUMAN-NEEDED: <one-line reason>`, **terminate run-cycle**. Do not silently proceed against the constitution, and do not unilaterally override it. |
| 🟠 RE-PLAN | Roadmap order/split needs change, but overall goals remain valid | Adjust roadmap autonomously, record in **Roadmap Revisions** log section |
| 🟡 SCOPE ADJUST | This cycle's scope needs trimming or expansion only | Adjust inline, proceed to STEP 1 |
| ⚪ NONE | Plan still valid | Proceed with inherited scope |

HARD STOP is **deliberately narrow**. Agent autonomy covers RE-PLAN and SCOPE ADJUST; human judgment is reserved for structural invalidation. If in doubt between RE-PLAN and HARD STOP, choose RE-PLAN and record the reasoning — the next cycle can escalate further if needed.

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
5. **Roadmap impact**: Does this cycle's outcome change what future cycles should do?
6. **User-facing quality** *(when changes touch UI, API contracts, CLI output, or app flow)*: Usability, interaction coherence, convention alignment, flow correctness relative to user mental models. Reference standards concisely when they anchor a finding objectively (e.g., "violates REST uniform interface", "missing affordance — Nielsen #1", "keyboard trap — WCAG 2.1.2").

**Defect vs. improvement distinction**:
- **Defects** (bugs, broken edges, violations) → fix before leaving STEP 4. Loop: discover → fix → re-verify.
- **Structural improvements** (better patterns, refactoring candidates) → do NOT fix silently; carry to STEP 5 as proposals for human decision.
- **Orphans** (unused code, unreferenced files, stale docs) → remove immediately, note in cycle log.

Only items requiring human judgment on defects are exempt from STEP 4 fixes (breaking API, major architecture, ambiguous scope).

### STEP 5: Derive Next

Record **only** what cannot be resolved autonomously, or what reshapes future cycles:

- **Carry-Forward (actionable)**: Things to address next cycle
- **Structural Improvement Proposals**: Refactoring candidates and better patterns found in STEP 4 — with rationale and recommended approach. Human decides when/whether to act.
- **Pending Human Decisions**: Breaking API, major architecture, ambiguous scope
- **Roadmap Revisions**: If STEP 4's roadmap-impact judgment said "yes" — record the change to `ROADMAP.md` (phase level) and log it
- **Next-Cycle Scope**: This is where the next cycle is actually planned — concretely, for **one** cycle only. Now that you know what this cycle revealed, name the next cycle's scope. This is also where mid-cycle discoveries land: a problem too large for this cycle, or one deserving its own cycle, becomes the next cycle's candidate scope (or a split into a near-term phase). Do **not** scope cycle+2 and beyond — those stay phase-level in the backlog until their predecessor's STEP 5 reaches them.

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
- Structural Improvement Proposals: {refactoring candidates with rationale, or "None"}
- Pending Human Decisions: {decisions needing human input, or "None"}
- Roadmap Revisions: {phase-level changes made to ROADMAP.md, or "None"}
- Next-Cycle Scope: {concrete scope for the next single cycle — decided now that this cycle's outcome is known. Do not scope further ahead.}
```

---

## Surplus-Cycle Value Ladder

When primary roadmap work finishes and cycles remain, a passionate maintainer does not down tools — they harden, document, and accelerate. Most agentic loops terminate the moment the task compiles; this skill instead treats the **remaining cycle budget as an investment fund for the full software lifecycle**.

This is the project-specific judgment a generic harness cannot supply, and it is our distinctive contribution — so it stays inside the minimal-intervention boundary: surplus cycles never exceed the requested budget `N`, never preempt defect resolution, and follow the same STEP 1→4 discipline (including "structural changes are proposals, not silent edits").

**Climb in order. Within each track, act only where the project shows a concrete gap (a signal) — do not invent work.**

| Track | Rungs (in order) | Signal that justifies a rung |
|-------|------------------|------------------------------|
| **① Main loop** *(always first)* | plan → execute → verify → cleanup | Open roadmap items or inherited Carry-Forward remain |
| **② 내공 / Durable value** | research/learning capture → structural refactoring → documentation & asset-ization | Undocumented surface, drifted docs, repeated patterns begging extraction, lessons worth recording |
| **③ 방어선 / Stability** | test/coverage & monitoring gaps → security & compliance → error-handling & resilience | Untested critical path, missing input validation, unhandled failure mode, no observability hook |
| **④ 가속기 / Efficiency** | CI/DevOps/platform → DX improvements | Manual repetitive steps, slow/flaky pipeline, awkward local setup |

**Execution guard (keeps minimal-intervention intact):**
- **Additive & low-risk → do it** this cycle (doc-sync, filling a test gap, adding validation, a small CI fix). Run it through STEP 2→4 and log it as a `[ladder:②/③/④]` cycle.
- **Invasive or opinionated → propose in Derive-Next**, do not perform (large refactors, dependency swaps, new infra, security architecture). Human decides.
- **Regression back-flow** — if any surplus track surfaces a defect or regression, drop the surplus work and return to the main loop (track ①, STEP 2). Defects always outrank surplus value; resume climbing only once the regression is resolved.
- Track ② rung "documentation" is the floor: even when nothing else applies, a stale-doc sweep (README, `docs/`, CLAUDE.md, CHANGELOG, examples) is always in-scope surplus work.

**Terminate early only when** primary work is done AND no defects/Carry-Forward remain AND the roadmap is stable AND the ladder surfaces no signal the remaining budget can act on. Log which rungs were climbed and which were proposed.

## Execution Rules

1. **No interruptions within a cycle**: Decide autonomously. Do not ask for confirmation mid-cycle.
2. **HARD STOP escalation is allowed**: When a HARD STOP trigger fires, emit `HUMAN-NEEDED: <reason>` and terminate and report — do not force progress.
2.5. **Option-question self-resolution**: When a non-blocker decision has multiple reasonable options, do NOT ask the user. Self-decide by this priority and proceed: 근본/structural fit > 정석/balanced > 표준/convention > 세련/minimal change > project-philosophy alignment. Log the options and the chosen rationale in one line. Reserve `HUMAN-NEEDED:` for true blockers only (unrecoverable error, structure-invalidating change, required external credential/dependency, or a decision only the user can make).
3. **Fix what you find**: STEP 4 **defects** (bugs, broken edges) MUST be resolved in the same cycle. **Structural improvements** go to Carry-Forward as proposals — do not refactor silently. **Orphans** (unused code, stale docs) are removed immediately and noted in the log.
4. **Inherited defects first**: Previous Carry-Forward actionables are mandatory at STEP 0.
5. **Roadmap is a phase backlog, not a cycle plan**: It holds phase-level directions only — never a cycle-numbered scope table. Concrete scope exists for one cycle at a time (this one); the next cycle is scoped by this cycle's STEP 5. Revise the backlog when evidence requires and log revisions explicitly.
6. **Quality over scope**: Reduce new scope if needed — never reduce defect resolution or reflection depth.
7. **Research actively**: WebSearch before guessing. Record sources.
7.5. **No invention**: Data you did not directly observe (a command's output, a file's contents, a test result) stays "unknown" — never present a guess as fact. When something is unknown and matters, state it and take the step that would observe it rather than assuming.
8. **Defect honesty**: Record issues openly. "It works" ≠ "It's good".
9. **Surplus-cycle investment (no idle early stop)**: If STEP 4 finds zero actionable defects AND no inherited defects remain AND the roadmap is stable, do NOT terminate immediately while cycles remain. Climb the **Surplus-Cycle Value Ladder** (see section above): invest remaining budget in durable value → stability → efficiency, acting only where the project shows a concrete signal. Doc-sync (README, `docs/`, CLAUDE.md, CHANGELOG, examples) is the always-applicable floor of this ladder. Additive/low-risk work is done in-cycle (STEP 2→4); invasive/opinionated work is proposed in Derive-Next. Terminate early only once the ladder surfaces no actionable signal, and log which rungs were climbed or proposed.
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
