# Changelog — iyu plugin

All notable changes to the `iyu` plugin are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); the plugin uses `0.x`-style
pre-1.0 semantics where MINOR adds features (backward-compatible) and PATCH fixes
bugs or docs. MAJOR is never bumped automatically.

> History is reconstructed from git from v1.11.0 onward. Earlier versions live in
> the git log only.

## [1.19.0] — 2026-07-01

### Changed
- **Human blockers no longer end the run prematurely (`run-cycle`)** — human blockers are
  now split into two kinds that behave oppositely. A **run-fatal HARD STOP** (`HUMAN-NEEDED:`,
  a constitution conflict or structural invalidation that poisons *all* remaining work) still
  terminates the whole run. But an **item-level `BLOCKED-ITEM:`** (one scope needs a credential
  or a user-only decision, while other work stays independent) is *parked* in a new persistent
  **Blocked-on-Human ledger** and the cycle **falls through to the next unblocked candidate**
  instead of stopping. This fixes the observed early-termination where the first human blocker
  killed the entire run even though independent backlog / carry-forward / emergent work remained.

### Added
- **Blocked-on-Human ledger** — a persistent Carry-Forward bucket that accumulates parked
  item-level blockers (scope + blocker + what would unblock it), carried forward and re-checked
  at each cycle's STEP 0. Added to the trigger matrix (🔵 BLOCKED row), STEP 5 buckets, and the
  cycle-log template.
- **Termination redefined** — the run now terminates only when **every** remaining candidate
  (backlog phase, Carry-Forward item, autonomous-eligible emergent capability, ladder signal)
  is done or parked in the ledger — i.e. no unblocked autonomous work remains anywhere — AND
  the frontier + ladder are explicitly judged exhausted. The Stop hook, value ladder, and rules
  2 / 2.5 / 9 were updated so an item-level blocker never forces ALLOW while unblocked work
  exists. Backward-compatible: arguments unchanged.

## [1.16.0] — 2026-06-26

### Added
- **Emergent scope derivation (`run-cycle`)** — STEP 5 (Derive Next) is now an *active
  derivation* engine, not just a reactive record. After building a capability, the cycle
  derives the natural follow-on its own output implies — from three stakeholder lenses
  (**user / developer-maintainer / operator**) — and runs every candidate through a
  **derivation gate**: pattern-following completion within the project's declared role
  becomes autonomous next scope, while anything opening a new product direction, paradigm,
  dependency, or real trade-off is routed to a human-decision proposal (never self-decided).
  This addresses the observed failure where a cycle found no defects, saw a stable roadmap,
  wrote "Next-Cycle Scope: none", and terminated even though the capability it just built
  was visibly incomplete (e.g. file upload with no validation / multi-file / safety follow-up).

### Changed
- **Termination requires explicit frontier-exhaustion judgment** — early stop now demands a
  *stated* "feature frontier exhausted" judgment in the cycle log (across all three lenses),
  not an unfilled blank. The Stop hook treats an empty Emergent Next Capability line as
  "derivation skipped" (continue), and only allows termination when both the frontier and the
  value ladder are explicitly exhausted. Cycle-log template adds an **Emergent Next Capability**
  line; value-ladder track ① now counts an autonomous-eligible emergent capability as main-loop
  work. Backward-compatible: arguments unchanged.

## [1.15.0] — 2026-06-24

### Changed
- **Just-in-time scoping (`run-cycle`)** — the runner no longer plans all `N` cycles
  upfront. Concrete scope now exists for **one cycle at a time** (the current one); the
  roadmap is a phase-level backlog that **never knows cycle numbers**, and each cycle's
  STEP 5 decides the *next* cycle's scope once it knows what that cycle revealed. `N` is
  now explicitly a **ceiling, not a target** — never pre-partitioned into `N` scopes.
  This fixes an observed failure where `/iyu:run-cycle N` produced a binding `Cycle 1 = …,
  Cycle N = …` table under a "directional" label, collapsing the multi-turn structure back
  into a single turn. Work too large for a cycle (or deserving its own) is now promoted to
  the next cycle instead of being pre-assigned. Backward-compatible: arguments and cycle-log
  format are unchanged.

## [1.14.0] — 2026-06-24

### Added
- **Release-readiness check (`run-cycle`)** — a lightweight checklist absorbed into
  the end-of-run commit step (skipped on `--no-commit` / `--dry-run`). Verifies version
  consistency across version-bearing files, CHANGELOG coverage, doc-sync, and packages
  the actual verification output as an evidence block in the final cycle log. It verifies
  and packages only — it never tags, publishes, or pushes; the release stays with human/CI.

## [1.13.0] — 2026-06-24

Identity release — formalizes the plugin's constitution and generalizes the
adaptive cycle into a full software-lifecycle model.

### Added
- **Constitution (`mindset`)** — three governing principles made explicit:
  Minimal Intervention, Critical-but-Constructive (Rule of Law), Adaptive Iteration.
- **Rule of Law / amendment protocol** — human instructions are subordinate to the
  project constitution (CLAUDE.md / philosophy / architecture). A conflict triggers a
  documented amendment (revise the instruction *or* propose a concrete diff to the
  governing doc), never silent compliance and never unilateral override.
- **No-invention rule** — data not directly observed stays "unknown"; guesses are
  never presented as fact (`mindset`, `run-cycle` execution rule 7.5).
- **Surplus-Cycle Value Ladder (`run-cycle`)** — when primary work is exhausted and
  cycles remain, the run climbs a lifecycle ladder instead of stopping:
  ① main loop → ② durable value (research → refactoring → docs/assets)
  → ③ stability (tests/monitoring → security/compliance → resilience)
  → ④ efficiency (DevOps → DX). Signal-gated; additive work is done in-cycle,
  invasive work is proposed for human decision.
- **Regression back-flow** — a defect surfaced in any surplus track returns the run
  to the main loop; defects always outrank surplus value.
- **Durable-state-over-conversation** — cycles reconstruct state from on-disk logs so
  the run survives native context compaction without an external reset loop.
- **Evidence-based verification** — completion is proven by command output, not asserted.
- **`AGENTS.md`** added to the plan-discovery chain.
- **Reference tables of contents** added to long reference files (>100 lines).

### Changed
- `run-cycle` HARD STOP trigger now follows the constitutional amendment protocol.
- Early-termination doc-sync gate generalized into the value ladder (doc-sync is its floor).
- Plugin `keywords` consolidated as the single source, mirrored into the marketplace entry.

## [1.12.1] — 2026

### Added
- `run-cycle`: documentation-consistency gate before early termination.

## [1.12.0] — 2026

### Added
- `telemetry-az`: run-over-run user-analytics report (cadence-normalized, bounded history).

## [1.11.1] — 2026

### Fixed
- `telemetry-az`: corrected `az` CLI usage; strengthened analysis.

## [1.11.0] — 2026

### Added
- `telemetry-az`: Azure Application Insights telemetry triage skill — defects,
  performance regressions, feature-drop signals; files issues for threshold-crossing findings.
