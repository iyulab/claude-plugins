# Proposal document template

Fill this structure and write it to `<root>/backlog-discovery/proposal-YYYY-MM-DD.md` in the
consumer repo — `<root>` being the docs root resolved in SKILL.md's "File layout" section
(default `claudedocs/`). This document is the **terminal output** of a
`/iyu:backlog-discover` run — `ROADMAP.md` is never touched by this skill; a human
reviews this file and asks explicitly for selected items to be merged.

```markdown
# Backlog Discovery Proposal — {date}

## 이번 실행 요약
- 기준 시각(nowUtc): {P0에서 `date -u`로 확정한 값 — 추정했다면 그 사실을 명시}
- 실행된 활동: {활동명 목록 — 각 항목에 due 판정 사유(케이던스 경과/최초실행/--modes 강제/증상 처방/사다리 강제) 포함}
- 진단된 증상 (있다면): {증상명} → {선택된 창발 세션 목록}, 또는 "증상 없음 — 로테이션 풀에서 선택: {목록}"
  - 최근 3회 억제로 건너뛴 증상: {있으면 증상명 목록, 없으면 "없음"}
- 심화 사다리 (바닥이 얕았을 때만 — 도그푸딩은 상시 바닥이며 레인이 아님): {내려간 레인 ①~④ 과 각 레인의 산출 유무}
- 재발견 항목: {n}건 — {이전 제안서에서 이어받아 증거만 누적한 항목 수, 없으면 "없음"}
- 가치축 균형: 비즈니스 {n} / 기술건전성 {n} / 사용자요청 {n} — {한 축이 지난 3회 실행 대비 현저히 낮으면 치우침 경고}
- 탐구축 균형: SW기술 {n} / 도메인전문 {n} — {한 축이 0이거나 1/4 미만이면 편중 명시 + 왜 비었는지(활동 미도래/신호 부재/미시도)}
- 시간축 균형: 과거정리 {n} / 현재위치 {n} / 미래견인 {n} — {미래견인이 과거+현재+미래 합의 1/4 미만이면 치우침 경고}

## 현재 상태 진단

- **비전 대비 지점**: {1문장, 또는 "이번 주기 미관측"}
- **시장 내 자리**: {1문장, 또는 "이번 주기 미관측"}
- **도메인 적합성**: {1문장, 또는 "이번 주기 미관측 — 다음 실행 예정: {날짜}". 생략 불가}
- **내부 체력**: {1문장, 또는 "이번 주기 미관측"}

> **판정**: 이 제품은 지금 {상태}이며, 다음 한 걸음은 {방향}이다.

## 우선순위 및 단계 구성

지평은 **순서**이며 일정이 아니다 — 사이클 번호·날짜·기간을 붙이지 않는다. 어떤 지평도 자동으로 `ROADMAP.md`에 반영되지 않는다.

| 지평 | 항목 | 가치 점수 | 비용·리스크 | 선행 의존 | 비고 |
|---|---|---|---|---|---|
| 지금 | {제목} | {n.n} | {1~5} | {항목 또는 없음} | {Discussion 필요 여부} |
| 다음 | {제목} | {n.n} | {1~5} | {…} | {비용 높음이면 분해안 링크} |
| 나중 | {제목} | {n.n} | {1~5} | {…} | {지금 하지 않는 이유 1줄} |

> 지금/다음/나중 각 지평은 최소 한 항목이 있거나 비어 있는 이유가 한 줄로 적혀 있어야 한다
> (synthesis-rubric.md §③ 제약 6).

- 배치를 덮어쓴 제약: {의존 우선 / 증거 하한(강도 1~2) / 되돌리기 불가 → Discussion / 축 편중(가치·탐구·시간) / 지평 미채움 사유 — 적용된 것만}
- 순환 의존으로 새로 세운 항목: {있으면 항목명, 없으면 "없음"}

## 발굴 항목

### `{BD-YYYYMMDD-nn}` [{value-axis}·{inquiry-axis}] {제목}
- 이력: {"신규" 또는 "재발견 {n}회차 (최초: BD-…)" — 재발견이면 이번에 새로 관찰한 증거만 아래에 추가}
- 출처 활동: {활동명 — playbook.md의 §번호 및 한글명}
- 근거: {1~3문장, 관찰한 신호를 구체적으로}
- 실행 증거 (도그푸딩·관리 점검 등 능동 구동 항목 필수): {구동한 시나리오 슬러그 또는 점검 갈래 + 실행한 명령/호출, 관찰한 동작·출력, 밟은 단계. 재현 트레이스가 없으면 발명이므로 제안에 싣지 않는다}
- 철학 정렬: {high|medium|low} ({4차원 평균 n.n}) — {CLAUDE.md/README 대비 판단 1문장}
- 판정: 비전 기여도 {1~5} / 철학 정렬 {1~5} / 증거 강도 {1~5} → **가치 {n.n}**, 비용·리스크 {1~5} — {각 점수를 정당화하는 신호를 한 줄로 인용}
- 배치: {지금|다음|나중} · 선행 의존: {항목 또는 없음}
- 예상 규모: {phase-level 방향성 설명만. 구체 사이클 수·일정은 산정하지 않음}
- 분류: {Autonomous-eligible로 보이는 확장 | Discussion 필요 — 새 방향/의존성/트레이드오프}

{... 항목별로 반복 ...}

## 기술 채택 판정 (적정기술 판정이 돌았을 때만)

| 후보 | 출처 | 판정 | 사유 (1줄) |
|---|---|---|---|
| {기술/방법} | {web-trend｜research-scan｜domain-practice｜benchmarking} | {채택｜시범｜보류｜기각} | {특히 "그 문제가 이 제품에 실재하는가"에 대한 답} |

`기각`·`보류`도 기록으로 남긴다 — 다음 실행에서 같은 후보를 처음부터 다시 다투지 않기 위함이다.

## 스킵된 활동
- {활동명}: {스킵 사유 — "케이던스 미도래 (다음 실행 예정: {날짜})" / "신호 부재: {구체 사유, 예: telemetry-az config.json 없음}" / "최초 실행 분할 — 다음 실행에서 수행 (케이던스 미전진)" / "--dry-run: 쓰기 경로 제외"}

{... 스킵된 활동마다 반복. 스킵된 것이 없으면 "없음" ...}
```

**Field notes:**
- `{value-axis}` is exactly one of `비즈니스`, `기술건전성`, `사용자요청` — pick the
  single best-fit axis per item, do not multi-tag.
- `{inquiry-axis}` is exactly one of `SW기술`, `도메인전문` — likewise single-tag. It records
  which kind of expertise produced the finding: how the product is *built* vs. what it is
  *for*. The two are co-equal; a run whose items are all `SW기술` must say in the summary
  what the domain axis was asked and why it produced nothing.
- 판정 · 배치 fields come from [synthesis-rubric.md](synthesis-rubric.md) (P6). Every score
  cites the observed signal behind it — an uncited number is invention wearing a number.
  `증거 강도` 1–2 items cannot be placed in `지금`; propose the work that would produce the
  evidence instead.
- The 단계 구성 horizons (`지금`/`다음`/`나중`) are an **ordering**, never a schedule, and
  never grant merge eligibility — see the note below on 분류.
- Every horizon must be non-empty or carry a one-line reason why not — see synthesis-rubric.md §③
  제약 6. 지금 stays concrete; 다음/나중 may be stated as direction rather than scoped work.
- 시간축(과거/현재/미래) is derived automatically from source activity (SKILL.md P4) — do not ask
  for a manual tag per item; the summary line aggregates it from each item's 출처 활동.
- "예상 규모" must stay phase-level (a direction, not a cycle count) — this mirrors
  `run-cycle`'s rule that only the *current* cycle is ever concretely scoped; a discovery
  proposal is even further upstream than that.
- "분류" is advisory triage for whoever reviews the proposal — it does **not** grant
  auto-merge eligibility. Every item in this document requires human approval before
  entering `ROADMAP.md`, regardless of this tag.
- "실행 증거" is mandatory for any item sourced from an activity that actively drives the
  product (dogfooding, and the emergent lenses that walk a real flow). The trace is what
  distinguishes observed friction from invented friction — an item lacking one is dropped,
  not softened. Concrete defects caught this way go to `<root>/issues/ISSUE-*.md`, not
  here (see SKILL.md execution rule 3); only systemic/UX-direction/vision-shortfall gaps
  become proposal items.
