# IYU Plugin

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.24.0-blue.svg)](./plugin.json)

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
| **Issue & PR Triage** | Skill | Auto | Conversational triage advice with decision matrices |
| `/iyu:issue` | Skill | Manual | Full issue triage report (isolated context) |
| `/iyu:pr` | Skill | Manual | PR review with security focus (isolated context) |
| `/iyu:run` | Skill | Manual | Plan-driven development execution |
| `/iyu:run-cycle` | Skill | Manual | Iterative development cycles with Stop hook |
| `/iyu:telemetry-az` | Skill | Manual | Azure App Insights telemetry triage, issue discovery + run-over-run user analytics |
| `/iyu:backlog-discover` | Skill | Manual | Playbook-driven backlog discovery + diagnose/rank/stage — proposal only, never auto-merges |

## Commands

### /iyu:issue

Systematic issue evaluation against project philosophy.

```bash
/iyu:issue https://github.com/user/repo/issues/123
/iyu:issue https://github.com/user/repo/issues/123 --quick
/iyu:issue ./docs/feature-request.md --save
/iyu:issue "Add support for Redis caching" --no-research
```

### /iyu:pr

PR review with security awareness and community-nurturing feedback.

```bash
/iyu:pr https://github.com/user/repo/pull/123
/iyu:pr #42 --quick
/iyu:pr #42 --security-focus --save
```

### /iyu:run

Plan-driven or input-driven development execution.

```bash
/iyu:run                                    # Auto-discover from plans
/iyu:run "Implement caching layer for API"  # Input-driven
/iyu:run --dry-run                          # Plan only
```

### /iyu:run-cycle

Iterative development cycles with evaluation and continuity tracking.

```bash
/iyu:run-cycle 5      # 5 cycles
/iyu:run-cycle 3 2    # 3 cycles starting from cycle 2
/iyu:run-cycle --dry-run
```

Each cycle: Scope → Research → Implement → Test → Evaluate → Carry-Forward.

**Just-in-time scoping** — `N` is a ceiling, not a target. Only the current cycle is scoped concretely; everything beyond it stays a phase-level direction in the backlog. Each cycle's outcome decides the *next* cycle's scope, so the run behaves like genuine multi-turn work rather than one upfront N-cycle plan executed sequentially. Work too large for a cycle (or deserving its own) is promoted to the next cycle instead of being pre-assigned.

**Emergent scope derivation** — not everything can be specified upfront; a capability, once built, implies follow-on work that only becomes concrete after it exists (single-file upload → "validate it", "accept multiple files", "handle the empty/oversized case"). Each cycle's STEP 5 actively derives this from three lenses — **user** (what would they now expect or hit?), **developer/maintainer** (does it fit the philosophy; what's left brittle?), **operator** (what does production now require?) — then runs every candidate through a **derivation gate**: pattern-following completion within the project's declared role is taken as autonomous next scope; anything opening a new product direction, paradigm, dependency, or real trade-off is routed to a human-decision proposal, never self-decided. The run stops only when the feature frontier is *explicitly* judged exhausted — preventing the "it only did the initial plan and quit" failure mode.

Cycles maintain continuity — unresolved issues and pending decisions automatically propagate through the cycle chain.

**Continuity-doc hygiene** — `ROADMAP.md` (and `HANDOFF.md`, if the project keeps one) hold *remaining* work only, so "what's left?" is never buried under "what's done". Every cycle's STEP 5 migrates every completed phase/item found — including pre-existing leftovers — into a `HISTORY.md` index (one compressed line per phase, linking to the cycle log; detail stays in cycle logs and git history). The handoff is rewritten to current + next only, each continuity doc links to `HISTORY.md` at the top, and the end-of-run release-readiness check verifies the docs stayed lean.

**Autonomy leveling (act like a capable delegate)** — decisions are handled by **stakes × reversibility**, not by asking about everything. **L0** taste/convention is decided silently; **L1** decisions that carry a real trade-off but are *reversible* (two-way door) are self-made by weighing five **co-equal** lenses (근본/정석/표준/세련/philosophy — deliberately *not* a priority order), acted on immediately, and logged `provisional` in a persistent **Decisions Ledger**; **L2** irreversible-or-human-only decisions are batched (BLOCKED-ITEM / Pending Human Decision) while other work continues; **L3** run-fatal issues HARD STOP. The bias is **in-dubio-pro-autonomy** — when a decision is ambiguous between L1 and L2 it resolves to L1 (decide + flag), the sole exception being an irreducible cross-lens conflict, which escalates. Corrections are dual-channel: a reverted L1 decision is picked up from conversation *and* written durably to the ledger, then re-opened at the next cycle's STEP 0 as fresh scope re-evaluated together with whatever was built on it. Every run ends with an **End-of-Run Report** (`RUN-SUMMARY-{date}.md` + final response, on all termination paths) in three parts — progress with evidence, deferred L2 decisions awaiting you, and self-made L1 decisions each with its trade-off and a one-line "to correct" — so proceed-first-correct-later stays safe.

**Self-unblock before parking** — a blocker only counts once you've tried to remove it. Before any `BLOCKED-ITEM` is parked, the cycle checks whether the credential/dependency is actually missing (look, don't assume), whether the "user-only decision" is already answered in CLAUDE.md / an accepted issue / a prior ledger entry, and whether a genuinely useful slice can proceed without the blocked part — parking only the residue, and recording what was tried. An assumed blocker is how a run stalls with budget left.

When primary work finishes early and cycles remain, run-cycle does not stop idle. It climbs a **Surplus-Cycle Value Ladder** — investing the remaining budget across the full software lifecycle: **① main loop → ② durable value** (research → refactoring → docs/assets) **→ ③ stability** (tests/monitoring → security/compliance → resilience) **→ ④ efficiency** (DevOps → DX). It acts only where the project shows a concrete signal; additive/low-risk work is done in-cycle, invasive/opinionated work is proposed for human decision. Doc-sync is the always-applicable floor of this ladder.

Before the single end-of-run commit, run-cycle runs a **lightweight release-readiness check** — version consistency across version-bearing files, CHANGELOG coverage, doc-sync, and an evidence block of the actual test/build/lint output. It verifies and packages only; tagging, publishing, and pushing stay with the human / CI. Skipped on `--no-commit` / `--dry-run`.

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

Per-repo settings live in `claudedocs/telemetry/config.json` (App Insights app id + thresholds);
the watermark and reports live under `claudedocs/telemetry/`. Issues follow the standard
`claudedocs/issues/` format. Requires `az login`.

### /iyu:backlog-discover

Discovers new backlog phases via the Backlog Generation Playbook — then **judges them**,
the way a team lead would. Convergent activities (vision-gap analysis, trend research,
benchmarking, academic/theory research scan, domain practice & norms watch,
appropriate-technology adoption verdicts, positioning review, telemetry-az reuse,
issue/community tracking, active dogfooding, code/security audits, developer-tooling gaps)
run on a persistent per-activity cadence, alongside emergent activities (pre-mortems,
subtraction sessions, chaos engineering, fresh-eyes onboarding, and more) selected by
self-diagnosing backlog symptoms from project history.

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
**deepen ladder** digs successively into tech health & tooling → theory & domain practice →
benchmarking & positioning. Findings must carry **run-evidence** (commands run + behavior
observed + steps walked) or they're dropped as guesses; concrete defects route to
`claudedocs/issues/`, only systemic/UX/vision gaps become proposal items.

```bash
/iyu:backlog-discover                          # Run all cadence-due activities + diagnosed emergent session(s)
/iyu:backlog-discover --modes vision-gap,web-trend  # Force specific activities regardless of cadence
/iyu:backlog-discover --symptom onboarding-friction # Force a specific emergent session
/iyu:backlog-discover --dry-run                # Report to chat only, no files, state unchanged
```

Fully independent of `/iyu:run-cycle` — `run-cycle` only *consumes* `ROADMAP.md`, this
command only *feeds* it. Every discovered item lands in a proposal document
(`claudedocs/backlog-discovery/proposal-YYYY-MM-DD.md`); **nothing merges into
`ROADMAP.md` automatically** — a human reviews the proposal and asks explicitly for
selected items to be adopted, per the mindset principle that new product direction is
never self-decided — ranking an item is not merging it. Cadence state
(`claudedocs/backlog-discovery/state.json`) tracks each of the playbook's 33 activities
independently, so a quarterly activity doesn't re-run every invocation and a stale
half-yearly one doesn't get silently skipped forever.

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
│   ├── mindset/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── backlog-discover/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── issue-triage/
│   │   └── SKILL.md
│   ├── issue/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── pr/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── run/
│   │   └── SKILL.md
│   ├── run-cycle/
│   │   └── SKILL.md
│   └── telemetry-az/
│       ├── SKILL.md
│       └── references/
└── README.md
```

## License

MIT
