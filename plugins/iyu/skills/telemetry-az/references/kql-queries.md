# Default KQL queries

## Contents

- [Watermark probe](#watermark-probe-always-run-first) — always run first
- [Class 1 — Defects](#class-1--defects)
- [Class 2 — Performance regression](#class-2--performance-regression)
- [Class 3 — Feature drop / usage decline](#class-3--feature-drop--usage-decline)
- [Class 4 — User analytics (run-over-run)](#class-4--user-analytics-run-over-run)
- [Optional — in-query anomaly detection](#optional--in-query-anomaly-detection)
- [Notes](#notes)

Baseline queries for the three signal classes. The time window is applied at the **CLI level**
via `--start-time`/`--end-time`, not inside the KQL — `az monitor app-insights query` defaults
to `--offset 1h` and honors the full window only when **both** time flags are passed. So the
queries below stay window-agnostic and the skill supplies bounds on the command line.

Run each via:

```bash
az monitor app-insights query --apps <appId> \
  --start-time "<lastRunUtc>" --end-time "<nowUtc>" \
  [--subscription <sub>] [--resource-group <rg>] \
  --analytics-query "<KQL>"
```

`--start-time` = `lastRunUtc` (from `.last-run.json` or `--since`; `ago(7d)`-equivalent on the
first run). `--end-time` = `nowUtc` from the probe below. Append any `config.customQueries`.
Tune aggregation to the project's traffic — high-traffic apps may want `summarize by bin(timestamp, 1h)`.

## Watermark probe (always run first)

Capture the authoritative current time once; reuse it for `--end-time`, the report, and
`.last-run.json` (run it without time flags — `now()` does not scan data). The probe also
emits `windowDays` **in-band** so the skill never needs shell date arithmetic (`allowed-tools`
is `Bash(az *)` — no `date`). User-analytics normalization divides by this value:

```kql
print nowUtc = now(), windowDays = (now() - datetime('<lastRunUtc>')) / 1d
```

On the **first run** (no `lastRunUtc`), skip the subtraction and use `windowDays = 7` to match
the 7-day default window.

## Class 1 — Defects

New / spiking exceptions, grouped by type and operation (carry affected-user count):

```kql
exceptions
| summarize count=count(), users=dcount(user_Id),
    firstSeen=min(timestamp), lastSeen=max(timestamp)
    by problemId, type, outerMessage, operation_Name
| order by count desc
| take 50
```

Failed requests and error rate by operation. Failure follows the App Insights convention
`success == false` (server failures are `resultCode >= 400`); `dcount(user_Id)` drives urgency:

```kql
requests
| summarize total=count(), failed=countif(success == false), users=dcount(user_Id),
    failRate=round(100.0 * countif(success == false) / count(), 2)
    by operation_Name, resultCode
| where failed > 0
| order by failed desc
| take 50
```

## Class 2 — Performance regression

Request duration percentiles (compare to `.last-run.json` baseline; flag when worse by
`thresholds.perfRegressionPct`). p95/p99 resist outlier noise better than the mean:

```kql
requests
| summarize p50=percentile(duration, 50), p95=percentile(duration, 95),
    p99=percentile(duration, 99), count=count(), users=dcount(user_Id)
    by operation_Name
| order by p95 desc
| take 50
```

Dependency latency (DB / downstream calls):

```kql
dependencies
| summarize p50=percentile(duration, 50), p95=percentile(duration, 95), count=count()
    by type, target, name
| order by p95 desc
| take 50
```

## Class 3 — Feature drop / usage decline

Custom event volume (compare to baseline; flag drops ≥ `thresholds.usageDropPct`, and events
present in baseline but absent now):

```kql
customEvents
| summarize count=count(), users=dcount(user_Id) by name
| order by count desc
| take 100
```

Page views (for UI-facing apps):

```kql
pageViews
| summarize views=count(), users=dcount(user_Id), avgDuration=avg(duration) by name
| order by views desc
| take 100
```

## Class 4 — User analytics (run-over-run)

Purpose 2: who is using the app and how, trended against prior runs. **Cadence caveat:** the
incremental window varies in length between runs, so raw counts are not comparable run-over-run.
Two complementary reads:

**(a) Window aggregates → normalize to per-day rates in the skill.** These use the incremental
`--start-time`/`--end-time` window; the skill divides each count by `windowDays` before storing
in `history[]` or comparing to the prior run.

Active users in the window (skill computes `usersPerDay = users / windowDays`):

```kql
requests
| summarize users=dcount(user_Id), sessions=dcount(session_Id), events=count()
```

Feature preference — custom events ranked (skill stores per-day rate + rank):

```kql
customEvents
| summarize count=count(), users=dcount(user_Id) by name
| order by count desc
| take 25
```

Page preference (UI-facing apps):

```kql
pageViews
| summarize views=count(), users=dcount(user_Id), avgDuration=avg(duration) by name
| order by views desc
| take 25
```

Engagement — events per session:

```kql
customEvents
| summarize events=count() by session_Id
| summarize eventsPerSession=avg(events), p50=percentile(events, 50)
```

**(b) Cadence-independent daily trend.** Run over a **fixed lookback** (e.g. 14 days) with a
daily bin, independent of the incremental window — this yields a real growth shape every run
even when the incremental window is a single day. This is the **one query that intentionally
overrides the watermark window**: pass `--offset 14d` and **no** `--start-time`/`--end-time`,
so the CLI scans `now() − 14d → now()` without any computed start (consistent with the
file's "time comes from CLI flags, not KQL" rule — the KQL itself stays window-agnostic):

```bash
az monitor app-insights query --apps <appId> --offset 14d \
  [--subscription <sub>] [--resource-group <rg>] --analytics-query "<KQL below>"
```

```kql
requests
| make-series users=dcount(user_Id) default=0 on timestamp step 1d
| mv-expand timestamp, users
| project timestamp, users=tolong(users)
```

**Trap — verify the scan window actually widened.** `make-series … default=0` pads missing
days with zeros. If `--offset 14d` did not widen the scan (e.g. the flags were dropped and the
default 1h offset applied), the series is silently padded to a *fake flat 14-day line* — no
error, just wrong. Confirm the series spans ~14 populated days before trusting its slope.

The skill reads the slope/direction of this series for the "↑ rising / ↓ falling / → flat"
trend, and cross-checks it against the per-day-rate delta from (a). Daily `dcount` is itself a
per-day rate, so this series needs no normalization. Rank shifts in features/pages are read by
diffing this run's ordering against `history[-1]` (risen / fallen / new / vanished).

## Optional — in-query anomaly detection

For projects with enough history, KQL's native time-series anomaly detection
(`series_decompose_anomalies`) flags deviations against a learned seasonal/trend baseline,
complementing the previous-run delta. Run over a longer lookback than the incremental window
(e.g. 14–30 days via `--start-time`/`--end-time`), so the model has signal:

```kql
requests
| make-series reqs=count() default=0 on timestamp step 1h by operation_Name
| extend (anomalies, score, baseline) = series_decompose_anomalies(reqs, 1.5)
| mv-expand timestamp, reqs, anomalies, score
| where anomalies != 0
| project operation_Name, timestamp, reqs, score, direction=anomalies
```

This mirrors what App Insights **Smart Detection** does server-side (Failure/Performance
Anomalies). Prefer cross-referencing an existing Smart Detection result when one covers the
window; use this query when you need anomaly signal on a custom metric or table.

## Notes

- Queries are window-agnostic; the window comes from `--start-time`/`--end-time` (see top).
  Do not add `where timestamp > …` — it cannot widen past the CLI offset and only adds noise.
  The **sole exception** is the Class 4(b) daily-trend query, which uses a fixed `--offset 14d`
  (no start/end) to read a cadence-independent lookback — the KQL still carries no time filter.
- If a table does not exist for the app (e.g. no `pageViews` for a backend service), the query
  errors — the skill records this as a gap, it is not a defect.
- Keep `take` bounded so a noisy window can't return an unbounded result set; raise it via a
  `customQueries` entry when a project genuinely needs deeper rows.
- `series_decompose_anomalies` needs sufficient history; on sparse data it yields few or no
  anomalies — that is not a defect.
