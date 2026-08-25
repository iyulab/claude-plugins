# Continuity docs — the shared contract

**This file is the single definition** of where a project's dev-tracking documents live and what
belongs in each. `run-cycle`, `handoff`, `resume`, `backlog-discover`, and `telemetry-az` all read it.
Copies of these rules inside individual skills drift apart; keep the definition here and link to it.

(`_shared/` holds no `SKILL.md`, so it is reference material, not a skill.)

---

## 1. Resolving the continuity root

Every artifact below lives **together in one directory**, the *continuity root* (`<root>`):

| Artifact | Path | Written by |
|---|---|---|
| Phase backlog (remaining work) | `<root>/ROADMAP.md` | run-cycle, handoff |
| Handoff (current + next) | `<root>/HANDOFF.md` | run-cycle, handoff — plus `resume`, which only ever appends to its `## Decided this session` section |
| Cross-session thread ledger | `<root>/STRANDS.md` | run-cycle, handoff |
| Thread-ledger archive (cold storage, created lazily) | `<root>/STRANDS-ARCHIVE-{NN}.md` | run-cycle, handoff |
| Completed-work index | `<root>/HISTORY.md` | run-cycle, handoff |
| Completed-work archive (cold storage, created lazily) | `<root>/HISTORY-ARCHIVE-{NN}.md` | run-cycle, handoff |
| Cycle logs | `<root>/cycle-logs/cycle-{NN}.md` | run-cycle |
| End-of-Run Report | `<root>/cycle-logs/RUN-SUMMARY-{YYYY-MM-DD}.md` | run-cycle |
| Backlog proposals | `<root>/backlog-discovery/` | backlog-discover |
| Telemetry reports | `<root>/telemetry/` | telemetry-az |
| Issue drafts | `<root>/issues/` | any |

**Resolve `<root>` once, at the start, by looking at the repo — never by assuming a literal path.**
A hardcoded path silently creates a *second* roadmap beside the one the project already keeps.

Glob once for `cycle-logs/`, `backlog-discovery/`, `telemetry/`, `ROADMAP.md`, and `HANDOFF.md`
(skip `node_modules`, `.git`, build output), then take the **first rule that matches** — the order
matters:

1. **A `cycle-logs/`, `backlog-discovery/`, or `telemetry/` directory exists** (in that precedence)
   → `<root>` is its **parent**. These are written only by this plugin's skills, so they are the
   most reliable anchor; `cycle-logs/` leads because only a previous run of `run-cycle` writes it.
2. **Otherwise a `ROADMAP.md` / `HANDOFF.md` exists** → `<root>` is the directory holding it. The
   repo has already chosen its convention; **use it in place**, never create a parallel one beside it.
3. **Nothing exists** → create the default **`claudedocs/`**.

**Every skill checks the identical list in the identical order.** An unequal list is how a project
that has so far run only one skill resolves one root there and a different one elsewhere — which is
the split these rules exist to prevent.

Two cases the plain rules do not settle:

- **Umbrella / multiple hits** — a repo tracking several submodules yields one candidate per
  submodule (`claudedocs/<Submodule>/`). Pick the one covering the code this run touches.
- **Legacy layout** — a `ROADMAP.md` / `HANDOFF.md` / `HISTORY.md` found **inside** `cycle-logs/`
  (an earlier layout) does not change rule 1: `<root>` is still the parent, and the skill that
  discovers the misplacement moves the file up to `<root>/` on the spot. Continuity docs sit
  *beside* `cycle-logs/`, never inside it — nesting them there makes `<root>/cycle-logs/` resolve
  recursively.

**They move together or not at all.** `HISTORY.md` indexes cycle logs by `(cycle-NN)` and
`HANDOFF.md` anchors to backlog phases; splitting them across directories breaks those references.

---

## 2. What belongs in each document

**The invariant: completed work does not live in a continuity doc.** `ROADMAP.md` and `HANDOFF.md`
are what a human — or a fresh session — reads to find *remaining* work fast. Without this rule both
grow monotonically until "what's left?" is buried under "what's done".

| Document | Holds | Never holds |
|---|---|---|
| `ROADMAP.md` | Phase-level directions, remaining only. Known unknowns and investigation needs | Completed phases. **Cycle numbers** — it is a backlog, not an itinerary |
| `HANDOFF.md` | What is in flight and what comes next, anchored to backlog phases | Past-session narrative. Anything already done |
| `HISTORY.md` | A pure index, newest first, one compressed entry per completed phase | Detail — cycle logs and git history are the record |
| `STRANDS.md` | Which dominant strand each cycle served, and interruption/resume transitions | Task detail (cycle logs own that), issues (issues/ owns that), completed-work narrative (HISTORY.md owns that), a session's current-vs-next snapshot (HANDOFF.md owns that — STRANDS.md is the cumulative cross-session record HANDOFF.md deliberately does not keep) |

**`STRANDS.md` and `HISTORY.md` are the two continuity docs with no other structural size ceiling.**
`HANDOFF.md` is rewritten current+next every time and `ROADMAP.md` only holds what remains — both
self-bound. `STRANDS.md`'s `## 중단됨` entries persist until a human retires them, and `HISTORY.md`
is by design a never-pruned index. Both keep a **live window** and roll overflow into numbered
archive files instead — see §3 step 2 (`HISTORY.md`) and step 4 (`STRANDS.md`). Nothing already
written to either is ever deleted, only relocated.

A **strand** is identified by the concern it serves (a `ROADMAP.md` phase title, or a short ad-hoc
label for off-roadmap work like `"사용자 요청: 로그인 버그 긴급 수정"`), not by the *kind* of work a
cycle did — the same strand can be advanced by a bugfix, a phase push, a discussion/decision, or a
docs cycle. `STRANDS.md` format:

```markdown
# STRANDS
> History: [HISTORY.md](HISTORY.md)
> Archive: [STRANDS-ARCHIVE-01.md](STRANDS-ARCHIVE-01.md)  <!-- omit this line until an archive exists -->

## 진행 중
- {strand} — 시작: {date} ({unit}), 최근: {date} ({unit}) (누적 {k}회)

## 중단됨 (복귀 검토 후보)
- {strand} — 마지막: {date} ({unit}) — 전환 사유: "{한 줄: 무엇으로 전환했는지}"

## 완료·졸업 (최근 10건 — 이전 이력은 archive 참조)
- {strand} — {date range}
```

`{unit}` is written literally as `cycle-{NN}` (when `run-cycle` writes it) or `session-{YYYY-MM-DD}`
(when `handoff` writes it) — never a bare number, so provenance survives the merge.

Every other reference to these sections, in any file, uses the short prefix shown above without
the parenthetical (`## 진행 중` / `## 중단됨` / `## 완료·졸업`) — this is the established
convention, not an inconsistency; only this canonical template carries the full descriptive text.

`HISTORY.md` entry format:

```
- **{YYYY-MM-DD}** {phase} — {one-line outcome} (cycle-NN)
```

---

## 3. Hygiene pass

Apply whenever continuity docs are written — every `run-cycle` STEP 5, every `handoff` run:

1. **Migrate every completed phase/item out of `ROADMAP.md`** — not only ones completed just now.
   Any already-completed leftover found is migrated too. This is invariant *enforcement*, not an
   event handler, and it is what makes pre-existing bloat converge without a special cleanup pass.
2. **Append to `HISTORY.md`** in the format above, beside `ROADMAP.md`. Never duplicate detail into
   it; deep dives start at the index and follow the reference. **Live-window cap**: `HISTORY.md`
   keeps only its most recent 30 entries live (newest first, per the existing format). When an
   append would push it past 30, move the oldest entries — enough to bring the live file back to
   30 — into `<root>/HISTORY-ARCHIVE-{NN}.md`, appending them there oldest-first (so the archive
   itself still reads chronologically). Start `{NN}` at `01`; once `HISTORY-ARCHIVE-{NN}.md` is at
   or past ~150 lines, the next overflow starts `{NN+1}` instead of appending further. Nothing is
   deleted — only relocated. Add `> Archive: [HISTORY-ARCHIVE-01.md](HISTORY-ARCHIVE-01.md)` under
   `HISTORY.md`'s own top-of-file link the first time an archive is created (update the number if it
   has since rolled past 01).
3. **Rewrite `HANDOFF.md` to current + next only** (if the project keeps one). Past-session
   narrative is dropped, not accumulated.
4. **`STRANDS.md` — update, then compress.** This is the one step both `run-cycle` (per completed
   cycle) and `handoff` (per closing session) apply identically — "this unit" below means whichever
   produced the update, recorded literally as `cycle-{NN}` or `session-{YYYY-MM-DD}`.

   **Update (transition procedure):**

   a. Identify the strand this unit predominantly served — the `ROADMAP.md` phase advanced, or a
      short ad-hoc label (e.g. `"사용자 요청: 로그인 버그 긴급 수정"`). If a session genuinely
      advanced more than one distinct strand substantially, apply steps b–e once per strand rather
      than picking one.
   b. If it matches the current `## 진행 중` entry: increment its cumulative count and update
      `최근` to this unit.
   c. If it differs from the current `## 진행 중` entry: move that entry to `## 중단됨`, recording
      this unit's strand name as the one-line transition reason; start a new `## 진행 중` entry for
      this unit's strand (시작 = this unit).
   d. If this unit resumes a strand currently listed under `## 중단됨`: move it back to
      `## 진행 중`, keeping its original 시작 date and adding this unit to its cumulative count.
   e. If this unit's `## 진행 중` strand reaches completion (its `ROADMAP.md` phase migrates to
      `HISTORY.md` in this same hygiene pass): move its `STRANDS.md` entry to `## 완료·졸업` as one
      line with the date range — the same migration `HISTORY.md` just received, recorded in both
      places. This is what closes the gap a `handoff`-only session used to leave open: a phase
      finished without ever running `run-cycle` now graduates its strand in the same pass that
      migrates it to `HISTORY.md`, not never.

   Create `STRANDS.md` with just the `# STRANDS` header and empty sections if it does not exist yet.

   **Compress (archives instead of dropping):** `## 진행 중` and `## 중단됨` are **never archived or
   dropped** — they are active state, and this document exists specifically so a thread in either
   section is never silently forgotten. `## 완료·졸업` keeps only its most recent 10 entries live;
   older ones move to `<root>/STRANDS-ARCHIVE-{NN}.md` (same `01` / ~150-line rollover rule as
   `HISTORY-ARCHIVE-{NN}.md` above), appended oldest-first. `## 중단됨` entries stay in place until
   either resumed (step d, above) or removed by hand once a human has accepted a `backlog-discover`
   `dormant-strand-review` `폐기` verdict (`backlog-discover`'s P9) — hygiene itself never reads
   `backlog-discovery/` proposals and never infers a retirement from an unreviewed one.
5. **Link line** — keep `> History: [HISTORY.md](HISTORY.md)` at the top of each continuity doc
   (create on first migration) so history stays one hop away.
6. **Size signal (soft)** — a continuity doc still long (~200+ lines) *after* migration means detail
   is living at the wrong layer: split phase detail into `<root>/plans/` and leave links. A judgment
   signal, not a hard rule. Does not apply to `STRANDS.md`/`HISTORY.md` — steps 2 and 4 already give
   those two a hard live-window + archive mechanism, since they are the only two continuity docs
   with no other structural size ceiling (see §2's caveat).

Hygiene is doc upkeep. It never gates termination and never blocks a run.

---

## 4. Deriving next scope

Both `run-cycle`'s STEP 5 and `handoff` answer "what comes next?". The sources, in priority order:

1. **Carry-forward defects** — anything actionable left unresolved.
2. **Mid-session discoveries** — a problem too large to have been handled where it surfaced.
3. **Emergent scope** — what the work just done *naturally implies next*, derived across three
   lenses: **user** (what would they now expect or hit?), **developer/maintainer** (what did it
   leave brittle, duplicated, or untested?), **operator** (what does running this now require?).
4. **The phase backlog** — the next-most-valuable unblocked phase.

`STRANDS.md`'s `## 중단됨` section is a fifth, narrower source: a strand interrupted recently enough
to still be worth a quick "resume this now?" check belongs here, surfaced the same way as any other
known-but-reordered work — it is not new discovery. A strand that has stayed interrupted for a long
time (multiple `backlog-discover` cadences) is no longer this section's concern; it is
`backlog-discover`'s `dormant-strand-review` (see that skill's SKILL.md), which closes with a
reignite/shrink/retire verdict rather than a scheduling nudge.

Classify every emergent candidate before proposing it:

- **Autonomous-eligible** — its absence reads as incompleteness or a defect; it stays within the
  project's declared role and established patterns; it carries no real trade-off.
- **Discussion / proposal-only** — it opens a new product direction, a new dependency or paradigm,
  or a trade-off only a human should weigh. Propose with rationale; never self-decide.

"Nothing left" is a legitimate outcome, but it must be a **stated judgment** across all three
lenses, never an empty section.

---

## 5. Output language

Every template in this plugin's skills (`## In flight`, `## Waiting on you`, `### {HD-01} …`, and
similar) is shown in English because these files are themselves written in English — it is not an
instruction to write the output in English. **Write the prose — chat responses and document
content alike — in the language the current session is actually conducted in.** A Korean-language
session produces a Korean `HANDOFF.md` and a Korean chat report; an English one produces English.
If a continuity doc being edited already has an established language (existing headings, existing
prose), match it in place rather than switching mid-document, even if it differs from the session's
language — a document should not fragment into two languages across one hygiene pass.

**Exception — literal machine-matched tokens stay in English, unmodified, regardless of session
language:** `HUMAN-NEEDED:`, `BLOCKED-ITEM:`, `FRONTIER-OPEN:`, `FRONTIER-EXHAUSTED:`, and decision
IDs (`HD-01`, `D-03`). The Stop hook and cross-run references match these as literal strings; the
label after the colon, and the rest of the entry, still follows the sentence above.
