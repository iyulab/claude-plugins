---
name: telemetry-az
description: Analyzes Azure Application Insights telemetry since the last run to surface defects, performance regressions, and feature-drop signals — then triages findings against project philosophy and files issues for threshold-crossing ones. Use when periodically reviewing production telemetry, e.g. "check app insights for new issues", "analyze telemetry regressions", "run the telemetry triage".
argument-hint: "[--since <ISO8601>] [--dry-run] [--no-issues]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, Bash(az *)
---

# Telemetry Triage (Azure Application Insights)

Analyze Application Insights telemetry **since the last run**, classify signals, run
issue-triage "1 → 10" latent discovery, and emit issues for threshold-crossing findings
plus a run report. Reusable across repositories — all repo-specific settings live in a
per-project config file, never in this skill.

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
  "baseline": { "requests": { "p50": 120, "p95": 480, "count": 10342 } }
}
```

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

Capture `<nowUtc>` first via a probe query (`print nowUtc = now()`); reuse that single value
for both `--end-time` and the new watermark. Then run each data query:

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

Three signal classes:

| Class | Source | Looks for |
|-------|--------|-----------|
| **Defects** | `exceptions`, failed `requests` | New exception types, error-rate spikes, top failing operations |
| **Perf regression** | `requests`, `dependencies` | p50/p95 duration worse than baseline by `perfRegressionPct` |
| **Feature drop** | `customEvents`, `pageViews` | Usage drop ≥ `usageDropPct`, funnel exits, vanished events |

Do not guess at telemetry you cannot retrieve — if a table is empty or a query errors,
record that explicitly rather than inferring.

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
files created. Under `--dry-run`, print this to chat instead of writing it.

### P7: Watermark (skip if `--dry-run`)

Update `.last-run.json`:
- `lastRunUtc` = the `now()` value captured in P2 (not the local clock)
- `baseline` = this run's perf/usage metrics, for next run's regression comparison

## Execution rules

1. **Incremental by default**: always resume from `.last-run.json`; never re-scan the full history unless `--since` says so.
2. **Config over hardcoding**: never embed appId/thresholds in this skill — they belong in the consumer's `config.json`.
3. **Bounded window**: capture `now()` once via the probe, pin it as the upper bound on every data query, and advance the watermark to exactly that value — so consecutive runs neither skip nor double-count events.
4. **Issue restraint**: only `issueMinRisk`+ findings become issue files; everything else lives in the report. Honors the "mentor, not noise" mindset.
5. **Honest gaps**: empty/errored queries are recorded as gaps, not inferred away.
6. **No silent re-scan**: if the watermark is advanced on a failed/partial run, say so in the report.
