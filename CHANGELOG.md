# Changelog — iyu plugin

All notable changes to the `iyu` plugin are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); the plugin uses `0.x`-style
pre-1.0 semantics where MINOR adds features (backward-compatible) and PATCH fixes
bugs or docs. MAJOR is never bumped automatically.

> History is reconstructed from git from v1.11.0 onward. Earlier versions live in
> the git log only.

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
