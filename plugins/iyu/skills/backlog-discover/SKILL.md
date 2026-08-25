---
name: backlog-discover
description: Discovers and judges new backlog phases for a project's ROADMAP.md like an owner-manager — runs a convergent/emergent research playbook (vision-gap, trend/competitive research, domain-practice and academic scans, stewardship inspection of dependencies/config/docs/repo hygiene, telemetry reuse, active dogfooding, plus emergent sessions rotated in by symptom) on a persistent per-activity cadence, then synthesizes the findings into a state-of-the-product diagnosis, an evidence-grounded importance ranking, and a dependency-ordered now/next/later staging toward the vision. Always produces a proposal document for human review; never merges into ROADMAP.md automatically.
when_to_use: Use when the backlog is running dry, when run-cycle reports the feature frontier exhausted, when dependencies or project configuration may have gone stale, or periodically to keep the roadmap fed with philosophy-aligned candidates. An empty or already-recently-run backlog is a deepen-signal — use the product, inspect what you own, then dig into tech-health, research, and positioning in that order — never a done-signal. Fully independent of run-cycle — run-cycle only consumes ROADMAP.md, this skill only feeds it.
argument-hint: "[--modes <comma-list>] [--symptom <name>] [--dry-run]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, WebFetch, TodoWrite, Bash
---

# Backlog Discovery

Run the [Backlog Generation Playbook](${CLAUDE_SKILL_DIR}/references/playbook.md) — a menu of convergent
(observe existing signals) and emergent (manufacture new signals) activities — to
discover new phase-level backlog candidates when a project's `ROADMAP.md` runs dry, or
periodically to keep it fed. This skill is **fully independent of `run-cycle`**:
`run-cycle` only ever *consumes* `ROADMAP.md`; this skill only ever *proposes additions*
to it, and never writes `ROADMAP.md` directly.

## Why this shape

`run-cycle` is the capable **employee** — given a scope, it executes, verifies, reports back. This
skill is the capable **owner-manager**: it decides *what deserves attention next* **and keeps what
already exists in good order**. That second half is the one a forward-only discovery skill loses,
which is why `stewardship-check` (관리 점검) is a short-cadence lane and the first rung of the
deepen ladder. Six properties follow — fixed named menu, per-activity cadence, symptom
self-diagnosis, never auto-merges, inspects rather than only imagines, judges rather than only
collects. Full rationale: [design-rationale.md](${CLAUDE_SKILL_DIR}/references/design-rationale.md).

## Parameters

- `--modes <comma-list>` — force specific activities to run **regardless of cadence**
  (e.g. `--modes vision-gap,benchmarking`). Escape hatch; default behavior is fully
  automatic due-checking (Preparation step 2 below).
- `--symptom <name>` — override the P2 self-diagnosis and force a specific emergent
  session by name, bypassing symptom detection.
- `--dry-run` — run through proposal generation (through P7) and print the proposal to
  chat; write no files and do not advance `state.json`. **This also bounds P3's active
  lanes**: `dogfooding` and `stewardship-check` drive the real project via `Bash`, so under
  `--dry-run` they take read-only paths only (inspect, query, list) and skip-with-reason
  anything that would install, upgrade, generate, or otherwise mutate the working tree. A
  dry run must not be able to change the project it is examining.

## File layout (consumer repo)

Paths below are relative to the repo's **docs root** (`<root>`). Resolve it per
**[continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §1** — the shared
definition every skill in this plugin uses. Resolve before reading or writing anything. Write the
proposal document in the session's language, per **§5**.

Landing in the same root as the others is not cosmetic: the roadmap this skill proposes into must
be the one `/iyu:run-cycle` consumes, and the telemetry lane below reads what `/iyu:telemetry-az`
wrote. A divergent root turns both into silent no-ops.

```
<root>/backlog-discovery/
├── state.json                    # per-activity cadence tracking + emergent rotation pointer
├── proposal-YYYY-MM-DD.md        # this run's discovery proposal (review target — see references/proposal-template.md)
└── INDEX.md                      # thin timeline index, one line per run (mirrors telemetry-az's TREND.md)
<root>/issues/
└── ISSUE-<target>-<timestamp>-<slug>.md   # incidental defects found during discovery — global issue-draft convention, unchanged
<root>/ROADMAP.md                 # read-only here — proposals never write it
```

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
- `lastItemSeq` — the highest item sequence number issued this run (item IDs, P4).

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

## Process

### P0: Clock, then state

**Establish `nowUtc` first — do not assume it.** Run `Bash: date -u +%Y-%m-%dT%H:%M:%SZ` and
use that single value for the whole invocation (P1 due-checks, P2 elapsed-time heuristics,
P8 writes). Never re-query mid-run: one clock keeps every cadence boundary consistent, and a
guessed timestamp written into `state.json` silently corrupts every future due-check — the
exact failure rule 6 ("cadence over guessing") exists to prevent. If `date` is unavailable,
fall back to the session's known date at 00:00Z and **say so in the proposal**.

Then read `<root>/backlog-discovery/state.json`. If missing, create it in-memory with the
schema above (all `lastRunUtc: null` / `[]`) — do not write it to disk yet (P8 writes it, and
only if not `--dry-run`).

### P1: Due-check

For each activity in `state.json.activities`:

```
elapsedDays = (nowUtc - lastRunUtc) in days   # Infinity if lastRunUtc is null
due = elapsedDays >= cadenceIntervalDays(activity.cadence)
```

Mark `due = true` unconditionally for any activity named in `--modes` (bypasses the
elapsed check). Collect the due set — this is what P3 executes.

**Thin/empty due-set is a deepen-signal, not a done-signal.** If cadence leaves few or no
activities due (e.g. this ran recently), do **not** return an empty proposal.

**The floor is not a ladder rung.** `dogfooding` is `always`-cadence, so it runs on *every*
invocation regardless of anything below — run it *actively* (P3's live-use path with a fresh
vision-anchored scenario), and let P2's round-robin still surface an emergent session. The
floor is what you always do; the ladder is what you do **when the floor came back thin**.
Conflating the two would make the ladder unreachable: an always-running first rung that
almost always yields something, combined with stop-at-first-material, means the deeper lanes
are never descended at all.

**Dry-backlog deepen ladder — engaged when the floor yields little.** The trigger condition
(backlog running dry) is exactly the case where search should widen, not narrow — so on
engagement, force **all four lanes below, plus `vision-gap`, due for this run regardless of
their individual cadence.** This deliberately differs from steady-state behavior (cadence governs
alone, per the schema note above): the "twenty shallow lanes" cost concern that governs steady
state does not apply here, because this mode only engages on the documented dry-backlog trigger,
not on every invocation.

| Lane | Force due | Question it answers |
|---|---|---|
| ① 관리 점검 | `stewardship-check` | 지금 이 프로젝트에서 낡았거나 어긋났거나 깨진 것은 무엇인가 |
| ② 기술 건전성 | `code-audit`, `tooling-development` | 부채는 어디에 쌓였고, 무엇이 우리를 느리게 하는가 |
| ③ 지식 (기술 + 도메인 양축) | `research-scan`, `domain-practice` → `appropriate-tech` | 이미 풀린 문제를 자체 발명으로 때우고 있지 않은가, 이 주제 영역의 현재 방법론에 비추어 우리 접근이 타당한가, 그 기술이 우리에게 맞는가 |
| ④ 시장 | `benchmarking` → `positioning-review` | 우리는 어디에 서 있고, 그 자리가 여전히 맞는가 |

Record in the proposal which lanes were forced and what each produced (including "empty").
Only after all four lanes come up empty is "이번 주기에는 도출할 항목이 없음" a grounded verdict
rather than an unexamined one — and even then, the P6 diagnosis is still written. An empty
backlog means "use the product, inspect what you own, then check the debt, the theory, and the
position", never "nothing to do".

### P1.5: Coverage floor (breadth, independent of the dry-backlog ladder)

Steady-state cadence means most invocations only touch the `always`/`sprint` floor —
quarterly/half-yearly activities (`web-trend`, `research-scan`, `benchmarking`, `domain-practice`,
`appropriate-tech`, `positioning-review`, `code-audit`, `security-compliance`,
`tooling-development`, `roadmap-decomposition`, `sunset-review`, `vision-gap`, `premortem`,
`sf-prototyping`, `archive-mining`) can go many runs without firing at all. This check exists so
that gap never goes on too long, without forcing all fifteen due every run — that cost concern is
still correct in steady state; the dry-backlog ladder already forces **eight of them** at once, but
only on its own much stronger (thin-output) trigger.

Union the `selected` field of the **last 3** `history[]` entries — the same window P2 already uses
for symptom-recency suppression, reused rather than duplicated. If **none** of the activities listed
above appear in that union, force the one among them with the oldest `lastRunUtc` due this run
(`due = true`, added to P1's due set, bypassing its own cadence check — same override mechanism
`--modes` already uses). If `history[]` has fewer than 3 entries, judge the check only against
whatever entries actually exist — do not force anything on a project's first or second-ever run,
where nothing has had the chance to be "missing" yet.

Skip forcing any activity the dry-backlog ladder (above) already forces due this run — for
`research-scan`, `benchmarking`, `domain-practice`, `appropriate-tech`, `positioning-review`,
`code-audit`, `tooling-development`, and `vision-gap`, the ladder's own force-due is a strict
superset of what this rule would add for them. The remaining seven of the fifteen (`web-trend`,
`security-compliance`, `roadmap-decomposition`, `sunset-review`, `premortem`, `sf-prototyping`,
`archive-mining`) are untouched by the ladder — this rule still applies to them even on a run where
the ladder engaged.

### P2: Symptom diagnosis (selects the emergent-pool activities to run alongside P1's due set)

If `--symptom <name>` was given, use it directly and skip detection. Otherwise, detect
using the heuristics below, checking **in this order** and stopping at first match
(a project can show multiple symptoms; treat the first-matched as this run's priority —
others surface on a later run).

**Recency suppression (required — this is what keeps the table from collapsing to row 1).**
Skip any symptom that appears as `symptom` in the **last 3 `history[]` entries**, and move on
to the next match. Only if *every* matching symptom is suppressed do you take the highest
one anyway (and say so in the proposal).

Without this, the table is decorative. Row 1's condition — zero removal/deprecation entries
across 8 logs — is true of almost every growing project, it is checked first, and
first-match-wins means it would win every run forever, leaving rows 2–7 and the 14-item
rotation pool as dead code. A one-run window is not enough either: rows 1 and 2 would simply
alternate while 3–7 still starve. `history[]` keeps 12 entries, so a 3-run window is free.

| Symptom | Heuristic (what to check) | Prescription (from playbook) |
|---|---|---|
| 기능만 쌓이고 제거가 없다 | Scan the last 8 `<root>/cycle-logs/cycle-*.md` (if present) plus `ROADMAP.md`'s revision history for any phase/entry describing removal, deprecation, or simplification. Zero found across ≥8 logs (or ≥8 `git log` entries touching `ROADMAP.md` if no cycle-logs exist) → symptom present. | `subtraction-session`, `sunset-review`, `inversion` |
| 리스크 대비가 부족하다 | `state.json.activities.security-compliance.lastRunUtc` is null or its elapsed time is ≥ 2× its cadence, AND no recent cycle-log Reflection section mentions security/resilience/observability work. | `premortem`, `chaos-engineering`, `red-team` |
| 온보딩/DX 불만이 감지된다 | Glob `<root>/issues/**` (open + `closed/`) and grep for onboarding/setup/confusing-error language; ≥2 matches → symptom present. | `error-message-audit`, `fresh-eyes-onboarding`, `ai-agent-usability` |
| 장기 방향이 흐릿하다 | `state.json.activities.vision-gap.lastRunUtc` elapsed ≥ 1.5× its cadence (severely overdue), OR — reading `ROADMAP.md`'s own revision history / `git log` over the date range spanned by the last 3 `INDEX.md` entries — the same phase names recur across that window without resolution. (`INDEX.md` itself only records run dates/counts/symptoms, not phase names; it just bounds which window of `ROADMAP.md` history to inspect.) | `working-backwards`, `sf-prototyping`, `constraint-removal` |
| 도메인 이해가 정체돼 있다 (조사가 SW 기술 축에 편중) | Sum `swTech` and `domain` across the last 3 `history[]` entries (or, if `history[]` is empty, grep the last 3 `proposal-*.md` for `탐구 축:` lines). `domain` is 0, or fewer than a quarter of the total → symptom present. The product's subject matter is being treated as settled while only its implementation is re-examined. | `research-scan` (도메인 축 필수), `domain-practice`, `cross-domain-borrowing` |
| 제품의 자리가 낡았다 (차별화 흐려짐) | `state.json.activities.positioning-review.lastRunUtc` is null or elapsed ≥ 2× its cadence, AND competitor-driven items dominate recent output — grep the last 3 `proposal-*.md` for `출처 활동:` lines and find that `벤치마킹`-sourced items are ≥ half of all items across them. (Chasing feature parity without re-examining where the product stands is exactly the drift this symptom names.) | `positioning-review`, `benchmarking`, `cross-domain-borrowing` |
| 아이디어 자체가 고갈됐다 | Both of the last 2 `history[]` entries have `itemCount` < 2. | `hackathon-exploration`, `cross-domain-borrowing`, `random-walk-reading`, `archive-mining` |
| 진행 중 흐름이 미완/파편적 | `STRANDS.md`'s `## 진행 중` entry has an accumulated count (cycles or sessions) well past this project's typical phase length (derive "typical" from `HISTORY.md`'s recent completed-phase durations, and cite it) → symptom present. Skip this row (not "no match") if `STRANDS.md` does not exist yet. | `strand-deepening` |
| 장기 흐름이 방치돼 있다 | `STRANDS.md`'s `## 중단됨` has an entry whose `마지막` entry is stale well past this skill's own run cadence (i.e. `backlog-discover` has run again since without that strand being touched) → symptom present. Skip this row if `STRANDS.md` does not exist yet or `## 중단됨` is empty. | `dormant-strand-review` |
| 미래 견인이 부족하다 (조사가 과거/현재 축에 편중) | Sum `past`, `present`, `future` across the last 3 `history[]` entries (or, if `history[]` is empty, this row cannot match yet). `future` is 0, or under a quarter of the three-way total → symptom present. | `vision-gap`, `working-backwards`, `sf-prototyping` |

If no symptom matches, select the **1–2 oldest-untried** items from
`emergentPool.rotationOrder` starting at `rotationPointer` (wrapping around the array),
i.e. plain round-robin — this guarantees every pool item eventually runs even absent a
diagnosed symptom.

**Prescription target may be individually cadenced.** Several prescriptions are not in
`emergentPool` — `vision-gap`, `sunset-review`, `premortem`, `sf-prototyping`, `archive-mining`,
`research-scan`, `domain-practice`, `benchmarking`, `positioning-review`, `strand-deepening`,
`dormant-strand-review` are tracked
individually in `state.json.activities` with their own cadence (the same list P1 already
due-checks). When a diagnosed symptom prescribes one of these, **treat the match as
forcing it due this run regardless of its own elapsed time** — a diagnosed symptom is a
stronger signal than mechanical cadence. When a prescription is a rotation-pool activity
instead, select it directly from the pool for this run (bypassing round-robin order, but
still advancing `rotationPointer` past it in P8 so it isn't re-selected redundantly by the
next round-robin pass).

Record the diagnosis (symptom name or `"none"`, and the selected activity id(s)) — this
feeds P8's `history[]` entry, next run's recency suppression, and the "아이디어 고갈" check.

### P2.5: Load prior proposals (dedupe basis)

Read the **two most recent** `<root>/backlog-discovery/proposal-*.md` and extract every
item's `id` + title + the gap it named. This list is the run's **known-items set**, and P4
checks each new finding against it.

If fewer than two prior proposals exist, the known-items set is whatever exists (possibly
empty) — not an error.

### P3: Execute

Run each due activity (from P1) and each selected emergent activity (from P2) using this
mapping. If an activity's required signal is absent, **skip it and record the reason** —
never fabricate the missing signal (mindset "no invention").

| Activity id | Execution |
|---|---|
| `vision-gap` | Compare CLAUDE.md/README's declared vision against the codebase (Glob/Grep survey) for unimplemented promises or drifted claims |
| `web-trend` | WebSearch/WebFetch for ecosystem trends, RFC/standard changes relevant to the project's domain |
| `benchmarking` | WebSearch for comparable/competing projects; build a feature/API/doc comparison — **and one row for how each models the problem domain** (what abstractions/vocabulary it commits to), not only what features it ships |
| `research-scan` | **Two axes, both mandatory** — attempt each and record a separate skip reason if one yields nothing. (a) **SW 기술 축**: papers/reference implementations/formal models for the algorithms and structures the project implements — target places where the code re-invents an already-solved problem. (b) **도메인 전문 축**: the literature and theory of the *subject matter the product serves* — established methods, models, and evaluation criteria of that field — target places where the product's approach to its own domain is naive, outdated, or contradicted by the field. Search the domain's own vocabulary, not the project's. Findings are phrased as "applying {theory/method} would fundamentally resolve {X}" |
| `domain-practice` | **도메인 실무·규범 추적** (the non-academic half of the domain axis). Track how practitioners of the product's subject area actually work now: the domain's own standards/spec bodies, normative or regulatory change, professional practice shifts, expert discourse, and the adjacent tools domain experts (not developers) reach for. Distinct from `web-trend` (software ecosystem) and `research-scan` (theory). Yields items about domain fitness — vocabulary, defaults, workflows, and outputs that no longer match how the field works |
| `appropriate-tech` | **Adoption judgment, not discovery.** Take the candidate technologies/approaches surfaced by `web-trend`, `research-scan`, `domain-practice`, and `benchmarking` this run (plus any still-unjudged candidates carried in earlier proposals) and rule on each: 성숙도, 팀·프로젝트 운용 역량, 운영·유지 비용, 되돌리기 비용, and above all **"does the problem it solves actually exist in this product?"** → `채택` / `시범` / `보류` / `기각`, each with a one-line reason. A `기각`/`보류` verdict is a recorded outcome, not a skip. If no candidate exists this run, skip-with-reason |
| `positioning-review` | (1) Write the current position from the project's own artifacts — 누구를 위한 것인가 / 무엇으로 선택받는가 / 무엇을 하지 않기로 했는가 (source: CLAUDE.md, README, declared non-goals). (2) Test that statement against evidence — the actual API surface, `benchmarking` output, `usage-analytics` if present. (3) Turn each mismatch into either a **position-recovery item** or a **position-adjustment proposal** (the latter is always `Discussion 필요`). Also flag feature additions that move the product toward parity at the cost of its stated differentiation |
| `telemetry-observability` | **Read-only.** Read `<root>/telemetry/report-*.md` + `.last-run.json` if present (do not call `az` or reimplement KQL). Skip + note "telemetry-az not configured" if `<root>/telemetry/config.json` is absent |
| `usage-analytics` | Same read-only reuse of `telemetry-az`'s purpose-2 (user analytics) report section |
| `issue-community` | `Bash(gh issue list)` / `gh discussion list` (if `gh` is authenticated) + scan `<root>/issues/**` for recurring themes. Skip + note "gh not authenticated" if it fails |
| `dogfooding` | **Active live use, not passive re-mining.** (1) Pick a **fresh, vision-anchored scenario** — a representative end-to-end task derived from a promise/claim in CLAUDE.md/README, and not one already in `state.json.activities.dogfooding.scenariosRun` (rotate to a new path each run). (2) **Actually drive it** through the project's own runnable surface via `Bash`: a CLI's real commands, a throwaway consumer script for a library, HTTP calls for a service. Where UI-automation tooling happens to be available in the environment, extend the walk-through to the UI; otherwise drive the library/API layer beneath the GUI and **skip-with-reason** the pure-GUI surface (never narrate UI friction you could not observe). (3) Record observed 기능/UI/UX/앱플로우 friction with **run-evidence** (commands run, behavior/output seen, steps walked) — this evidence is what makes the finding grounded observation, not invention. (4) *Also* fold in DX friction previously recorded in cycle-log Carry-Forward / Structural Improvement Proposal sections. If nothing in the project is Bash-drivable at all, skip-with-reason. |
| `stewardship-check` | **관리 점검 — the owner's walk-through of what they are responsible for.** Not a scan for future ideas: an inspection of what *already exists* and has quietly gone stale, broken, or inconsistent. Actually run the checks (`Bash`), do not read about them. Four sweeps, each skip-with-reason if N/A: **(a) 의존성 최신화** — `npm outdated` / `dotnet list package --outdated` / `pip list --outdated` / `cargo outdated` etc.; for each behind-package judge *upgradeable now* vs. *blocked by a breaking change* vs. *deprecated-or-EOL, needs replacement*, and check the runtime/SDK floor (declared `engines`, target framework, language version) against what is currently supported. **(b) 구성 점검** — build/CI/lint/format/test config, release pipeline, package metadata (license, repo URL, entry points, exports, published-file list), `.gitignore`, editor/tooling config: look for settings that no longer match reality, silently-disabled checks, and steps that would fail on a clean clone. **(c) 문서·링크 위생** — README/docs links, badges, version numbers, and quickstart commands verified against the current tree, not assumed. **(d) 저장소 위생** — orphan files, dead scripts, stale generated artifacts, config that references paths that no longer exist. Route by kind (rule 3): each concrete fixable defect → `<root>/issues/ISSUE-*.md`; only the systemic pattern behind them (e.g. "의존성 정책 부재", "릴리즈 파이프라인이 수동 단계에 의존") becomes a proposal item. Every finding carries the command run and its output — the same run-evidence bar as dogfooding |
| `code-audit` | Grep/Glob static scan for TODO/FIXME/deprecated markers + the project's own lint tooling via `Bash`. **Dependency currency belongs to `stewardship-check`; CVE/vulnerability to `security-compliance`** — this lane is about the shape of the code the team wrote |
| `security-compliance` | Dependency audit via `Bash` (e.g. `npm audit`, `dotnet list package --vulnerable`) + WebSearch for CVEs affecting declared dependencies |
| `tooling-development` | Mine the project's own history for **repeated manual work**: scan cycle logs / `git log` / CI config / scripts dir for procedures done by hand more than twice (release steps, fixture generation, log comparison, repro setup), slow or flaky verification loops, and one-off scripts rewritten each time. Each recurrence is a candidate to asset-ize as a script/harness/generator. Targets team throughput, not product durability — do not file refactoring items here |
| `roadmap-decomposition` | Re-derive epics/stories from any stated milestones/KPIs in CLAUDE.md/README against current `ROADMAP.md` phases |
| `sunset-review` | Grep for deprecated/legacy markers; compare the current feature list against the declared vision for "would not build today" candidates |
| `premortem` | Author a failure-mode narrative ("this project failed in 2 years because...") from the current architecture, worked backward into preventive tasks |
| `sf-prototyping` | Author a 5–10 year forward-looking domain scenario, backcast to near-term extension points worth seeding now |
| `archive-mining` | Glob `<root>/issues/closed/**` and old cycle-log Carry-Forwards for previously-declined ideas whose blocking condition may have since changed |
| `inversion` | Thought experiment: list what would most annoy users, then check which the project already does |
| `constraint-removal` | Thought experiment: design as if a named constraint (perf, back-compat) didn't exist, then extract the closeable gap |
| `subtraction-session` | Review the current public API/surface for what could be removed/simplified/deprecated |
| `working-backwards` | Author a future press-release + FAQ for a not-yet-built capability, then derive the tasks it implies |
| `extreme-persona` | Walk an extreme-scale or extreme-constraint persona's journey through the project, note where it breaks |
| `hackathon-exploration` | Free-form exploration pass outside current roadmap direction, noting anything surprising or worth pursuing |
| `random-walk-reading` | Read a handful of randomly-selected source files with fresh eyes, noting "why is this like this?" reactions |
| `error-message-audit` | Enumerate the project's actual error messages (grep for throw/raise/error strings) and evaluate whether each guides the user to a next action |
| `cross-domain-borrowing` | Deliberately borrow a pattern from an unrelated domain (games, finance, biology, urban planning) and sketch its application here |
| `chaos-engineering` | Reason through what happens if a dependency/service the project relies on fails mid-operation; note unhandled failure modes |
| `red-team` | Adopt an attacker/malicious-user mindset against the current surface; note successful "attack" paths as defense tasks |
| `fresh-eyes-onboarding` | Follow only the README/quickstart as a brand-new user would, noting every friction point without using prior codebase knowledge |
| `ai-agent-usability` | Follow only the project's documented API/docs (no source-diving) to accomplish a representative task, noting where the docs alone were insufficient |
| `dependency-horizon-scan` | Check declared dependencies' upstream release/commit cadence and maintainer count (via WebFetch to the package registry / repo) for decay signals |
| `strand-deepening` | **Guard first — only if actually stuck.** Skip-with-reason unless `STRANDS.md`'s `## 진행 중` entry's cumulative cycle count is already past this project's typical phase length (same test as the P2 row above — derive "typical" from `HISTORY.md` and cite it); a healthy in-flight strand is not a target. When the guard passes: **adjacent investigation around that specific stuck strand**, not a generic lane. Read the entry's strand name, trace what it actually touches in the codebase (the `ROADMAP.md` phase text, related files/APIs via Glob/Grep), and investigate what's adjacent and unaddressed — the surface the stuck strand itself implies but hasn't reached. Cite the strand name and its cumulative cycle count as the evidence for why this ran |
| `dormant-strand-review` | **Judgment, not discovery** — mirrors `appropriate-tech`'s "never leave a candidate un-judged" discipline. For each stale `STRANDS.md` `## 중단됨` entry: read what it was for (the `ROADMAP.md` phase or ad-hoc reason), check whether the strand that displaced it is itself now resolved or quiet, and rule `재점화` / `축소해서 재개` / `폐기`, each with a one-line reason. A `폐기` verdict only takes effect once a human accepts it at P9 and removes the `STRANDS.md` entry by hand — this activity is the only place the verdict gets made, and P9 is the only place it gets applied; hygiene never infers a retirement from an unreviewed proposal |

### P4: Tag & de-duplicate

For every discovered item, record: a **stable id**, source activity id, **value axis**
(exactly one of `비즈니스` / `기술건전성` / `사용자요청`), **inquiry axis** (exactly one of
`SW기술` / `도메인전문`), a 1–3 sentence rationale grounded in what was actually observed, and
a **phase-level** scope description (never cycle-numbered — consistent with `run-cycle`'s
roadmap-is-a-phase-backlog rule).

**Item id**: `BD-{YYYYMMDD}-{nn}`, `nn` restarting at 01 each run. The id is what makes an
item referable across proposals; without one, "is this the same gap we found last time?" has
no mechanical answer.

**Re-discovery check (against P2.5's known-items set)**: if the finding names a gap already
carried by a prior proposal, do **not** mint a new item. Keep the original id, mark it
`재발견 {n}회차 (최초: BD-…)`, and append **only the newly observed evidence**. Repeated
independent observation is not noise — it is exactly what should raise 증거 강도 and, through
P6, move the item to an earlier horizon on its own. Re-litigating it from zero each run
throws that signal away and buries the reviewer in near-duplicates.

The **inquiry axis** answers "which kind of expertise did this finding come from" and the
two are co-equal, not primary/secondary:

- `SW기술` — how the product is *built*: architecture, algorithms, APIs, dependencies,
  performance, tooling, developer experience.
- `도메인전문` — what the product is *for*: the concepts, methods, norms, vocabulary, and
  evaluation criteria of the subject area it serves, and whether the product's treatment
  of them is still correct.

Tag exactly one — forcing the judgment is the point. An all-`SW기술` proposal is a
legitimate outcome only if the domain axis was actually examined and produced nothing;
P6's diagnosis reports the split either way, and a persistent skew is what P2's
"도메인 이해가 정체돼 있다" symptom detects.

**시간축(temporal axis)** answers "does this run's activity mix pull toward the vision, or only
tend what already exists" — derived automatically from a **static activity→axis mapping**, never a
fourth manual tag (unlike value-axis and inquiry-axis, temporal orientation is strongly determined
by *which activity* produced a finding, not by the finding's content):

| 시간축 | 활동 |
|---|---|
| 과거(정리) | `stewardship-check`, `code-audit`, `security-compliance`, `tooling-development`, `sunset-review`, `subtraction-session`, `archive-mining`, `dormant-strand-review`, `strand-deepening` |
| 현재(위치) | `benchmarking`, `positioning-review`, `usage-analytics`, `telemetry-observability`, `issue-community`, `domain-practice`, `roadmap-decomposition`, `dogfooding` |
| 미래(견인) | `vision-gap`, `web-trend`, `research-scan`, `working-backwards`, `sf-prototyping`, `premortem`, `constraint-removal`, `appropriate-tech`, `inversion`, `cross-domain-borrowing`, `extreme-persona`, `hackathon-exploration`, `random-walk-reading`, `fresh-eyes-onboarding`, `ai-agent-usability`, `chaos-engineering`, `red-team`, `error-message-audit`, `dependency-horizon-scan` |

Every activity id in the P3 table must appear in exactly one row above — this is a completeness
requirement, not a suggestion; an activity added to P3 later must also be added here.

### P5: Philosophy alignment

Score each item using [philosophy-alignment-guide.md](${CLAUDE_SKILL_DIR}/../mindset/references/philosophy-alignment-guide.md)
(the same guide `issue`/`pr`/`telemetry-az` use). Low-scoring items are **kept but
flagged** "정렬 미흡" in the proposal — this skill never silently drops an item; exclusion
is a human call made when reviewing the proposal.

### P6: Synthesis — diagnose, rank, stage

Discovery produced a pile of grounded items. This step turns it into something a human can
decide on, using [synthesis-rubric.md](${CLAUDE_SKILL_DIR}/references/synthesis-rubric.md) for the scoring
tables and constraints. Three outputs, in order:

1. **현재 상태 진단** — four sentences from what was *actually observed this run*, one per
   axis: 비전 대비 지점 · 시장 내 자리 · **도메인 적합성** · 내부 체력. An axis with no
   observation this run is written "이번 주기 미관측", never filled with a guess. Close with
   a one-sentence verdict — "이 제품은 지금 〈상태〉이며, 다음 한 걸음은 〈방향〉이다" — which
   becomes the thesis the ranking is measured against.
2. **중요도 판정** — score each item 1–5 on 비전 기여도, 철학 정렬 (reuse P5's average — do
   not recompute, and **clamp it to 1–5**: the alignment guide's red-flag adjustments of
   −1/−2 can push the raw average below 1, which would silently distort the mean), and
   증거 강도; 가치 점수 is their mean. 비용·리스크 is scored separately and used only for
   placement. Every score cites the signal that justifies it.
3. **단계 구성** — place items on **지금 / 다음 / 나중** by 가치 × 비용, then apply the
   rubric's overriding constraints: dependency order beats score, 증거 강도 1–2 cannot sit
   in 지금, irreversible items are marked `Discussion 필요`, skew on any of the four axes
   (value, inquiry, temporal, or scale) is reported rather than silently rebalanced, and every
   horizon is populated or its emptiness is explained (synthesis-rubric.md §③ 제약 6).

**These horizons are an ordering, not a schedule.** No cycle numbers, no dates, no
durations — the same rule that keeps `run-cycle`'s roadmap a phase backlog applies here,
one layer further upstream. And ranking is not merging: rule 1 still holds for every item
in 지금.

If discovery produced no items at all (all four deepen-ladder lanes came up empty), output
① and the ladder record anyway — "무엇을 확인했고 왜 비어 있는가"는 그 자체로 보고할 내용이다.

### P7: Proposal document

Write `<root>/backlog-discovery/proposal-YYYY-MM-DD.md` using
[proposal-template.md](${CLAUDE_SKILL_DIR}/references/proposal-template.md). This is the **terminal output**
of this skill — `ROADMAP.md` is never written here. List skipped activities explicitly
with their skip reason (never silent).

Skip file writes entirely under `--dry-run`; print the filled template to chat instead.

### P8: State update (skip if `--dry-run`)

All timestamps written here are the single `nowUtc` established in P0 — never a fresh or
assumed value.

- Advance `lastRunUtc` to `nowUtc` for every activity that **actually ran** (P3), including
  ones that ran but were skipped internally for lacking a signal — a signal-less skip still
  counts as this cadence period's attempt, so it doesn't get retried every invocation until
  the next cadence boundary.
- **Exception — never advance a first-run-split deferral.** An activity deferred by P1's
  first-run split was never attempted at all, so its `lastRunUtc` stays `null` and it remains
  due next invocation. The two skip kinds are distinct: *attempted, no signal* advances the
  clock; *never attempted* does not.
- Advance `emergentPool.rotationPointer` past the selected pool items (wrap at array
  length); set their `lastRunUtc`.
- If active `dogfooding` ran, append the exercised scenario's slug to
  `activities.dogfooding.scenariosRun` (trim to the last ~8) so the next run rotates to a
  fresh path.
- Append **one** `history[]` entry for this run — `{ runUtc, symptom, selected, itemCount,
  business, techHealth, userRequest, swTech, domain, past, present, future, lastItemSeq }` — and trim
  to the last 12 (matches `telemetry-az`'s `history[]` convention). One entry per run, never parallel
  arrays needing a join.
- Append one line to `<root>/backlog-discovery/INDEX.md`:
  `{date} — {N} items ({business}/{techHealth}/{userRequest} · SW{swTech}/도메인{domain} · 과거{past}/현재{present}/미래{future}), 지금 {n}건, symptom: {name-or-none}`
  + a link to this run's proposal file. Create `INDEX.md` with a one-line header if it
  doesn't exist yet.

### P9: Merge — explicitly NOT part of this skill's automated flow

This skill's work ends at P8. When a human reviews `proposal-YYYY-MM-DD.md` and asks for
specific items to be adopted, add them to `ROADMAP.md`'s phase backlog by hand in that
follow-up turn, following `run-cycle`'s "phase backlog, not cycle-numbered" format. Do
not perform this step as part of a `/iyu:backlog-discover` invocation itself.

If a proposal carries a `dormant-strand-review` verdict of `폐기` and the human accepts it, remove
that `STRANDS.md` `## 중단됨` entry by hand in the same follow-up turn — this is the only path that
retires a strand (see `continuity-docs.md` §3).

## Execution rules

1. **No auto-merge, ever.** No invocation of this skill writes to `ROADMAP.md`. This is
   a deliberate, permanent asymmetry with `run-cycle`'s autonomous-eligible fast path.
2. **No invention — but active use is grounding, not invention.** A skipped activity's
   reason is always recorded in the proposal's "스킵된 활동" section — never backfilled with
   a guess. Actively *driving* the product and reporting what you observed is the opposite
   of invention: it manufactures real signal. The discriminator is **run-evidence** — any
   dogfooding finding must carry the commands run, the behavior/output observed, and the
   steps walked. A finding with no reproducible trace is a guess and is dropped, not
   filed. Narrating friction on a surface you could not actually drive (e.g. a GUI with no
   automation available) is the forbidden invention — skip-with-reason instead.
3. **Route findings by kind.** A concrete bug/defect surfaced incidentally during
   discovery — including a broken flow, a bad error message, or a UI glitch caught while
   dogfooding — is filed through the existing global `<root>/issues/ISSUE-*.md`
   convention, not folded into the discovery proposal. Only **systemic gaps, UX-direction
   shifts, and vision-shortfalls** (phase-level, not a single fixable defect) become
   proposal items.
4. **No major-version framing.** A discovered item that reads as breaking/major-scale is
   marked "Pending Human Decision" with a minor/patch-sized decomposition offered
   alongside it where feasible — never phrased as an implied major bump.
5. **Minimal intervention on telemetry.** This skill never re-implements `telemetry-az`'s
   Azure/KQL machinery; it only reads that skill's own output files.
6. **Cadence over guessing.** Whether an activity runs this invocation is decided by
   `state.json`, not by re-deriving "does this feel due" from scratch each time — the
   state file is the durable memory, matching `telemetry-az`'s `.last-run.json` pattern.
7. **Judgment is grounded too.** Rule 2's no-invention discipline applies to P6 exactly as
   it applies to discovery: every score cites the signal that justifies it, an unobserved
   diagnosis axis says "미관측" rather than guessing, and an item resting on a thought
   experiment alone (증거 강도 1–2) cannot be placed in 지금 — the response is to schedule
   the work that would produce evidence, not to promote the hunch. Ranking without cited
   grounds is invention wearing a number.
8. **Both inquiry axes, always.** `SW기술` and `도메인전문` are co-equal lanes, not a main
   one and a footnote. Domain-axis activities (`research-scan`'s domain half,
   `domain-practice`, `benchmarking`'s domain-modeling row) are attempted and reported —
   including their skip reasons — every run they are due. A proposal that is entirely
   `SW기술` must be able to say what the domain axis was asked and why it came up empty;
   "we only looked at the implementation" is the failure this rule names.
9. **Nothing gets re-litigated from scratch.** A technology or method surfaced by
   `web-trend`, `research-scan`, or `domain-practice` is a *candidate*, never a decision: it
   reaches the proposal only through `appropriate-tech`'s verdict, and a `기각`/`보류` verdict
   is recorded, not dropped. The same discipline applies to **every** item, not just
   technology candidates — a gap already carried by a recent proposal keeps its original id
   and gains new evidence (P2.5 + P4), rather than reappearing as a fresh near-duplicate.
   The record is the point: it is what lets repeated observation *accumulate* into a stronger
   case instead of resetting each run.
10. **Inspect what you already own.** Discovery is not only about what to build next; an
   owner is also answerable for what is already there. `stewardship-check` runs on a short
   cadence and is lane ① of the deepen ladder because outdated dependencies, drifted config,
   broken quickstarts, and orphaned files are *findings about the product's present*, and
   they degrade whether or not anyone is looking. Inspect by running the checks, not by
   reasoning about what they would probably say — the run-evidence bar in rule 2 applies here
   in full.
