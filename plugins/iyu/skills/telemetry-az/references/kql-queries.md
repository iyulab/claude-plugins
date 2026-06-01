# Default KQL queries

These are the baseline queries for the three signal classes. The skill runs the **watermark
probe first** to capture `nowUtc`, then injects both the window start
(`datetime('<lastRunUtc>')`, from `.last-run.json` or `--since`) and end
(`datetime('<nowUtc>')`) into every data query — so each query is bounded to
`[lastRunUtc, nowUtc]` and consecutive runs neither skip nor double-count events. The same
`nowUtc` is stored as the new watermark.

Run each via:

```bash
az monitor app-insights query --app <appId> \
  [--subscription <sub>] [--resource-group <rg>] \
  --analytics-query "<KQL>"
```

Append any `config.customQueries` after these. Tune window/aggregation to the project's
traffic volume — high-traffic apps may need `summarize` by hour rather than raw rows.

## Watermark probe (always run first)

Capture the authoritative current time once, reuse it for the report and `.last-run.json`:

```kql
print nowUtc = now()
```

## Class 1 — Defects

New / spiking exceptions in the window, grouped by type and operation:

```kql
let win = datetime('{{lastRunUtc}}');
let end = datetime('{{nowUtc}}');
exceptions
| where timestamp between (win .. end)
| summarize count=count(), firstSeen=min(timestamp), lastSeen=max(timestamp)
    by problemId, type, outerMessage, operation_Name
| order by count desc
| take 50
```

Failed requests (server errors) and error rate by operation:

```kql
let win = datetime('{{lastRunUtc}}');
let end = datetime('{{nowUtc}}');
requests
| where timestamp between (win .. end)
| summarize total=count(), failed=countif(success == false),
    failRate=round(100.0 * countif(success == false) / count(), 2)
    by operation_Name, resultCode
| where failed > 0
| order by failed desc
| take 50
```

## Class 2 — Performance regression

Request duration percentiles in the window (compare to `.last-run.json` baseline; flag when
worse by `thresholds.perfRegressionPct`):

```kql
let win = datetime('{{lastRunUtc}}');
let end = datetime('{{nowUtc}}');
requests
| where timestamp between (win .. end)
| summarize p50=percentile(duration, 50), p95=percentile(duration, 95),
    p99=percentile(duration, 99), count=count()
    by operation_Name
| order by p95 desc
| take 50
```

Dependency latency (DB / downstream calls):

```kql
let win = datetime('{{lastRunUtc}}');
let end = datetime('{{nowUtc}}');
dependencies
| where timestamp between (win .. end)
| summarize p50=percentile(duration, 50), p95=percentile(duration, 95), count=count()
    by type, target, name
| order by p95 desc
| take 50
```

## Class 3 — Feature drop / usage decline

Custom event volume in the window (compare to baseline; flag drops ≥ `thresholds.usageDropPct`,
and events present in baseline but absent now):

```kql
let win = datetime('{{lastRunUtc}}');
let end = datetime('{{nowUtc}}');
customEvents
| where timestamp between (win .. end)
| summarize count=count(), users=dcount(user_Id) by name
| order by count desc
| take 100
```

Page views (for UI-facing apps):

```kql
let win = datetime('{{lastRunUtc}}');
let end = datetime('{{nowUtc}}');
pageViews
| where timestamp between (win .. end)
| summarize views=count(), users=dcount(user_Id), avgDuration=avg(duration) by name
| order by views desc
| take 100
```

## Notes

- `{{lastRunUtc}}` and `{{nowUtc}}` are placeholders the skill replaces before sending each
  query. `{{nowUtc}}` comes from the watermark probe, captured once per run and reused as both
  the window upper bound and the stored watermark.
- For first runs (no watermark) the skill substitutes an `ago(7d)`-equivalent start for `win`
  and notes it; `end` is still the probe's `nowUtc`.
- If a table does not exist for the app (e.g. no `pageViews` for a backend service), the
  query errors — the skill records this as a gap, it is not a defect.
- Keep `take` bounded so a noisy window can't return an unbounded result set; raise it via a
  `customQueries` entry when a project genuinely needs deeper rows.
