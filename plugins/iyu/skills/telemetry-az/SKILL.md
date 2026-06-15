---
name: telemetry-az
description: Analyzes Azure Application Insights telemetry since the last run to surface defects, performance regressions, and feature-drop signals, plus a run-over-run user-analytics report (active-user growth, feature/page preference shifts, engagement trends vs prior runs) — then triages findings against project philosophy and files issues for threshold-crossing ones. Use when periodically reviewing production telemetry, e.g. "check app insights for new issues", "analyze telemetry regressions", "how is usage trending vs last run", "run the telemetry triage".
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
├── .last-run.json       # watermark: lastRunUtc + previous-run metric baseline
└── report-YYYY-MM-DD.md # full ledger of findings per run
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
  "thresholds": { "issueMinRisk": "High", "perfRegressionPct": 20, "usageDropPct": 30 },
  "customQueries": []
}
```

`.last-run.json` schema:

```json
{
  "lastRunUtc": "2026-06-01T00:00:00Z",
  "baseline": {
    "requests": { "p50": 120, "p95": 480, "count": 10342 },
    "usersPerDay": 412,
    "topFeatures": [ { "name": "export", "perDay": 88 }, { "name": "search", "perDay": 61 } ],
    "topPages": [ { "name": "/dashboard", "perDay": 240 } ]
  },
  "history": [
    {
      "runUtc": "2026-06-01T00:00:00Z",
      "windowDays": 1.0,
      "usersPerDay": 412,
      "topFeatures": [ { "name": "export", "perDay": 88 } ],
      "topPages": [ { "name": "/dashboard", "perDay": 240 } ]
    }
  ]
}
```

**Normalization is mandatory.** The window is incremental, so consecutive runs cover
**different-length spans** (1 day if run daily, 7+ if weekly, 7 on the first run). Raw
`count`/`dcount` scale with window length, so comparing them run-over-run produces pure
cadence artifacts (a weekly run shows "+250% users" vs a daily one). Therefore `history[]`
and the user-analytics `baseline` fields store **per-day rates** (`metric / windowDays`),
never raw counts. `windowDays = (nowUtc − lastRunUtc)` in days. Percentile perf metrics
(p50/p95) are window-independent and stay as raw values. `history[]` keeps the **last 12
runs** (trim older); it is the basis for the trend lines, while the cadence-independent
daily-binned trend query (Class 4) supplies the within-window shape every run.

## Process

### P0: Config & Auth

1. Read `claudedocs/telemetry/config.json`.
   - **Missing** → ask the user for `appId` (and `subscription`/`resourceGroup` if needed),
     infer `targetPackage` from the repo/directory name, write the file with default
     thresholds, then continue. Do not invent an `appId`.
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
`--app` works only via CLI prefix-matching and is fragile). Default KQL for the three signal
classes lives in [kql-queries.md](references/kql-queries.md). Append any `config.customQueries`.

Four signal classes:

| Class | Source | Looks for | Purpose |
|-------|--------|-----------|---------|
| **Defects** | `exceptions`, failed `requests` | New exception types, error-rate spikes, top failing operations | Defect discovery |
| **Perf regression** | `requests`, `dependencies` | p50/p95 duration worse than baseline by `perfRegressionPct` | Defect discovery |
| **Feature drop** | `customEvents`, `pageViews` | Usage drop ≥ `usageDropPct`, funnel exits, vanished events | Defect discovery |
| **User analytics** | `customEvents`, `pageViews`, `requests` | Active-user growth/decline, feature/page preference shifts, engagement trend — run-over-run | User analytics |

Classes 1–3 feed defect discovery (Process P3–P5). Class 4 feeds the user-analytics report
(P2b → P6) and is **report-only — it never files issues**; a usage drop that crosses
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

### P3: Classify (Bug Risk)

Assign each signal a Bug Risk level — reuse the `issue-triage` scale:

| 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low |

- Critical/High: production-breaking errors, sharp regressions, feature outages
- Medium: elevated but non-breaking; Low: minor/noise
- Weigh **user impact** (`dcount(user_Id)`), not just event counts — a high failure rate hitting
  few users may rank below a smaller regression affecting many. Always carry affected-user counts.

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

### P6: Report

Write `claudedocs/telemetry/report-YYYY-MM-DD.md` using
[report-template.md](references/report-template.md). The report is the **full ledger** —
every finding (all risk levels), the triage summary, dedup notes, and links to any issue
files created. It also carries the **User Analytics** section from P2b: user growth/decline
vs prior run + N-run trend, feature/page preference shifts, engagement, each as
지표 → 해석 → 실행권고. Under `--dry-run`, print this to chat instead of writing it.

### P7: Watermark (skip if `--dry-run`)

Update `.last-run.json`:
- `lastRunUtc` = the `now()` value captured in P2 (not the local clock)
- `baseline` = this run's perf/usage metrics, for next run's regression comparison.
  Perf percentiles stay as raw values; user-analytics fields (`usersPerDay`, `topFeatures`,
  `topPages`) are stored as **per-day rates** so the next run's delta is cadence-valid.
- `history` = push this run's snapshot (`runUtc`, `windowDays`, per-day user-analytics rates),
  then **trim to the last 12 runs**. This is the basis for P2b trend lines.

## Execution rules

1. **Incremental by default**: always resume from `.last-run.json`; never re-scan the full history unless `--since` says so.
2. **Config over hardcoding**: never embed appId/thresholds in this skill — they belong in the consumer's `config.json`.
3. **Bounded window**: capture `now()` once via the probe, pin it as the upper bound on every data query, and advance the watermark to exactly that value — so consecutive runs neither skip nor double-count events.
4. **Issue restraint**: only `issueMinRisk`+ findings become issue files; everything else lives in the report. Honors the "mentor, not noise" mindset.
5. **Honest gaps**: empty/errored queries are recorded as gaps, not inferred away. The same holds for trends — with fewer than ~3 `history[]` entries, say "history insufficient" instead of drawing a trend line.
6. **No silent re-scan**: if the watermark is advanced on a failed/partial run, say so in the report.
7. **Cadence-normalized analytics**: all run-over-run user-analytics comparison uses per-day rates (`metric / windowDays`), never raw counts — the incremental window length varies between runs, so raw deltas are cadence artifacts. Percentile perf metrics are exempt (window-independent).
8. **Analytics is report-only**: user-analytics movements (growth, preference shifts, engagement) inform the report and never file issues. A usage drop worth an issue is a Feature-drop (Class 3) finding — Class 4 flags and cross-links it, the Class 3 path files it, so a collapsing feature is never double-filed.
