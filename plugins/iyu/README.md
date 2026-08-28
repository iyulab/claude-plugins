# IYU Plugin

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://code.claude.com/docs/en/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.36.1-blue.svg)](./.claude-plugin/plugin.json)

Productivity toolkit for open-source library maintainers and developers.

## Philosophy

**"Every issue is an opportunity"** - Move beyond accept/reject to find the best path forward.

**"Every contribution is a gift"** - Mentor, don't gatekeep. Merge and improve when feasible.

## Installation

```bash
/plugin marketplace add iyulab/claude-plugins
/plugin install iyu@iyulab-plugins
```

## Components

| Component | Type | Activation | Description |
|-----------|------|------------|-------------|
| **Mindset** | Skill | Auto | Shared "Critical but Constructive" philosophy + reference materials |
| **Issue & PR Triage** | Skill | Auto | Conversational triage advice with decision matrices, response templates, and tone rules |
| `/iyu:run-cycle` | Skill | Manual | Iterative development cycles with Stop hook |
| `/iyu:handoff` | Skill | Manual + model-invoked | Session closeout — continuity-doc upkeep, next scope, re-ordering, decisions flagged (not briefed) for `/iyu:resume` |
| `/iyu:resume` | Skill | Manual + model-invoked | Session opener — reads the continuity docs and current state, synthesizes/reprioritizes, briefs flagged and derived decisions with options + a recommendation, records the pick immediately, stops before execution |
| `/iyu:ship` | Skill | Manual | Version bump → commit → push → CI watch, gated on whether now is the moment |
| `/iyu:telemetry-az` | Skill | Manual | Azure App Insights telemetry triage, issue discovery + run-over-run user analytics |
| `/iyu:backlog-discover` | Skill | Manual | Playbook-driven backlog discovery + diagnose/rank/stage — proposal only, never auto-merges |

## Commands

### /iyu:run-cycle

Iterative development cycles with evaluation and continuity tracking.

```bash
/iyu:run-cycle        # 10 cycles (default)
/iyu:run-cycle 20     # up to 20 cycles
```

One parameter, the cycle budget — anything you write alongside the invocation is read as scope
context. The starting cycle number is derived from the existing logs (highest index + 1), not passed.

Each cycle: Scope → Research → Implement → Test → Evaluate → Carry-Forward.

**Just-in-time scoping** — `N` is a ceiling, not a target. Only the current cycle is scoped concretely; everything beyond it stays a phase-level direction in the backlog. Each cycle's outcome decides the *next* cycle's scope, so the run behaves like genuine multi-turn work rather than one upfront N-cycle plan executed sequentially. Work too large for a cycle (or deserving its own) is promoted to the next cycle instead of being pre-assigned.

**Emergent scope derivation** — not everything can be specified upfront; a capability, once built, implies follow-on work that only becomes concrete after it exists (single-file upload → "validate it", "accept multiple files", "handle the empty/oversized case"). Each cycle's STEP 5 actively derives this from three lenses — **user** (what would they now expect or hit?), **developer/maintainer** (does it fit the philosophy; what's left brittle?), **operator** (what does production now require?) — then runs every candidate through a **derivation gate**: pattern-following completion within the project's declared role is taken as autonomous next scope; anything opening a new product direction, paradigm, dependency, or real trade-off is routed to a human-decision proposal, never self-decided. The verdict is written as a **token** the Stop hook reads literally — `FRONTIER-OPEN:` or `FRONTIER-EXHAUSTED:` — and the run can stop early only on the latter; neither token present means derivation was skipped, which is never a valid reason to stop. This is what prevents the "it only did the initial plan and quit" failure mode.

Cycles maintain continuity — unresolved issues and pending decisions automatically propagate through the cycle chain.

**Continuity root (follows your repo's convention)** — a run's six artifacts (`ROADMAP.md`, `HANDOFF.md`, `HISTORY.md`, `cycle-logs/`, `RUN-SUMMARY-*.md`, `STRANDS.md`) all live in **one** directory, resolved by looking at the repo rather than hardcoded: any existing `cycle-logs/`, `backlog-discovery/`, or `telemetry/` anchors the root at its parent, else an existing `ROADMAP.md`/`HANDOFF.md` anchors it at its own directory. The project's convention is adopted as-is — including an umbrella repo that nests the set per submodule (`claudedocs/<Submodule>/`). Only when none of those exists is the default `claudedocs/` created. `/iyu:backlog-discover` and `/iyu:telemetry-az` resolve by the identical rule, so a project that has run only one of the three still lands every artifact in the same place. The six move together, since `HISTORY.md` indexes cycle logs, the handoff anchors to backlog phases, and `STRANDS.md` tracks which dominant strand of work each cycle or session served — written by both
`run-cycle` and `handoff`.

**Continuity-doc hygiene** — `ROADMAP.md` (and `HANDOFF.md`, if the project keeps one) hold *remaining* work only, so "what's left?" is never buried under "what's done". Every cycle's STEP 5 migrates every completed phase/item found — including pre-existing leftovers — into a `HISTORY.md` index (one compressed line per phase, linking to the cycle log; detail stays in cycle logs and git history). The handoff is rewritten to current + next only, each continuity doc links to `HISTORY.md` at the top, and the end-of-run release-readiness check verifies the docs stayed lean.

**Autonomy leveling (act like a capable delegate)** — decisions are handled by **stakes × reversibility**, not by asking about everything. **L0** taste/convention is decided silently; **L1** decisions that carry a real trade-off but are *reversible* (two-way door) are self-made by weighing five **co-equal** lenses (근본/정석/표준/세련/philosophy — deliberately *not* a priority order), acted on immediately, and logged `provisional` in a persistent **Decisions Ledger**; **L2** irreversible-or-human-only decisions are batched (BLOCKED-ITEM / Pending Human Decision) while other work continues; **L3** run-fatal issues HARD STOP. The bias is **in-dubio-pro-autonomy** — when a decision is ambiguous between L1 and L2 it resolves to L1 (decide + flag), the sole exception being an irreducible cross-lens conflict, which escalates. Corrections are dual-channel: a reverted L1 decision is picked up from conversation *and* written durably to the ledger, then re-opened at the next cycle's STEP 0 as fresh scope re-evaluated together with whatever was built on it. Every run ends with an **End-of-Run Report** (`RUN-SUMMARY-{date}.md` + final response, on all termination paths) in three parts — progress with evidence, deferred L2 decisions awaiting you, and self-made L1 decisions each with its trade-off and a one-line "to correct" — so proceed-first-correct-later stays safe.

**Self-unblock before parking** — a blocker only counts once you've tried to remove it. Before any `BLOCKED-ITEM` is parked, the cycle checks whether the credential/dependency is actually missing (look, don't assume), whether the "user-only decision" is already answered in CLAUDE.md / an accepted issue / a prior ledger entry, and whether a genuinely useful slice can proceed without the blocked part — parking only the residue, and recording what was tried. An assumed blocker is how a run stalls with budget left.

When primary work finishes early and cycles remain, run-cycle does not stop idle. It climbs a **Surplus-Cycle Value Ladder** — investing the remaining budget across the full software lifecycle: **① main loop → ② durable value** (research → refactoring → docs/assets) **→ ③ stability** (tests/monitoring → security/compliance → resilience) **→ ④ efficiency** (DevOps → DX). It acts only where the project shows a concrete signal; additive/low-risk work is done in-cycle, invasive/opinionated work is proposed for human decision. Doc-sync is the always-applicable floor of this ladder.

Before committing, run-cycle runs a **lightweight release-readiness check** — version consistency across version-bearing files, CHANGELOG coverage, doc-sync, and an evidence block of the actual test/build/lint output. It verifies and packages only; tagging, publishing, and pushing stay with the human / CI. The commit itself defaults to **one per run** (bundling beats fragmenting), splitting on **verified-cycle boundaries** only when a long run's single diff would no longer be reviewable in one pass — each cycle's passing STEP 3 is already a clean rollback point.

Cycle accounting is relative to where the run started: Preparation derives the starting index from the existing logs and records it (with the budget) in every cycle log header, and only logs from that index onward count toward the budget — so a repo carrying logs from earlier runs can't read as already over budget and stop before doing any work. The Stop hook reads those headers, since it gets no invocation arguments of its own.

### /iyu:handoff

Close out a session so the next one can resume from files alone.

```bash
/iyu:handoff              # cover the whole session
/iyu:handoff "decisions"  # narrow the focus
```

Rewrites `HANDOFF.md` to **in flight / next / waiting on you / decided this session / state of
play**, migrates completed work out of `ROADMAP.md` into the `HISTORY.md` index, and derives the
next scope across the user / developer / operator lenses. It reconstructs what happened from `git
log`, the existing continuity docs, and the latest cycle log — not from the conversation, which may
already be compacted.

Unlike the plugin's other command skills, Claude can also start this one on its own — only on a
concrete signal that the session is actually ending or the continuity docs are visibly stale, and
always announcing the run before touching a file. It is the one command skill safe to self-invoke:
it never commits, pushes, or implements, so a mistimed run costs nothing worse than a re-editable
file.

It also **re-orders what remains**: deriving what comes next and deciding what order the rest sits
in are different jobs, and the item most often misplaced is the release. Work still pending on the
same consumer-facing surface pushes a release item to that phase boundary — and the outcome is the
reordered file, not a paragraph about it.

**Decisions are flagged here, not briefed.** This skill used to also brief pending decisions with
options and a recommendation — it no longer does. A briefing is analysis aimed at whoever resumes,
and producing it at close means it sits, possibly staling, until someone actually acts on it. This
skill now stops at **naming** a decision-class item in one line (resource-blockers still keep their
short blocker · tried · what-would-unblock form, since that's a fact, not a choice) — briefing it is
[`/iyu:resume`](#iyuresume)'s job, done fresh at the moment someone is actually about to act on it.
If you can already see the answer *and* the choice is reversible, it never reaches "Waiting on you"
at all — it's decided on the spot and recorded under "Decided this session" instead. Nothing left
that needs a human is a good outcome, reported as **"None"**, not a gap to fill.

The four-part briefing shape itself — decision · grounded options · cross-lens read · named
recommendation — lives in [`_shared/decision-briefing.md`](./skills/_shared/decision-briefing.md),
read by `/iyu:resume` step 4, `run-cycle`'s End-of-Run Report, and `ship` step 0. Only the carrier
differs: `resume` and `run-cycle` write a document section, `ship` puts the options and the
recommendation **into the question it asks** and waits for the answer.

It deliberately does **not** commit and does **not** implement: the handoff describes a state, and
changing that state while writing it makes the description wrong.

Shares [`_shared/continuity-docs.md`](./skills/_shared/continuity-docs.md) with `/iyu:run-cycle` —
where the docs live, what belongs in each, the hygiene pass, and how next scope is derived are
defined once, in one file, for both — and
[`_shared/decision-lenses.md`](./skills/_shared/decision-lenses.md), which defines those five lenses
for the two self-decide/brief purposes described below.

### /iyu:resume

Open a session from the files `/iyu:handoff` left, instead of re-deriving the same ground twice.

```bash
/iyu:resume              # confirm state + brief every flagged decision
/iyu:resume "decisions"  # narrow to just the decisions
```

Reads `HANDOFF.md`/`ROADMAP.md` as they stand, plus enough current state (git log/status, `HISTORY.md`
tail, recent memory) to judge whether they still hold — no cycle-log reading, no hygiene pass, no
migrating anything to `HISTORY.md`; that stays `/iyu:handoff`'s job entirely, so running both is two
different jobs, not double work. It applies judgment to what it read, not just replaying it: reorder
"Next" when the recorded priority no longer fits current state, derive prerequisites the plan is
missing, and object to anything that no longer looks reasonable — presented as proposals, split into
코드 작업 / 비코드 작업 (flagging staleness if the tree has moved since the last handoff; an empty
"Next" gets a pointer to `/iyu:backlog-discover`, not an invocation — synthesis reorders known work, it
doesn't discover unscoped work). It then **briefs** every decision-class item, whether flagged by
`/iyu:handoff` or raised by its own synthesis: grounded options, the cross-lens read
(근본/정석/표준/세련/철학), and a named recommendation with what it locks in. That code/non-code split
also drives the reversibility read: a code decision defaults toward self-decide once a recommendation
exists, while a non-code decision touching something central policy already gates on a human (push, a
GitHub issue registration, a major-version bump, publish) stays briefed regardless of confidence. A
self-decided entry doesn't disappear — it's surfaced alongside the briefing (decision · trade-off · to
correct) for a quick "anything different?" look, confirm-not-approval, and recorded the same as an
answered decision.

**It is the only skill in this plugin whose entire point is to pause and wait — and then stop.** Every
decision-class entry gets an answer before the session-opening work is called done — and the instant
one lands, it is written into `HANDOFF.md`'s "Decided this session" section immediately, not left for
the next `/iyu:handoff` to reconstruct from a git diff that might not even show it (a confirmed reorder
lands there too, for the next handoff to apply to `ROADMAP.md`). That immediate write-back is what
keeps a decision from being lost if the session ends, or compacts, before the next handoff runs. Once
the scope is settled, `/iyu:resume` stops — it never proceeds into implementation on its own; starting
the work is a separate, explicit instruction or `/iyu:run-cycle`.

Like `/iyu:handoff`, this is safe to self-invoke on a narrow signal (a fresh session with no stated
task and an existing `HANDOFF.md`) — it proposes and decides but never implements.

### /iyu:ship

Take finished work out, and confirm it landed.

```bash
/iyu:ship --commit-only   # bump + changelog + commit
/iyu:ship --no-publish    # ...+ push + watch the CI run
/iyu:ship                 # ...+ publish, if the moment is right
/iyu:ship minor           # force the bump level
```

**Staged, because the stages cost differently.** `bump + commit` is local. `push` reaches the remote
and **spends CI budget**. `publish` reaches **consumers and cannot be undone**. Each stage is
reachable without the next.

**Step 0 asks whether now is the moment** — and asks it as a **briefing**, not a question. Before
anything else it reads the remaining backlog; if unfinished work would touch the same
consumer-facing surface, it lays out the options (publish now / push without publishing / batch into
the next version), what each costs, and which one it would pick and why — then waits. A release that
will require a re-release shortly is close to no release at all, and the project's rhythm is the
project's to declare, not the skill's to impose. If the test clears, no question is asked at all.

It watches the pipeline to completion (`gh run watch --exit-status`) rather than assuming a push
succeeded, and on a red run it fetches the failing step, summarizes the cause, and **stops** — it
does not push speculative fixes. It never bumps MAJOR, and it never reorders the backlog itself;
that is `/iyu:handoff`'s job.

Shares [`_shared/release-cadence.md`](./skills/_shared/release-cadence.md) with `/iyu:handoff` and
`/iyu:run-cycle` — the placement test lives in one file for all three — and
[`_shared/decision-briefing.md`](./skills/_shared/decision-briefing.md) with `/iyu:resume` and
`/iyu:run-cycle`, which is why step 0's question carries options and a recommendation.

### /iyu:telemetry-az

Azure Application Insights telemetry triage. Analyzes telemetry **since the last run**,
classifies defects / performance regressions / feature-drop signals, runs issue-triage
"1 → 10" discovery aligned with the project philosophy, and files issues for
threshold-crossing findings.

It also produces a **run-over-run user-analytics report** (purpose 2): active-user
growth/decline, feature & page preference shifts, and engagement trends — compared against
prior runs via a bounded history (last 12 runs). Comparisons are **cadence-normalized**
(per-day rates), so deltas hold whether you run it daily or weekly. User analytics is
report-only insight; it files an issue only when a usability drop is itself a defect.

```bash
/iyu:telemetry-az                              # Resume from last watermark, triage, file issues
/iyu:telemetry-az --since 2026-05-01T00:00:00Z # Override window start
/iyu:telemetry-az --dry-run                    # Report to chat only, no files, watermark unchanged
/iyu:telemetry-az --no-issues                  # Write report but file no issues
```

Per-repo settings live in `telemetry/config.json` (App Insights app id + thresholds); the
watermark and reports live beside it under `telemetry/`, and issues follow the standard
`issues/` format — all under the same docs root the other skills resolve (default
`claudedocs/`). Requires `az login`.

### /iyu:backlog-discover

Discovers new backlog phases via the Backlog Generation Playbook — then **judges them**,
the way an owner-manager would. Where `run-cycle` is the capable *employee* that executes a
scope, this is the capable *owner*: it decides what deserves attention next **and keeps what
already exists in good order**. Convergent activities (vision-gap analysis, trend research,
benchmarking, academic/theory research scan, domain practice & norms watch,
appropriate-technology adoption verdicts, positioning review, telemetry-az reuse,
issue/community tracking, active dogfooding, stewardship inspection, code/security audits,
developer-tooling gaps) run on a persistent per-activity cadence, alongside emergent
activities (pre-mortems, subtraction sessions, chaos engineering, fresh-eyes onboarding, and
more) selected by self-diagnosing backlog symptoms from project history — with a **3-run
recency window** so one perpetually-true symptom can't monopolize the rotation.

**관리 점검 (stewardship-check)** is the upkeep half, run every sprint by actually executing
the checks: dependency currency (outdated / deprecated / EOL, upgradeable-now vs.
blocked-by-breaking-change, runtime & SDK floor), project configuration (build/CI/lint/test,
release pipeline, package metadata, silently-disabled checks), doc & link hygiene (README
links, badges, quickstart commands verified against the current tree), and repo hygiene
(orphan files, dead scripts, stale artifacts). Concrete defects route to
`<root>/issues/`; only the systemic pattern behind them becomes a proposal item.

**Two co-equal inquiry axes.** Every item is tagged `SW기술` (how the product is built) or
`도메인전문` (what the product is *for* — the concepts, methods, and norms of its subject
area). Research naturally drifts toward the implementation axis while the domain gets
treated as settled; a persistent skew is detected as its own symptom and reported rather
than silently accepted.

**Synthesis, not a flat list.** Discovery ends in a state-of-the-product **diagnosis**
(vision distance · market position · domain fitness · internal health), an
evidence-grounded **importance ranking** (vision contribution × philosophy alignment ×
evidence strength, with cost/risk used for placement), and a dependency-ordered
**now/next/later staging**. Horizons are an ordering, never a schedule — no cycle numbers,
no dates. Every score cites the signal behind it, and an item resting on a thought
experiment alone can't be placed in "now": the response is to schedule the work that would
produce evidence.

**Active dogfooding** is the always-on floor: instead of re-reading already-recorded
friction, a team member drives the product live through a *fresh, vision-anchored
scenario* on its real runnable surface (CLI / library consumer-script / service HTTP),
observing feature/UI/UX/app-flow gaps first-hand. This makes an **empty or recently-run
backlog a deepen-signal, not a done-signal** — and when the floor comes up thin, a
**deepen ladder** digs successively into stewardship → tech health & tooling → theory &
domain practice → benchmarking & positioning. (The floor is not a ladder rung: dogfooding
runs every invocation regardless, so counting it as the first rung would make the deeper
lanes unreachable.) Findings must carry **run-evidence** (commands run + behavior observed +
steps walked) or they're dropped as guesses; concrete defects route to `<root>/issues/`,
only systemic/UX/vision gaps become proposal items.

Items carry stable ids (`BD-YYYYMMDD-nn`), and a gap already named by a recent proposal is
re-opened as **재발견** with new evidence appended rather than filed again — repeated
observation should raise evidence strength, not multiply near-duplicates.

```bash
/iyu:backlog-discover                          # Run all cadence-due activities + diagnosed emergent session(s)
/iyu:backlog-discover --modes vision-gap,web-trend  # Force specific activities regardless of cadence
/iyu:backlog-discover --symptom onboarding-friction # Force a specific emergent session
/iyu:backlog-discover --dry-run                # Report to chat only, no files, state unchanged
```

Fully independent of `/iyu:run-cycle` — `run-cycle` only *consumes* `ROADMAP.md`, this
command only *feeds* it. Every discovered item lands in a proposal document
(`backlog-discovery/proposal-YYYY-MM-DD.md`, under the same docs root `run-cycle`
resolves — default `claudedocs/`); **nothing merges into
`ROADMAP.md` automatically** — a human reviews the proposal and asks explicitly for
selected items to be adopted, per the mindset principle that new product direction is
never self-decided — ranking an item is not merging it. Cadence state
(`backlog-discovery/state.json`) tracks each of the playbook's 34 activities
independently against a clock read once per run (`date -u`, never assumed), so a quarterly
activity doesn't re-run every invocation and a stale half-yearly one doesn't get silently
skipped forever. A single `history[]` (last 12 runs) is the sole trend state, matching
`telemetry-az`'s convention.

## Decision Matrices

**Issue Triage:**

| | Philosophy HIGH | Philosophy LOW |
|--|----------------|----------------|
| Feasibility HIGH | ACCEPT | REDIRECT |
| Feasibility MED | ADAPT | DEFER/REDIRECT |
| Feasibility LOW | DEFER | DECLINE |

**PR Review:**

| | Quality HIGH | Quality LOW |
|--|-------------|-------------|
| Philosophy HIGH | APPROVE | MERGE_WITH_FIXES |
| Philosophy MED | APPROVE_WITH_NOTES | REQUEST_CHANGES |
| Philosophy LOW | REDIRECT | DECLINE |

**Severity Levels:**
| 🔴 Blocker | 🟠 Major | 🟡 Minor | ✨ Praise |

## Skills (Auto-Activated)

The plugin activates automatically when discussing issue evaluation or PR review:

- "Should I accept this feature request?"
- "Is this in scope for my project?"
- "Help me triage this pull request"
- "Review this PR for me"

## Plugin Structure

```
iyu/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── _shared/
│   │   ├── continuity-docs.md
│   │   ├── decision-briefing.md
│   │   ├── decision-lenses.md
│   │   └── release-cadence.md
│   ├── mindset/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── issue-triage/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── run-cycle/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── handoff/
│   │   └── SKILL.md
│   ├── resume/
│   │   └── SKILL.md
│   ├── ship/
│   │   └── SKILL.md
│   ├── backlog-discover/
│   │   ├── SKILL.md
│   │   └── references/
│   └── telemetry-az/
│       ├── SKILL.md
│       └── references/
└── README.md
```

## License

MIT
