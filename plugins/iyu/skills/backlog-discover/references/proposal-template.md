# Proposal document template

Fill this structure and write it to `claudedocs/backlog-discovery/proposal-YYYY-MM-DD.md`
in the consumer repo. This document is the **terminal output** of a
`/iyu:backlog-discover` run — `ROADMAP.md` is never touched by this skill; a human
reviews this file and asks explicitly for selected items to be merged.

```markdown
# Backlog Discovery Proposal — {date}

## 이번 실행 요약
- 실행된 활동: {활동명 목록 — 각 항목에 due 판정 사유(케이던스 경과/최초실행/--modes 강제) 포함}
- 진단된 증상 (있다면): {증상명} → {선택된 창발 세션 목록}, 또는 "증상 없음 — 로테이션 풀에서 선택: {목록}"
- 가치축 균형: 비즈니스 {n} / 기술건전성 {n} / 사용자요청 {n} — {한 축이 지난 3회 실행 대비 현저히 낮으면 치우침 경고}

## 발굴 항목

### [{value-axis}] {제목}
- 출처 활동: {활동명 — playbook.md의 §번호 및 한글명}
- 근거: {1~3문장, 관찰한 신호를 구체적으로}
- 철학 정렬: {high|medium|low} — {CLAUDE.md/README 대비 판단 1문장}
- 예상 규모: {phase-level 방향성 설명만. 구체 사이클 수·일정은 산정하지 않음}
- 분류: {Autonomous-eligible로 보이는 확장 | Discussion 필요 — 새 방향/의존성/트레이드오프}

{... 항목별로 반복 ...}

## 스킵된 활동
- {활동명}: {스킵 사유 — "케이던스 미도래 (다음 실행 예정: {날짜})" 또는 "신호 부재: {구체 사유, 예: telemetry-az config.json 없음}"}

{... 스킵된 활동마다 반복. 스킵된 것이 없으면 "없음" ...}
```

**Field notes:**
- `{value-axis}` is exactly one of `비즈니스`, `기술건전성`, `사용자요청` — pick the
  single best-fit axis per item, do not multi-tag.
- "예상 규모" must stay phase-level (a direction, not a cycle count) — this mirrors
  `run-cycle`'s rule that only the *current* cycle is ever concretely scoped; a discovery
  proposal is even further upstream than that.
- "분류" is advisory triage for whoever reviews the proposal — it does **not** grant
  auto-merge eligibility. Every item in this document requires human approval before
  entering `ROADMAP.md`, regardless of this tag.
