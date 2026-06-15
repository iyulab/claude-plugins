# Report template

Write to `claudedocs/telemetry/report-YYYY-MM-DD.md`. The report is the **full ledger** of a
run: every finding at every risk level, the triage summary, dedup notes, and links to any
issue files created. If multiple runs happen on one day, append a new `## Run` section rather
than overwriting.

```markdown
# Telemetry Report — {YYYY-MM-DD}

## Run {HH:mm UTC}

- **Window**: {lastRunUtc} → {nowUtc captured in-band}
- **App**: {targetPackage} (appId {…masked…})
- **Mode**: {full | --dry-run | --no-issues}
- **Auth**: {az account name / subscription}

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
- **Root cause**: {Trigger} → {Component} → **{root cause}** → {Symptom}
- **Similar-pattern risk**: {where else this root cause may recur, or "none found"}
- **Surrounding gaps**: {missing instrumentation / alerts / docs / API gaps}
- **Prevention**: {test, guard, dashboard, alert that would catch it earlier}
- **Philosophy alignment**: {how the proposed action fits project scope/mission}
- **Decision**: {filed issue | logged only | dedup of existing | needs human}
- **Issue**: {link to claudedocs/issues/ISSUE-… or "—"}

### User Analytics

Run-over-run reading (purpose 2). All comparisons use **per-day rates** (cadence-normalized);
window length this run: {windowDays} d. Trend covers the last {n} run(s) — say "history
insufficient" if fewer than ~3.

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

- {empty/errored queries, tables absent, partial runs, watermark notes, insufficient history}

### Dedup

- {findings matched to already-open issues, not re-filed}

### Watermark

- Advanced to: {nowUtc} {or "NOT advanced (--dry-run / partial run)"}
- Baseline updated: {perf percentiles + per-day user-analytics rates for next comparison}
- History: {pushed run snapshot; now holding {n}/12 runs}
```

## Rules

- Mask the full `appId` in the report (show only a suffix); the unmasked id stays in `config.json`.
- Every issue file created in P5 must be linked from its finding here — the report is the index.
- Record the watermark decision explicitly; a reader must be able to tell whether the next run
  resumes cleanly or re-covers this window.
