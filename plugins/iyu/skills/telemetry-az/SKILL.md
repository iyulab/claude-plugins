---
name: telemetry-az
description: Analyzes Azure Application Insights telemetry since the last run to surface defects, performance regressions, and feature-drop signals — tracked run-over-run as a quality trend (error-rate/p95/issue-count direction over the last N runs, with closed-issue recurrence detection) — plus a run-over-run user-analytics report (active-user growth, feature/page preference shifts, engagement trends vs prior runs). It triages findings against project philosophy, files issues for threshold-crossing ones, and leads every report with a both-purpose Trend section backed by a 12-run history. Use when periodically reviewing production telemetry, e.g. "check app insights for new issues", "analyze telemetry regressions", "is quality trending up or down", "how is usage trending vs last run", "run the telemetry triage".
argument-hint: "[--since <ISO8601>] [--dry-run] [--no-issues]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, Bash(az *)
---

# Telemetry Triage (Azure Application Insights)

Analyze Application Insights telemetry **since the last run**, classify signals, run
issue-triage "1 → 10" latent discovery, and emit issues for threshold-crossing findings
plus a run report. Reusable across repositories — all repo-specific settings live in a
per-project config file, never in this skill.

The skill serves **two purposes**, kept distinct in the report:

1. **Defect discovery (primary)** — find gaps, defects, and improvement opportunities
   (the Defects / Perf-regression / Feature-drop signal classes; threshold-crossing
   findings become issues).
2. **User analytics** — a run-over-run reading of *who is using the app and how*:
   active-user growth/decline, which features and pages users prefer, and engagement
   trends, analyzed historically against prior runs. This is **report-only insight** — it
   never files issues. A usage *drop* that warrants an issue is already owned by the
   Feature-drop class (purpose 1); user analytics surfaces the trend and points there
   rather than re-deriving the threshold.

## Scoped Bash rationale

`allowed-tools` scopes Bash to `az *`. The current UTC watermark is captured in-band via
KQL `now()` inside the query, so no `date`/shell arithmetic is needed. This keeps the
surface narrow — consistent with `issue`/`pr` (`Bash(gh *)`), unlike the deliberately
unscoped `run`/`run-cycle` skills.

## Input

**Flags**:
- `--since <ISO8601>` — override the window start (otherwise read from `.last-run.json`)
- `--dry-run` — collect + triage + print report to chat, but write no files and do not advance the watermark
- `--no-issues` — write the report but create no issue files

## File layout (consumer repo)

```
claudedocs/telemetry/
├── config.json          # resource identity + thresholds + custom KQL
├── .last-run.json       # watermark: lastRunUtc + history[] (trend state, both purposes)
├── TREND.md             # thin timeline index: one line per run, links to each report
└── report-YYYY-MM-DD.md # full ledger of findings per run (leads with Trend section)
claudedocs/issues/
└── ISSUE-<target>-<ts>-<slug>.md   # threshold-crossing findings only
```

`config.json` schema:

```json
{
  "targetPackage": "<repo-name>",
  "appId": "<application-insights-application-id>",
  "subscription": "<sub-id>",
  "resourceGroup": "<rg>",
  "thresholds": {
    "issueMinRisk": "High",
    "perfRegressionPct": 20,
    "usageDropPct": 30,
    "absolute": {
      "maxFailRatePct": null,
      "maxP95Ms": null,
      "minUsersPerDay": null
    }
  },
  "customQueries": []
}
```

**Relative vs. absolute thresholds.** `perfRegressionPct` / `usageDropPct` are **relative** —
they measure *change* vs. prior runs and catch regressions. `thresholds.absolute` is an
**absolute floor** — it measures the *current state's health* regardless of trend, and catches
the failure modes relative comparison structurally misses: a *chronically* broken state (40%
fail rate that never spikes), the **first run** (no history to compare against — exactly when
defects are most likely), and slow boiling-frog drift that stays under the per-run relative
threshold while accumulating. The two are **OR-combined**: a signal is a finding if it crosses
*either* the relative regression bar *or* the absolute floor.

Every `absolute.*` field defaults to `null` = **disabled**. Absolute health bars are
project-specific (a 5 s p95 is fine for an internal batch tool, unacceptable for a checkout
API), so there is no universal default — the floor activates only for fields the consumer
sets. `minUsersPerDay` is optional and **purpose-2-adjacent**: a user count collapsing below an
absolute floor is still a Feature-drop (Class 3) finding, not a new issue class — it just gives
the relative `usageDropPct` an absolute backstop for the first-run/low-history case.

`.last-run.json` schema — `history[]` is the **single source of trend state for both
purposes** (there is no separate `baseline`; the prior run is just `history[-1]`):

```json
{
  "lastRunUtc": "2026-06-01T00:00:00Z",
  "history": [
    {
      "runUtc": "2026-06-01T00:00:00Z",
      "windowDays": 1.0,
      "mode": "full",

      "defects": {
        "errorRatePerDay": 12.3,
        "exceptionsPerDay": 45.0,
        "newExceptionTypes": 2,
        "affectedUsersPerDay": 8.1
      },
      "perf": { "p50": 120, "p95": 480, "p99": 900 },
      "issues": {
        "filed": 3,
        "byRisk": { "critical": 0, "high": 3, "medium": 5, "low": 2 },
        "reopened": 1
      },

      "usersPerDay": 412,
      "sessionsPerDay": 95,
      "eventsPerSession": 7.2,
      "topFeatures": [ { "name": "export", "perDay": 88 }, { "name": "search", "perDay": 61 } ],
      "topPages": [ { "name": "/dashboard", "perDay": 240 } ]
    }
  ]
}
```

A run snapshot carries **both purposes**: `defects`/`perf`/`issues` drive the purpose-1
(quality) trend, the user-analytics fields drive purpose-2. The prior-run comparison reads
`history[-1]`; the multi-run trend reads the whole array. No `baseline` object exists — it was
a duplicate of `history[-1]` and a second place to keep in sync.

**Backward compatibility.** If an existing `.last-run.json` predates this schema (has a
`baseline` object, or `history[]` entries lacking the `defects`/`perf`/`issues` blocks), treat
the missing purpose-1 fields as **absent history**: report "history insufficient" for the
quality trend this run, drop the stale `baseline` on the next watermark write, and start
populating the full snapshot from this run forward. Do not back-fill fabricated values.

**Normalization is mandatory.** The window is incremental, so consecutive runs cover
**different-length spans** (1 day if run daily, 7+ if weekly, 7 on the first run). Raw
`count`/`dcount` scale with window length, so comparing them run-over-run produces pure
cadence artifacts (a weekly run shows "+250% users" vs a daily one). Therefore every
**count-derived** field in `history[]` — both the purpose-1 defect rates (`errorRatePerDay`,
`exceptionsPerDay`, `affectedUsersPerDay`) and the purpose-2 user-analytics rates — stores a
**per-day rate** (`metric / windowDays`), never a raw count. `windowDays = (nowUtc −
lastRunUtc)` in days. Two field classes are **exempt** because they are already
window-independent: **percentile perf metrics** (`perf.p50/p95/p99`) and **counters that are
not volumes** (`newExceptionTypes`, `issues.*`). `history[]` keeps the **last 12 runs** (trim
older); it is the basis for the trend lines, while the cadence-independent daily-binned trend
query (Class 4) supplies the within-window shape every run.

## Process

### P0: Config & Auth

1. Read `claudedocs/telemetry/config.json`.
   - **Missing** → ask the user for `appId` (and `subscription`/`resourceGroup` if needed),
     infer `targetPackage` from the repo/directory name, write the file with default
     thresholds (including `absolute` with all fields `null` = disabled), then continue. Do not
     invent an `appId`. Mention that the consumer can later set `thresholds.absolute.*` to its
     own SLO bars (e.g. `maxFailRatePct`, `maxP95Ms`) to enable trend-independent health gating.
2. Verify Azure auth: `az account show`. If it fails, stop and instruct the user to run
   `az login` (suggest they type `! az login` in the prompt).
3. The `application-insights` CLI extension auto-installs on the first
   `az monitor app-insights` call (Azure CLI ≥ 2.71.0) — allow the one-time install prompt.

`config.json` is **non-secret** and may be committed: `appId`/`subscription`/`resourceGroup`
are resource identifiers, not credentials — access is authorized via `az login` / Azure AD,
not the app id. (Gitignore it only if your project prefers; the report still masks the appId.)

### P1: Window

- Read `.last-run.json`. Window start = `lastRunUtc` (or `--since` when provided).
- **First run** (no `.last-run.json`): default the window to the last 7 days and note this
  in the report.
- Window end = `now()` — captured **once** by the watermark probe (see
  [kql-queries.md](references/kql-queries.md)), then passed as `--end-time` on every data
  query, never from the local clock.

### P2: Collect

Capture `<nowUtc>` first via a probe query (`print nowUtc = now(), windowDays = …` — see
[kql-queries.md](references/kql-queries.md)); reuse `nowUtc` for both `--end-time` and the new
watermark, and `windowDays` for user-analytics normalization (P2b). Computing `windowDays`
in-band keeps the skill within `Bash(az *)` — no shell `date` needed. Then run each data query:

```bash
az monitor app-insights query --apps <appId> \
  --start-time "<lastRunUtc>" --end-time "<nowUtc>" \
  [--subscription <sub>] [--resource-group <rg>] \
  --analytics-query "<KQL>"
```

**Critical — pass the window as `--start-time` AND `--end-time` (both).**
`az monitor app-insights query` defaults to `--offset 1h` and ignores it only when **both**
time flags are supplied. A KQL `where timestamp` filter alone does NOT widen the window — the
service applies the offset first, so without these flags the query silently returns only the
last hour and the rest of `[lastRunUtc, nowUtc]` is lost. Use `--apps` (the canonical name;
`--app` works only via CLI prefix-matching and is fragile). Default KQL for the signal
classes lives in [kql-queries.md](references/kql-queries.md). Append any `config.customQueries`.

Four signal classes:

| Class | Source | Looks for | Purpose |
|-------|--------|-----------|---------|
| **Defects** | `exceptions`, failed `requests` | New exception types, error-rate spikes, top failing operations | Defect discovery |
| **Perf regression** | `requests`, `dependencies` | p50/p95 duration worse than the recent-run median by `perfRegressionPct` | Defect discovery |
| **Feature drop** | `customEvents`, `pageViews` | Usage drop ≥ `usageDropPct`, funnel exits, vanished events | Defect discovery |
| **User analytics** | `customEvents`, `pageViews`, `requests` | Active-user growth/decline, feature/page preference shifts, engagement trend — run-over-run | User analytics |

Classes 1–3 feed defect discovery — the P2c quality trend plus P3–P5 triage. Class 4 feeds the
user-analytics report (P2b → P6) and is **report-only — it never files issues**; a usage drop that crosses
`usageDropPct` is a Feature-drop (Class 3) finding, so Class 4 surfaces the trend and defers
the issue to Class 3 rather than double-filing. Do not guess at telemetry you cannot retrieve
— if a table is empty or a query errors, record that explicitly rather than inferring.

### P2b: User analytics (run-over-run)

Build the user-analytics reading — **purpose 2**. Run the Class 4 queries
([kql-queries.md](references/kql-queries.md)) and compare against history:

1. **Normalize.** Convert this run's active-user count and per-event/per-page counts to
   **per-day rates** (`metric / windowDays`, `windowDays = nowUtc − lastRunUtc` in days).
   All run-over-run comparison uses these rates, never raw counts (see schema note above).
2. **User growth/decline.** Compare `usersPerDay` to the prior run (`history[-1]`) for the
   delta %, and to the last up-to-12 runs for the **trend** (↑ rising / ↓ falling / → flat).
   Cross-check with the cadence-independent daily-binned series (Class 4) so the trend isn't
   an artifact of one noisy window.
3. **Preference shifts.** Diff this run's `topFeatures` / `topPages` rankings against
   `history[-1]`: mark each as **risen / fallen / new / vanished**. Rank is comparatively
   robust to window length; still report rates, not raw counts.
4. **Engagement.** Events-per-session / avg page duration vs prior run.
5. **Interpret + recommend.** For each material movement, write **지표 → 해석(가설) →
   실행권고**: the metric change, the most likely explanation, and a concrete next step
   (e.g. "feature X +40% per-day, likely new-user inflow → review onboarding for it").
   Per the mindset, a hypothesis with no telemetry to support it is labeled a hypothesis or
   recorded as a gap — never asserted as fact.

This section is **report-only — it never files issues**. If the analysis surfaces a usage
*drop* worth acting on (a core feature's per-day usage collapsing), that is a **Feature-drop
(Class 3)** finding: flag it for P3–P5 to triage under purpose 1, and cross-link it from here
rather than filing a second issue. Growth, preference shifts, and engagement never become
issues.

### P2c: Quality trend (run-over-run)

Build the purpose-1 reading — the **defect/perf/quality** trend, symmetric to P2b. This is the
trend layer the report leads with for purpose 1; the per-signal triage still happens in P3–P5.

1. **Normalize defect volumes.** Convert this run's failed-request count, exception count, and
   affected-user count to **per-day rates** (`/ windowDays`) → `errorRatePerDay`,
   `exceptionsPerDay`, `affectedUsersPerDay`. `newExceptionTypes` (problemIds absent from the
   prior run) and `perf.p50/p95/p99` are window-independent — store raw.
2. **Recent-run median for perf.** Compute the median of `perf.p95` over the last up-to-N runs
   in `history[]` (N = min(5, available)). **Class 2 perf-regression is judged against this
   median, not against `history[-1]` alone** — a single anomalously fast/slow prior run no
   longer fakes or masks a regression. Flag when this run's p95 exceeds the median by
   `thresholds.perfRegressionPct`. With fewer than ~3 history entries, fall back to
   `history[-1]` and note "median basis insufficient".
3. **Defect-rate trend.** Compare `errorRatePerDay` / `exceptionsPerDay` to `history[-1]` (Δ%)
   and to the last up-to-12 runs for direction (↑ worsening / ↓ improving / → flat). This is
   how purpose 1 answers "are errors trending up or down", which a single-run ledger cannot.
4. **Issue-rate trend.** Carry `issues.filed` / `issues.byRisk` from P5 (filled after issues are
   created) so the report can show issues-per-run over time. On a `--dry-run`/`--no-issues` run,
   record the would-be counts and mark them provisional.
5. **Absolute-floor check (trend-independent).** For each `thresholds.absolute.*` field the
   consumer **set** (non-`null`), flag a finding when the current value crosses it, *regardless
   of trend*:
   - `maxFailRatePct` — any operation whose `failRate` (Class 1 query) exceeds it
   - `maxP95Ms` — any operation whose `p95` (Class 2 query) exceeds it
   - `minUsersPerDay` — `usersPerDay` below it → hand to Class 3 (Feature-drop), per the schema note
   This check is **OR-combined** with the relative bars from steps 2–3: a signal is a finding if
   it crosses *either*. Crucially, it **runs even with empty/insufficient history** — the
   first-run and chronically-broken cases the relative bars miss. An absolute-floor violation
   carries `basis: absolute` so P3 can rank it (P3 escalates an absolute breach one level).

This step **classifies and trends; it does not file issues itself** — issue creation stays in
P5. Like P2b, with fewer than ~3 history entries say "history insufficient" for the *relative*
trend lines — but the absolute-floor check (step 5) still applies and is the primary defect
gate when history is thin.

### P3: Classify (Bug Risk)

Assign each signal a Bug Risk level — reuse the `issue-triage` scale:

| 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low |

- Critical/High: production-breaking errors, sharp regressions, feature outages
- Medium: elevated but non-breaking; Low: minor/noise
- Weigh **user impact** (`dcount(user_Id)`), not just event counts — a high failure rate hitting
  few users may rank below a smaller regression affecting many. Always carry affected-user counts.
- **Absolute-floor violations rank one level higher** than the same magnitude would as a
  relative regression: an absolute breach is not "got worse" but "is currently violating a
  health bar the project declared" — a standing SLO breach, more urgent than a one-run delta.
- **Merge, don't double-count.** If one operation trips *both* the relative regression bar and
  an absolute floor, it is **one finding** (use the higher risk), with both bases recorded
  (`basis: relative + absolute`). This mirrors the P5 dedup rule — one defect, one issue.

### P4: Triage — "1 → 10"

For each material signal, do not stop at the metric. Apply the issue-triage frame:

- **Surface**: what the telemetry literally shows
- **Root cause**: `[Trigger] → [Component] → [ROOT CAUSE] → [Symptom]` — build the chain, don't restate the symptom
- **Similar-pattern detection**: the same root cause likely recurs elsewhere — search for it
- **Surrounding gaps**: missing instrumentation, absent alerts, doc/API gaps the signal reveals
- **Prevention**: what would have caught this earlier (test, guard, dashboard, alert)

Use WebSearch for unfamiliar exceptions or regression patterns. Do not guess.

**Leverage built-in ML**: Application Insights Smart Detection already runs proactive ML
analysis — Failure Anomalies (failure-rate deviation vs the last 40 min / 7 days, with cluster
analysis of the common resultCode/operation/role) and Performance Anomalies (response-time and
dependency-duration regression vs an ~8-day baseline). If a detection exists for this window,
cross-reference it: its cluster analysis often hands you the root-cause characterization
directly. The skill's KQL complements Smart Detection — it does not replace it.

**Philosophy alignment** — decisions must align with the project, per the mindset:
read the project's CLAUDE.md / README and weigh each finding through
[philosophy-alignment-guide.md](../mindset/references/philosophy-alignment-guide.md).
A telemetry signal that conflicts with the project's intended scope is a finding about
*scope or instrumentation*, not an automatic backlog item.

### P5: Issues (skip if `--dry-run` or `--no-issues`)

Create an issue file **only** for findings at or above `config.thresholds.issueMinRisk`
(default High). Follow the global issue rule:

- Path: `claudedocs/issues/ISSUE-<targetPackage>-<YYYYMMDD-HHmm>-<slug>.md`
- Include: discovery context (which query/window surfaced it), root-cause chain,
  similar-pattern risk, Bug Risk level, and the proposed action with its philosophy rationale.
- Before creating, glob existing `claudedocs/issues/**` and skip duplicates of an
  already-open finding (same root cause) — note the dedup in the report instead.
- **Recurrence (regression) detection.** Also glob `claudedocs/issues/closed/**`. If this
  finding's root cause matches an **already-closed** issue, it is a **regression**, not a fresh
  defect: file a new issue, label it `regression-of: <closed-issue-file>`, raise its Bug Risk by
  one level (a defect that escaped a prior fix is more serious), and link the closed issue from
  the finding. Count these in `issues.reopened` (P2c) — a rising reopened count is itself a
  quality signal the trend surfaces.

### P6: Report

Write `claudedocs/telemetry/report-YYYY-MM-DD.md` using
[report-template.md](references/report-template.md). The report **leads with a Trend section**
(both purposes, run-over-run) and then carries the full ledger:

- **Trend (top)** — a compact run-over-run dashboard. Purpose-1 row block from P2c
  (errorRatePerDay, p95 vs recent-run median, exceptions, issues filed / reopened) and
  purpose-2 row block from P2b (usersPerDay, engagement). Each row: this run | prior run | Δ% |
  N-run direction (↑/↓/→). This is the answer to "is quality/usage trending up or down" that a
  single-run ledger could not give — it is the report's headline.
- **Full ledger (below)** — every finding (all risk levels), the triage summary, dedup notes,
  recurrence/regression links, and links to any issue files created.
- **User Analytics** — the P2b detail: growth/decline vs prior run + N-run trend, feature/page
  preference shifts, engagement, each as 지표 → 해석 → 실행권고.

Append/update `claudedocs/telemetry/TREND.md` — a thin index: one line per run
(`{date} — users/day {n} ({Δ}), errorRate/day {n} ({Δ}), issues {n}` + link to that run's
report). It is the entry point to the timeline so a reader never has to diff 12 report files by
hand. Under `--dry-run`, print the report to chat and do **not** touch `TREND.md`.

### P7: Watermark (skip if `--dry-run`)

Update `.last-run.json`:
- `lastRunUtc` = the `now()` value captured in P2 (not the local clock)
- `history` = push this run's **full snapshot** (`runUtc`, `windowDays`, `mode`, the purpose-1
  `defects`/`perf`/`issues` blocks from P2c/P5, and the purpose-2 `usersPerDay`/`sessionsPerDay`/
  `eventsPerSession`/`topFeatures`/`topPages` rates from P2b), then **trim to the last 12 runs**.
  This single array is the basis for both the P2c quality trend and the P2b user-analytics trend.
  Every count-derived field is a **per-day rate**; perf percentiles and the `issues`/`newExceptionTypes`
  counters stay raw (window-independent).
- There is **no `baseline`** to write — next run's prior-run comparison reads `history[-1]`, and
  perf regression reads the recent-N-run median. Keeping one array eliminates the
  baseline/history sync hazard.

## Execution rules

1. **Incremental by default**: always resume from `.last-run.json`; never re-scan the full history unless `--since` says so.
2. **Config over hardcoding**: never embed appId/thresholds in this skill — they belong in the consumer's `config.json`.
3. **Bounded window**: capture `now()` once via the probe, pin it as the upper bound on every data query, and advance the watermark to exactly that value — so consecutive runs neither skip nor double-count events.
4. **Issue restraint**: only `issueMinRisk`+ findings become issue files; everything else lives in the report. Honors the "mentor, not noise" mindset.
5. **Honest gaps**: empty/errored queries are recorded as gaps, not inferred away. The same holds for trends — with fewer than ~3 `history[]` entries, say "history insufficient" instead of drawing a trend line.
6. **No silent re-scan**: if the watermark is advanced on a failed/partial run, say so in the report.
7. **Cadence-normalized comparison (both purposes)**: every run-over-run comparison — purpose-1 defect rates (`errorRatePerDay`, `exceptionsPerDay`, `affectedUsersPerDay`) and purpose-2 user-analytics rates — uses per-day rates (`metric / windowDays`), never raw counts; the incremental window length varies between runs, so raw deltas are cadence artifacts. Exempt (window-independent): percentile perf metrics and non-volume counters (`newExceptionTypes`, `issues.*`).
8. **Analytics is report-only**: user-analytics movements (growth, preference shifts, engagement) inform the report and never file issues. A usage drop worth an issue is a Feature-drop (Class 3) finding — Class 4 flags and cross-links it, the Class 3 path files it, so a collapsing feature is never double-filed.
9. **Trend-first, both purposes**: the report leads with a run-over-run Trend section covering *both* purpose 1 (quality: error rate, p95-vs-median, issues/recurrences) and purpose 2 (usage). A single-run ledger cannot answer "is this trending up or down" — `history[]` is the single state that makes it possible, and `TREND.md` is its timeline index. With fewer than ~3 runs, say "history insufficient" rather than drawing a direction.
10. **Recurrence escalates**: a finding whose root cause matches an already-*closed* issue is a regression — re-file it, raise its Bug Risk one level, link the closed issue, and count it in `issues.reopened`. A defect that escaped a prior fix is more serious than a first sighting.
11. **One trend state, no baseline**: `history[]` is the sole trend store; the prior run is `history[-1]` and perf regression uses the recent-N-run median. Never reintroduce a separate `baseline` object — it duplicates `history[-1]` and invites sync drift.
12. **Relative AND absolute gates**: defect detection OR-combines the **relative** regression bars (trend-based — catch "got worse") with **absolute** floors (`thresholds.absolute` — catch "is currently unhealthy"). Absolute floors default to `null`/disabled (no universal value is right), activate only for fields the consumer sets, **run even with empty/insufficient history** (the first-run and chronically-broken cases relative bars structurally miss), and rank one level higher when breached. One operation tripping both gates is a single merged finding, not two.
