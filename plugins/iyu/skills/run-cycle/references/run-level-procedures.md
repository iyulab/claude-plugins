# Run-level procedures — the value ladder, the end-of-run report, and the commit

**`SKILL.md` owns the per-cycle loop; this file owns what happens once per *run*.** The split is
deliberate: auto-compaction re-attaches only the first 5,000 tokens of a skill, so the procedures a
run needs once — at its end — are the ones that can safely live a file away, while the loop a cycle
needs every time stays inline. Read this file when a run reaches its end (any termination path), or
when a compacted context has lost the detail behind `SKILL.md`'s pointers.

Everything here is normative. `SKILL.md` keeps the one-line obligations and links here for the
procedure.

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

## End-of-Run Report

At run end — on **every** termination path (budget reached, HARD STOP, or early exhaustion) — synthesize one **report to the human** before the final commit. This is the "delegate reports back to their manager" moment: what got done, what was decided autonomously and can still be corrected, and what was escalated because it was not the delegate's to decide. Write it to `<root>/cycle-logs/RUN-SUMMARY-{YYYY-MM-DD}.md` (a run-level artifact, distinct from per-cycle logs — beside them so the Stop hook finds it in the directory it already resolved) **and** surface the same three parts in the final chat response. It is unconditional — a run has no mode in which the report is skipped. `{YYYY-MM-DD}` is the day the run **ends** — the day the report is written. A run that crosses midnight is dated by its last day, not its first; the hook does not judge the report by its filename date but by whether its content covers this run's cycles, so an earlier-dated file is never a reason to rename or duplicate it.

Each run block opens with one header line the Stop hook keys on — the hook has no session context (invariant: anything it needs is written into a header, as the cycle logs do with `Budget:`/`Start:`):

```
Run: cycles {Start}–{last completed} · ended {YYYY-MM-DD}
```

Three parts follow — draw them straight from the ledgers the cycles already maintained; this is a report, not a re-derivation:

1. **Progress / achievements** — what shipped this run, with STEP 3 evidence (test counts, build/lint result). Assertions are not evidence (rule 7.5).
2. **Deferred decisions (L2 — escalated, awaiting you)** — the Pending Human Decisions plus the full Blocked-on-Human ledger. Present them per **[decision-briefing.md](../../_shared/decision-briefing.md)**: a *resource-blocked* entry keeps the short blocked · what-was-tried · what-would-unblock form (§1), while a *decision-class* entry is **briefed** (§2) — the decision in one line, ≥2 observed options (one usually "defer"), the cross-lens read of how the leading ones differ, and a named recommendation with **what it locks in**. These are the decisions the run did not *act* on because the act was irreversible or yours alone; handing them over as bare questions puts the analysis back on the person furthest from the work. State the recommendation as the run's provisional decision, not as a question (§3: the owner is asked for resources and criteria, never for a pick) — what waits on you is the act, or, for an irreducible lens conflict, the **criterion** to decide it by (§1's criterion request). This is a *report-time* synthesis of ledgers that already exist — the per-cycle `BLOCKED-ITEM:` entry format is unchanged (§3), since those entries govern termination and must stay cheap to write. Nothing to defer is a valid and good outcome: write "None" rather than promoting an L1 decision to fill the section.
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

