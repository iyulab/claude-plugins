# Default KQL queries

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
`.last-run.json` (run it without time flags — `now()` does not scan data):

```kql
print nowUtc = now()
```

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
- If a table does not exist for the app (e.g. no `pageViews` for a backend service), the query
  errors — the skill records this as a gap, it is not a defect.
- Keep `take` bounded so a noisy window can't return an unbounded result set; raise it via a
  `customQueries` entry when a project genuinely needs deeper rows.
- `series_decompose_anomalies` needs sufficient history; on sparse data it yields few or no
  anomalies — that is not a defect.
