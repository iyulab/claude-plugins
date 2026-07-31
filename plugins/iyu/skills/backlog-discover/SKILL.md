---
name: backlog-discover
description: Adaptively discovers new backlog phases for a project's ROADMAP.md and then judges them like a team lead — running a convergent/emergent research playbook (vision-gap analysis, trend/competitive research, academic-research scan, appropriate-technology adoption judgment, positioning review, telemetry-az output reuse, voice-of-customer mining, technical-debt audits, developer-tooling gaps, active dogfooding, plus emergent techniques like pre-mortems, subtraction sessions, chaos engineering, fresh-eyes onboarding) on a persistent per-activity cadence, self-diagnosing which emergent session to rotate in when the backlog feels stale, then synthesizing the findings into a state-of-the-product diagnosis, an evidence-grounded importance ranking, and a dependency-ordered now/next/later staging toward the vision. Always produces a proposal document for human review; never merges into ROADMAP.md automatically. Use when the backlog is running dry, when run-cycle reports the feature frontier exhausted, or periodically to keep the roadmap fed with fresh, philosophy-aligned candidates. An empty or already-recently-run backlog is a deepen-signal (use the product, then dig into tech-health, research, and positioning in that order), never a done-signal. Fully independent of run-cycle — run-cycle only consumes ROADMAP.md, this skill only feeds it.
argument-hint: "[--modes <comma-list>] [--symptom <name>] [--dry-run]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, WebFetch, TodoWrite, Bash
---

# Backlog Discovery

Run the [Backlog Generation Playbook](references/playbook.md) — a menu of convergent
(observe existing signals) and emergent (manufacture new signals) activities — to
discover new phase-level backlog candidates when a project's `ROADMAP.md` runs dry, or
periodically to keep it fed. This skill is **fully independent of `run-cycle`**:
`run-cycle` only ever *consumes* `ROADMAP.md`; this skill only ever *proposes additions*
to it, and never writes `ROADMAP.md` directly.

## Why this shape

A generic "brainstorm new features" prompt either runs the same handful of ideas every
time (stale) or invents ungrounded scope (mindset violation — "no invention", no
autonomous new product direction). This skill instead:

1. Draws from a **fixed, named menu** (the playbook) so activities are legible and
   repeatable, not reinvented per run.
2. **Tracks cadence per activity** in a persistent state file, so a quarterly activity
   doesn't re-run every invocation and a stale half-yearly one doesn't get forgotten.
3. **Self-diagnoses** which emergent (deliberately provocative) session to run from
   observable symptoms in the project's own history — not a random pick.
4. **Never auto-merges.** Every discovered item — however well-argued — lands in a
   proposal document. A human decides what enters `ROADMAP.md`. This is a stricter bar
   than `run-cycle`'s in-cycle "autonomous-eligible" fast path, because this skill's
   discoveries are external and speculative (web trends, competitor features, deliberately
   engineered provocations) rather than a narrow "what does the diff I just wrote imply."
5. **Judges, not just collects.** Handing over 40 tagged findings is not a finished job —
   it moves the whole burden of "what matters, in what order, and why" onto the reader.
   P6 closes that gap: a state-of-the-product **diagnosis**, an evidence-grounded
   **importance ranking**, and a dependency-ordered **staging** toward the vision. Judgment
   is still a proposal, never a decision — ranking an item is not merging it (rule 1).

## Unscoped Bash rationale

`allowed-tools` includes `Bash` without scope, matching `run-cycle`. Activities span
arbitrary project-specific commands (dependency/outdated audits, `gh issue list`,
`git log` mining, package-registry lookups for the dependency-horizon-scan activity)
across unknown project types — scoping would require per-project edits. In practice this
skill is read-mostly (research + analysis, not code changes), so the blast radius of the
unscoped surface is smaller than `run-cycle`'s, but the same justification applies.

## Parameters

- `--modes <comma-list>` — force specific activities to run **regardless of cadence**
  (e.g. `--modes vision-gap,benchmarking`). Escape hatch; default behavior is fully
  automatic due-checking (Preparation step 2 below).
- `--symptom <name>` — override the P2 self-diagnosis and force a specific emergent
  session by name, bypassing symptom detection.
- `--dry-run` — run through proposal generation (through P7) and print the proposal to
  chat; write no files and do not advance `state.json`.

## File layout (consumer repo)

```
claudedocs/backlog-discovery/
├── state.json                    # per-activity cadence tracking + emergent rotation pointer
├── proposal-YYYY-MM-DD.md        # this run's discovery proposal (review target — see references/proposal-template.md)
└── INDEX.md                      # thin timeline index, one line per run (mirrors telemetry-az's TREND.md)
claudedocs/issues/
└── ISSUE-<target>-<timestamp>-<slug>.md   # incidental defects found during discovery — global issue-draft convention, unchanged
```

### `state.json` schema

```json
{
  "activities": {
    "vision-gap":             { "cadence": "half-yearly", "lastRunUtc": null },
    "web-trend":               { "cadence": "quarterly",   "lastRunUtc": null },
    "benchmarking":            { "cadence": "quarterly",   "lastRunUtc": null },
    "research-scan":           { "cadence": "half-yearly", "lastRunUtc": null },
    "domain-practice":         { "cadence": "quarterly",   "lastRunUtc": null },
    "appropriate-tech":        { "cadence": "quarterly",   "lastRunUtc": null },
    "positioning-review":      { "cadence": "quarterly",   "lastRunUtc": null },
    "telemetry-observability": { "cadence": "always",       "lastRunUtc": null },
    "usage-analytics":         { "cadence": "sprint",       "lastRunUtc": null },
    "issue-community":         { "cadence": "always",       "lastRunUtc": null },
    "dogfooding":              { "cadence": "always",       "lastRunUtc": null, "scenariosRun": [] },
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
  "diagnosisHistory": [],
  "valueAxisHistory": [],
  "inquiryAxisHistory": []
}
```

`inquiryAxisHistory` entries are `{ runUtc, swTech, domain }` — the per-run count of items
tagged on each **inquiry axis** (P4). It is what makes the "SW 기술 축으로만 조사하고 있다"
skew detectable across runs rather than only within one.

`dogfooding.scenariosRun` is a rolling list (last ~8) of short slugs naming the
end-to-end scenarios already exercised, so each active-dogfooding run picks a *fresh*
vision-anchored path instead of re-walking the same one — this is what makes the
`always`-cadence dogfooding productive even on back-to-back runs.

Cadence intervals in days: `always` = 0, `sprint` = 14, `quarterly` = 91,
`half-yearly` = 182. `always` = 0 means "due whenever checked" — it is **not**
special-cased as unconditional; it goes through the same due-check as every other
activity (elapsed ≥ interval), it simply always satisfies that check.

On first run (no `state.json` file), every explicitly-cadenced activity has
`lastRunUtc: null`, which counts as infinite elapsed time — every activity listed in
`activities` is due: all of playbook §1–5 (including the domain-axis, tooling, and
positioning lanes) plus the four individually-tracked Part B activities (`sunset-review`,
`premortem`, `sf-prototyping`, `archive-mining` — three half-yearly, `sunset-review`
quarterly). This produces a deliberately larger first proposal (a genuine cold-start
backlog seed) — **note this explicitly** in the proposal's summary rather than silently
truncating it.

## Process

### P0: State

Read `claudedocs/backlog-discovery/state.json`. If missing, create it in-memory with the
schema above (all `lastRunUtc: null` / `{}` / `[]`) — do not write it to disk yet (P8
writes it, and only if not `--dry-run`).

### P1: Due-check

For each activity in `state.json.activities`:

```
elapsedDays = (nowUtc - lastRunUtc) in days   # Infinity if lastRunUtc is null
due = elapsedDays >= cadenceIntervalDays(activity.cadence)
```

Mark `due = true` unconditionally for any activity named in `--modes` (bypasses the
elapsed check). Collect the due set — this is what P3 executes.

**Thin/empty due-set is a deepen-signal, not a done-signal.** If cadence leaves few or no
activities due (e.g. this ran recently), do **not** return an empty proposal. `dogfooding`
is `always`-cadence and therefore always in the due set — treat that as the floor: run it
*actively* (P3's active live-use path with a fresh vision-anchored scenario), and let
P2's round-robin still surface an emergent session.

**Dry-backlog deepen ladder.** When the floor still yields little, dig into progressively
deeper (and more expensive) lanes in this order, forcing the named activities due for this
run regardless of their cadence, and stopping at the first lane that produces material:

| Lane | Force due | Question it answers |
|---|---|---|
| ① 실사용 | `dogfooding` (always-floor) | 새 시나리오로 직접 써보면 무엇이 걸리는가 |
| ② 기술 건전성 | `code-audit`, `tooling-development` | 부채는 어디에 쌓였고, 무엇이 우리를 느리게 하는가 |
| ③ 지식 (기술 + 도메인 양축) | `research-scan`, `domain-practice` → `appropriate-tech` | 이미 풀린 문제를 자체 발명으로 때우고 있지 않은가, 이 주제 영역의 현재 방법론에 비추어 우리 접근이 타당한가, 그 기술이 우리에게 맞는가 |
| ④ 시장 | `benchmarking` → `positioning-review` | 우리는 어디에 서 있고, 그 자리가 여전히 맞는가 |

Record in the proposal which lanes were descended and why. Only after lane ④ also comes up
empty is "이번 주기에는 도출할 항목이 없음" a grounded verdict rather than an unexamined one —
and even then, the P6 diagnosis is still written. An empty backlog means "use the product,
then check the debt, the theory, and the position", never "nothing to do".

### P2: Symptom diagnosis (selects the emergent-pool activities to run alongside P1's due set)

If `--symptom <name>` was given, use it directly and skip detection. Otherwise, detect
using the heuristics below, checking **in this order** and stopping at first match
(a project can show multiple symptoms; treat the first-matched as this run's priority —
others surface on a later run):

| Symptom | Heuristic (what to check) | Prescription (from playbook §6–10) |
|---|---|---|
| 기능만 쌓이고 제거가 없다 | Scan the last 8 `claudedocs/cycle-logs/cycle-*.md` (if present) plus `ROADMAP.md`'s revision history for any phase/entry describing removal, deprecation, or simplification. Zero found across ≥8 logs (or ≥8 `git log` entries touching `ROADMAP.md` if no cycle-logs exist) → symptom present. | `subtraction-session`, `sunset-review`, `inversion` |
| 리스크 대비가 부족하다 | `state.json.activities.security-compliance.lastRunUtc` is null or its elapsed time is ≥ 2× its cadence, AND no recent cycle-log Reflection section mentions security/resilience/observability work. | `premortem`, `chaos-engineering`, `red-team` |
| 온보딩/DX 불만이 감지된다 | Glob `claudedocs/issues/**` (open + `closed/`) and grep for onboarding/setup/confusing-error language; ≥2 matches → symptom present. | `error-message-audit`, `fresh-eyes-onboarding`, `ai-agent-usability` |
| 장기 방향이 흐릿하다 | `state.json.activities.vision-gap.lastRunUtc` elapsed ≥ 1.5× its cadence (severely overdue), OR — reading `ROADMAP.md`'s own revision history / `git log` over the date range spanned by the last 3 `INDEX.md` entries — the same phase names recur across that window without resolution. (`INDEX.md` itself only records run dates/counts/symptoms, not phase names; it just bounds which window of `ROADMAP.md` history to inspect.) | `working-backwards`, `sf-prototyping`, `constraint-removal` |
| 도메인 이해가 정체돼 있다 (조사가 SW 기술 축에 편중) | Sum `swTech` and `domain` across the last 3 `inquiryAxisHistory` entries (or, if that history is empty, grep the last 3 `proposal-*.md` for `탐구 축:` lines). `domain` is 0, or fewer than a quarter of the total → symptom present. The product's subject matter is being treated as settled while only its implementation is re-examined. | `research-scan` (도메인 축 필수), `domain-practice`, `cross-domain-borrowing` |
| 제품의 자리가 낡았다 (차별화 흐려짐) | `state.json.activities.positioning-review.lastRunUtc` is null or elapsed ≥ 2× its cadence, AND competitor-driven items dominate recent output — grep the last 3 `proposal-*.md` for `출처 활동:` lines and find that `벤치마킹`-sourced items are ≥ half of all items across them. (Chasing feature parity without re-examining where the product stands is exactly the drift this symptom names.) | `positioning-review`, `benchmarking`, `cross-domain-borrowing` |
| 아이디어 자체가 고갈됐다 | For the last 2 entries in `state.json.diagnosisHistory`, sum each matching `valueAxisHistory` entry (same `runUtc`) as `business + techHealth + userRequest` — if both sums are fewer than 2 total discovered items, symptom present. (`diagnosisHistory` itself does not store an item count; join on `runUtc` against `valueAxisHistory` to derive it.) | `hackathon-exploration`, `cross-domain-borrowing`, `random-walk-reading`, `archive-mining` |

If no symptom matches, select the **1–2 oldest-untried** items from
`emergentPool.rotationOrder` starting at `rotationPointer` (wrapping around the array),
i.e. plain round-robin — this guarantees every pool item eventually runs even absent a
diagnosed symptom.

**Prescription target may be individually cadenced.** Several prescriptions are not in
`emergentPool` — `sunset-review`, `premortem`, `sf-prototyping`, `archive-mining`,
`research-scan`, `domain-practice`, `benchmarking`, `positioning-review` are tracked
individually in `state.json.activities` with their own cadence (the same list P1 already
due-checks). When a diagnosed symptom prescribes one of these, **treat the match as
forcing it due this run regardless of its own elapsed time** — a diagnosed symptom is a
stronger signal than mechanical cadence. When a prescription is a rotation-pool activity
instead, select it directly from the pool for this run (bypassing round-robin order, but
still advancing `rotationPointer` past it in P8 so it isn't re-selected redundantly by the
next round-robin pass).

Record the diagnosis (symptom name or `"none"`, and the selected activity id(s)) — this
feeds P8's `diagnosisHistory` entry and next run's "아이디어 고갈" check.

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
| `telemetry-observability` | **Read-only.** Read `claudedocs/telemetry/report-*.md` + `.last-run.json` if present (do not call `az` or reimplement KQL). Skip + note "telemetry-az not configured" if `claudedocs/telemetry/config.json` is absent |
| `usage-analytics` | Same read-only reuse of `telemetry-az`'s purpose-2 (user analytics) report section |
| `issue-community` | `Bash(gh issue list)` / `gh discussion list` (if `gh` is authenticated) + scan `claudedocs/issues/**` for recurring themes. Skip + note "gh not authenticated" if it fails |
| `dogfooding` | **Active live use, not passive re-mining.** (1) Pick a **fresh, vision-anchored scenario** — a representative end-to-end task derived from a promise/claim in CLAUDE.md/README, and not one already in `state.json.activities.dogfooding.scenariosRun` (rotate to a new path each run). (2) **Actually drive it** through the project's own runnable surface via `Bash`: a CLI's real commands, a throwaway consumer script for a library, HTTP calls for a service. Where UI-automation tooling happens to be available in the environment, extend the walk-through to the UI; otherwise drive the library/API layer beneath the GUI and **skip-with-reason** the pure-GUI surface (never narrate UI friction you could not observe). (3) Record observed 기능/UI/UX/앱플로우 friction with **run-evidence** (commands run, behavior/output seen, steps walked) — this evidence is what makes the finding grounded observation, not invention. (4) *Also* fold in DX friction previously recorded in cycle-log Carry-Forward / Structural Improvement Proposal sections. If nothing in the project is Bash-drivable at all, skip-with-reason. |
| `code-audit` | Grep/Glob static scan for TODO/FIXME/deprecated markers + the project's own lint/outdated tooling via `Bash` (e.g. `npm outdated`, `dotnet list package --outdated`) |
| `security-compliance` | Dependency audit via `Bash` (e.g. `npm audit`, `dotnet list package --vulnerable`) + WebSearch for CVEs affecting declared dependencies |
| `tooling-development` | Mine the project's own history for **repeated manual work**: scan cycle logs / `git log` / CI config / scripts dir for procedures done by hand more than twice (release steps, fixture generation, log comparison, repro setup), slow or flaky verification loops, and one-off scripts rewritten each time. Each recurrence is a candidate to asset-ize as a script/harness/generator. Targets team throughput, not product durability — do not file refactoring items here |
| `roadmap-decomposition` | Re-derive epics/stories from any stated milestones/KPIs in CLAUDE.md/README against current `ROADMAP.md` phases |
| `sunset-review` | Grep for deprecated/legacy markers; compare the current feature list against the declared vision for "would not build today" candidates |
| `premortem` | Author a failure-mode narrative ("this project failed in 2 years because...") from the current architecture, worked backward into preventive tasks |
| `sf-prototyping` | Author a 5–10 year forward-looking domain scenario, backcast to near-term extension points worth seeding now |
| `archive-mining` | Glob `claudedocs/issues/closed/**` and old cycle-log Carry-Forwards for previously-declined ideas whose blocking condition may have since changed |
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

### P4: Tag

For every discovered item, record: source activity id, **value axis** (exactly one of
`비즈니스` / `기술건전성` / `사용자요청`), **inquiry axis** (exactly one of `SW기술` /
`도메인전문`), a 1–3 sentence rationale grounded in what was actually observed, and a
**phase-level** scope description (never cycle-numbered — consistent with `run-cycle`'s
roadmap-is-a-phase-backlog rule).

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

### P5: Philosophy alignment

Score each item using [philosophy-alignment-guide.md](../mindset/references/philosophy-alignment-guide.md)
(the same guide `issue`/`pr`/`telemetry-az` use). Low-scoring items are **kept but
flagged** "정렬 미흡" in the proposal — this skill never silently drops an item; exclusion
is a human call made when reviewing the proposal.

### P6: Synthesis — diagnose, rank, stage

Discovery produced a pile of grounded items. This step turns it into something a human can
decide on, using [synthesis-rubric.md](references/synthesis-rubric.md) for the scoring
tables and constraints. Three outputs, in order:

1. **현재 상태 진단** — four sentences from what was *actually observed this run*, one per
   axis: 비전 대비 지점 · 시장 내 자리 · **도메인 적합성** · 내부 체력. An axis with no
   observation this run is written "이번 주기 미관측", never filled with a guess. Close with
   a one-sentence verdict — "이 제품은 지금 〈상태〉이며, 다음 한 걸음은 〈방향〉이다" — which
   becomes the thesis the ranking is measured against.
2. **중요도 판정** — score each item 1–5 on 비전 기여도, 철학 정렬 (reuse P5's average — do
   not recompute), and 증거 강도; 가치 점수 is their mean. 비용·리스크 is scored separately
   and used only for placement. Every score cites the signal that justifies it.
3. **단계 구성** — place items on **지금 / 다음 / 나중** by 가치 × 비용, then apply the
   rubric's overriding constraints: dependency order beats score, 증거 강도 1–2 cannot sit
   in 지금, irreversible items are marked `Discussion 필요`, and skew on either axis
   (value or inquiry) is reported rather than silently rebalanced.

**These horizons are an ordering, not a schedule.** No cycle numbers, no dates, no
durations — the same rule that keeps `run-cycle`'s roadmap a phase backlog applies here,
one layer further upstream. And ranking is not merging: rule 1 still holds for every item
in 지금.

If discovery produced no items at all (all four deepen-ladder lanes came up empty), output
① and the ladder record anyway — "무엇을 확인했고 왜 비어 있는가"는 그 자체로 보고할 내용이다.

### P7: Proposal document

Write `claudedocs/backlog-discovery/proposal-YYYY-MM-DD.md` using
[proposal-template.md](references/proposal-template.md). This is the **terminal output**
of this skill — `ROADMAP.md` is never written here. List skipped activities explicitly
with their skip reason (never silent).

Skip file writes entirely under `--dry-run`; print the filled template to chat instead.

### P8: State update (skip if `--dry-run`)

- Advance `lastRunUtc` to `nowUtc` for every activity that actually ran (P3), including
  ones that were "run" but skipped internally for lacking a signal — a signal-less skip
  still counts as this cadence period's attempt, so it doesn't get retried every
  invocation until the next cadence boundary.
- Advance `emergentPool.rotationPointer` past the selected pool items (wrap at array
  length); set their `lastRunUtc`.
- If active `dogfooding` ran, append the exercised scenario's slug to
  `activities.dogfooding.scenariosRun` (trim to the last ~8) so the next run rotates to a
  fresh path.
- Append this run's diagnosis to `diagnosisHistory` (`{ runUtc, symptom, selected }`), the
  value-axis counts to `valueAxisHistory` (`{ runUtc, business, techHealth, userRequest }`),
  and the inquiry-axis counts to `inquiryAxisHistory` (`{ runUtc, swTech, domain }`). Trim
  each to the last 12 entries (matches `telemetry-az`'s `history[]` convention).
- Append one line to `claudedocs/backlog-discovery/INDEX.md`:
  `{date} — {N} items ({business}/{techHealth}/{userRequest} · SW{swTech}/도메인{domain}), 지금 {n}건, symptom: {name-or-none}`
  + a link to this run's proposal file. Create `INDEX.md` with a one-line header if it
  doesn't exist yet.

### P9: Merge — explicitly NOT part of this skill's automated flow

This skill's work ends at P8. When a human reviews `proposal-YYYY-MM-DD.md` and asks for
specific items to be adopted, add them to `ROADMAP.md`'s phase backlog by hand in that
follow-up turn, following `run-cycle`'s "phase backlog, not cycle-numbered" format. Do
not perform this step as part of a `/iyu:backlog-discover` invocation itself.

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
   dogfooding — is filed through the existing global `claudedocs/issues/ISSUE-*.md`
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
9. **Discovery ≠ adoption.** A technology or method surfaced by `web-trend`,
   `research-scan`, or `domain-practice` is a *candidate*, never a decision. It reaches the
   proposal only through `appropriate-tech`'s verdict, and a `기각`/`보류` verdict is
   recorded, not dropped — the record is what stops the same candidate being re-litigated
   from scratch next run.
