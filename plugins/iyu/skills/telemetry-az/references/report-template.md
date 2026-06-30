# Report template

Write to `claudedocs/telemetry/report-YYYY-MM-DD.md`. The report is the **full ledger** of a
run: it **leads with a run-over-run Trend section** (both purposes), then carries every finding
at every risk level, the triage summary, dedup/recurrence notes, and links to any issue files
created. If multiple runs happen on one day, append a new `## Run` section rather than
overwriting.

```markdown
# Telemetry Report — {YYYY-MM-DD}

## Run {HH:mm UTC}

- **Window**: {lastRunUtc} → {nowUtc captured in-band} ({windowDays} d)
- **App**: {targetPackage} (appId {…masked…})
- **Mode**: {full | --dry-run | --no-issues}
- **Auth**: {az account name / subscription}

### Trend (run-over-run)

Headline for both purposes. All count-derived metrics are **per-day rates** (cadence-normalized);
direction covers the last {n} run(s) — say "history insufficient" if fewer than ~3. Δ% is vs the
prior run (`history[-1]`).

**Purpose 1 — quality**

| Metric | This run | Prior | Δ% | {n}-run direction | Floor |
|--------|----------|-------|-----|-------------------|-------|
| Error rate /day | {12.3} | {10.1} | {+22%} | {↑ worsening / ↓ improving / → flat} | {ok / ⚠ >maxFailRatePct / —} |
| Exceptions /day | {45} | {44} | {+2%} | {→} | {—} |
| p95 (ms) | {480} | {median 410} | {+17%} | {↑} | {ok / ⚠ >maxP95Ms / —} |
| New exception types | {2} | {0} | — | {↑} | {—} |
| Issues filed | {3} | {1} | — | {↑} | {—} |
| Recurrences (reopened) | {1} | {0} | — | {↑} | {—} |

- **Read**: {one-line interpretation — is quality improving or degrading, and what drives it}
- **Floor column**: `ok` = bar set and met, `⚠ …` = absolute floor breached (a finding regardless
  of trend), `—` = bar not configured (`null`). With thin history this column, not Δ%, is the
  primary quality gate.

**Purpose 2 — usage**

| Metric | This run | Prior | Δ% | {n}-run direction |
|--------|----------|-------|-----|-------------------|
| Users /day | {412} | {405} | {+1.7%} | {↑ rising / ↓ falling / → flat} |
| Sessions /day | {95} | {92} | {+3%} | {↑} |
| Events / session | {7.2} | {7.0} | {+3%} | {→} |

- **Read**: {one-line interpretation; detail lives in User Analytics below}

### Summary

| Class | Signals | 🔴 | 🟠 | 🟡 | 🟢 | Issues filed |
|-------|---------|----|----|----|----|--------------|
| Defects | {n} | {n} | {n} | {n} | {n} | {n} |
| Perf regression | {n} | … | … | … | … | … |
| Feature drop | {n} | … | … | … | … | … |

### Findings

For each material signal:

#### {risk-emoji} {short title} — {class}

- **Surface**: {what telemetry showed — metric, counts, affected users (dcount), query}
- **Basis**: {relative regression vs N-run median | absolute floor (maxP95Ms/maxFailRatePct) | both — note the breached value vs the bar}
- **Root cause**: {Trigger} → {Component} → **{root cause}** → {Symptom}
- **Similar-pattern risk**: {where else this root cause may recur, or "none found"}
- **Recurrence**: {regression-of: link to closed issue + risk raised one level, or "new — not a recurrence"}
- **Surrounding gaps**: {missing instrumentation / alerts / docs / API gaps}
- **Prevention**: {test, guard, dashboard, alert that would catch it earlier}
- **Philosophy alignment**: {how the proposed action fits project scope/mission}
- **Decision**: {filed issue | logged only | dedup of existing | regression re-file | needs human}
- **Issue**: {link to claudedocs/issues/ISSUE-… or "—"}

### User Analytics

Run-over-run detail (purpose 2 — expands the usage block of the Trend section). All comparisons
use **per-day rates** (cadence-normalized); window length this run: {windowDays} d. Trend covers
the last {n} run(s) — say "history insufficient" if fewer than ~3.

**Active users**

- **Per-day users**: {usersPerDay} ({+/-Δ%} vs prior run) — trend {↑ rising | ↓ falling | → flat}
- **Daily series (14d)**: {brief shape, e.g. "steady ~410, dip on 06-12"}
- **Interpretation**: {most likely explanation — labeled a hypothesis if unproven}
- **Recommendation**: {concrete next step, or "—" if none warranted}

**Feature & page preferences**

| Item | Type | Per-day | Δ vs prior | Movement |
|------|------|---------|-----------|----------|
| {export} | feature | {88} | {+12%} | {risen | fallen | new | vanished} |
| {/dashboard} | page | {240} | {-4%} | {flat} |

- **Interpretation**: {what the shift in what users reach for suggests}
- **Recommendation**: {action, or "—"}

**Engagement**

- **Events/session**: {n} ({Δ vs prior}); **avg page duration**: {n} — {one-line read}

**Cross-links**: {any usage drop surfaced here that was handed to a Feature-drop (Class 3) finding — link that finding/issue; else "none — analytics is report-only"}

### Gaps & caveats

- {empty/errored queries, tables absent, partial runs, watermark notes, insufficient history,
  "median basis insufficient" when fewer than ~3 history entries}

### Dedup & recurrence

- {findings matched to already-open issues, not re-filed}
- {findings matched to a closed issue → re-filed as regression (link both)}

### Watermark

- Advanced to: {nowUtc} {or "NOT advanced (--dry-run / partial run)"}
- History: {pushed this run's full snapshot — defects/perf/issues + per-day user-analytics rates;
  now holding {n}/12 runs}. No separate baseline — the prior run is `history[-1]`.
- TREND.md: {appended this run's line | not touched (--dry-run)}
```

## Rules

- **Trend section leads.** A reader should see "is quality/usage trending up or down" before the
  per-finding ledger. Both purpose blocks are always present; mark "history insufficient" rather
  than fabricating a direction when fewer than ~3 runs exist.
- Mask the full `appId` in the report (show only a suffix); the unmasked id stays in `config.json`.
- Every issue file created in P5 must be linked from its finding here — the report is the index.
- A regression (recurrence of a closed issue) must link **both** the new issue and the closed one.
- Record the watermark decision explicitly; a reader must be able to tell whether the next run
  resumes cleanly or re-covers this window.
- Keep `TREND.md` in sync: one appended line per non-dry-run run, linking back to this report.
