# `state.json` — schema, cadence semantics, and the first-run split

**This file is the normative definition of `<root>/backlog-discovery/state.json`.** `SKILL.md` keeps
the one-line obligations (P0 reads it, P8 writes it); everything about its shape, the cadence
clock, the emergent rotation pointer, and the cold-start split lives here. Read it whenever you are
about to read or write the file, and whenever P1's due-check or P8's update needs the exact rule.

---

### `state.json` schema

```json
{
  "activities": {
    "vision-gap":              { "cadence": "half-yearly", "lastRunUtc": null },
    "web-trend":               { "cadence": "quarterly",   "lastRunUtc": null },
    "benchmarking":            { "cadence": "quarterly",   "lastRunUtc": null },
    "research-scan":           { "cadence": "half-yearly", "lastRunUtc": null },
    "domain-practice":         { "cadence": "quarterly",   "lastRunUtc": null },
    "appropriate-tech":        { "cadence": "quarterly",   "lastRunUtc": null },
    "positioning-review":      { "cadence": "quarterly",   "lastRunUtc": null },
    "telemetry-observability": { "cadence": "always",      "lastRunUtc": null },
    "usage-analytics":         { "cadence": "sprint",      "lastRunUtc": null },
    "issue-community":         { "cadence": "always",      "lastRunUtc": null },
    "dogfooding":              { "cadence": "always",      "lastRunUtc": null, "scenariosRun": [] },
    "stewardship-check":       { "cadence": "sprint",      "lastRunUtc": null },
    "strand-deepening":         { "cadence": "sprint",      "lastRunUtc": null },
    "dormant-strand-review":    { "cadence": "sprint",      "lastRunUtc": null },
    "code-audit":              { "cadence": "quarterly",   "lastRunUtc": null },
    "security-compliance":     { "cadence": "quarterly",   "lastRunUtc": null },
    "tooling-development":     { "cadence": "quarterly",   "lastRunUtc": null },
    "roadmap-decomposition":   { "cadence": "quarterly",   "lastRunUtc": null },
    "sunset-review":           { "cadence": "quarterly",   "lastRunUtc": null },
    "premortem":               { "cadence": "half-yearly", "lastRunUtc": null },
    "sf-prototyping":          { "cadence": "half-yearly", "lastRunUtc": null },
    "archive-mining":          { "cadence": "half-yearly", "lastRunUtc": null }
  },
  "emergentPool": {
    "rotationOrder": ["inversion", "constraint-removal", "subtraction-session",
      "working-backwards", "extreme-persona", "hackathon-exploration",
      "random-walk-reading", "error-message-audit", "cross-domain-borrowing",
      "chaos-engineering", "red-team", "fresh-eyes-onboarding", "ai-agent-usability",
      "dependency-horizon-scan"],
    "lastRunUtc": {},
    "rotationPointer": 0
  },
  "history": []
}
```

**`history[]` is the sole trend state** (last 12 runs, newest last) — one entry per run, not
three parallel arrays joined on a timestamp. This matches `telemetry-az`'s single-`history[]`
convention, and it is what lets P2's heuristics be a plain scan instead of a join:

```json
{ "runUtc": "...", "symptom": "기능만 쌓이고 제거가 없다", "selected": ["subtraction-session"],
  "itemCount": 7, "business": 3, "techHealth": 3, "userRequest": 1,
  "swTech": 6, "domain": 1, "past": 5, "present": 1, "future": 1, "lastItemSeq": 7 }
```

- `past` / `present` / `future` — per-run **시간축(temporal-axis)** counts (P4), derived
  automatically from a static activity→axis mapping (P4), never hand-tagged.
  This is what makes a "조사가 과거/현재 축에 편중" skew detectable across runs, the same way
  `swTech`/`domain` already makes the SW/domain skew detectable.
- `business` / `techHealth` / `userRequest` — per-run **value axis** counts (P4).
- `swTech` / `domain` — per-run **inquiry axis** counts (P4). This is what makes the
  "SW 기술 축으로만 조사하고 있다" skew detectable across runs rather than only within one.
- `symptom` / `selected` — P2's diagnosis, read back by P2 itself for its suppression window.
- `lastItemSeq` — the highest item sequence number issued this run (item IDs, P4). A later run on
  the same UTC date continues from it, so `nn` stays unique within the date.

`dogfooding.scenariosRun` is a rolling list (last ~8) of short slugs naming the
end-to-end scenarios already exercised, so each active-dogfooding run picks a *fresh*
vision-anchored path instead of re-walking the same one — this is what makes the
`always`-cadence dogfooding productive even on back-to-back runs.

Cadence intervals in days: `always` = 0, `sprint` = 14, `quarterly` = 91,
`half-yearly` = 182. `always` = 0 means "due whenever checked" — it is **not**
special-cased as unconditional; it goes through the same due-check as every other
activity (elapsed ≥ interval), it simply always satisfies that check.

On first run (no `state.json` file), every activity has `lastRunUtc: null`, which counts as
infinite elapsed time — **all 20 are due at once**. Running twenty lanes in one invocation
does not produce twenty findings; it produces twenty shallow passes, or a context wall.

**First-run split (applies only when `state.json` did not exist).** Run this ordered core of
convergent activities to completion and stop there (P2's one emergent session still runs on
top — the split bounds the due set, not the process):

1. `vision-gap` — establishes the thesis everything else is measured against
2. `dogfooding` — the always-floor, and the only source of 증거 강도 5
3. `stewardship-check` — the owner's walk-through: what is already broken or out of date
4. `issue-community` — signals someone already took the trouble to report
5. `code-audit` — where the debt sits

**Every** remaining activity is deferred — including `always`- and `sprint`-cadence ones such
as `telemetry-observability` and `usage-analytics`. The split bounds a cold start by *effort
available*, not by cadence, so "always = due whenever checked" (above) does not exempt an
activity from it; on a first run those data-driven lanes also have the least to read
(`telemetry-az` has typically never run yet). Each is recorded in the proposal's
스킵된 활동 section as `최초 실행 분할 — 다음 실행에서 수행` with its `lastRunUtc` left `null`,
so it is due again next invocation — and from the second run onward the split never applies,
so cadence governs alone. **This is a deliberate exception to P8's rule that a skipped activity still
advances `lastRunUtc`** — a split-deferred activity was never attempted, so advancing its
clock would silently swallow it for a whole cadence period. P8 restates this distinction.

The first proposal is still larger than a steady-state one (a genuine cold-start backlog
seed) — note that in the summary. What it must not be is twenty lanes touched and none
finished.
