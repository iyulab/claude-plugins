# Changelog — iyu plugin

All notable changes to the `iyu` plugin are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); the plugin uses `0.x`-style
pre-1.0 semantics where MINOR adds features (backward-compatible) and PATCH fixes
bugs or docs. MAJOR is never bumped automatically.

> History is reconstructed from git from v1.11.0 onward. Earlier versions live in
> the git log only.

## [1.35.0] — 2026-08-19

Usage feedback: `/iyu:backlog-discover` was producing only 1-2 items per run, even on the exact
condition (an empty backlog) meant to trigger a fuller reassessment — the dry-backlog "deepen ladder"
stopped at the first lane that produced anything, and nothing tracked whether in-flight or interrupted
work was quietly stalling or drifting apart from the rest of the backlog.

### Added

- **`STRANDS.md`**, a new continuity artifact tracking which dominant strand of work each cycle
  serves, across sessions — written by `/iyu:run-cycle` every cycle, read by `/iyu:resume` (recent
  interruptions) and `/iyu:backlog-discover` (long-stale ones). Compressed by the existing
  continuity-doc hygiene pass; a strand only retires once a human reviews and accepts a
  `dormant-strand-review` verdict — nothing auto-retires.
- **Two new `/iyu:backlog-discover` activities**: `strand-deepening` investigates the surface around a
  strand that's stayed active without finishing; `dormant-strand-review` judges reignite /
  shrink-and-resume / retire for a strand that's stayed interrupted well past normal cadence.
- **A self-correcting temporal-axis balance check** (past/present/future), derived automatically from
  each activity's own nature rather than a manual tag, so the two activities above never crowd out
  vision-pulling ones like `vision-gap` or `working-backwards`.

### Changed

- **`/iyu:backlog-discover`'s dry-backlog trigger now forces a full four-lane sweep** instead of
  stopping at the first lane with material — an empty backlog is exactly the condition where search
  should widen, not narrow. Steady-state (cadence-driven) behavior is unchanged.
- **Every discovery proposal now requires all three horizons (now/next/later) populated or explicitly
  explained**, with the near horizon staying concrete and the far horizon allowed to stay directional.

## [1.34.0] — 2026-08-16

Usage feedback: `/iyu:resume` was proceeding straight into implementation once decisions were
answered, collapsing the boundary with `/iyu:run-cycle` it was designed to keep. Separately, it only
replayed `## In flight`/`## Next` as written, even when circumstances had visibly moved past what the
docs still assumed — leaving reprioritization, missing prerequisites, and questionable plan items for
someone to catch by hand.

### Changed

- **`/iyu:resume` no longer starts the work.** Step 6 ("Start the work") is replaced with a hard stop:
  the skill ends at a settled, confirmed scope and never proceeds into implementation on its own.
  Starting the work is a separate, explicit instruction or `/iyu:run-cycle`.
- **`/iyu:resume` now synthesizes instead of replaying.** Step 3 applies judgment to `## In
  flight`/`## Next` against current state (git log/status, `HISTORY.md` tail, recent memory): it
  proposes reordering when recorded priority no longer fits, derives prerequisites the plan is
  missing, and objects to items that no longer look reasonable — all as proposals, not silent edits.
  A proposal that rises to decision-class is briefed the same as a handoff-flagged one (step 4); a
  confirmed reorder is recorded in `HANDOFF.md`'s "Decided this session" for the next `/iyu:handoff` to
  apply to `ROADMAP.md` — resume still never writes `ROADMAP.md` directly.

## [1.33.0] — 2026-08-14

### Changed

- **`/iyu:resume` splits "In flight"/"Next" into 코드 작업 / 비코드 작업**, and feeds that split into
  step 4's reversibility read: a code decision defaults toward self-decide once a recommendation
  exists, while a non-code decision touching an action central policy already gates on a human
  (`git push`, a GitHub issue registration, a major-version bump, publish/release) stays briefed
  regardless of confidence — closing a gap where the "recommendable + reversible → self-decide" guard
  had no principled way to tell the two apart.
- **`/iyu:resume` points at `/iyu:backlog-discover` when `## Next` is empty**, mirroring the closing
  line `run-cycle`'s End-of-Run Report already writes when a run ends on `FRONTIER-EXHAUSTED:` with
  budget left. A pointer only — resume never invokes it, keeping the two skills' non-merging boundary
  intact.
- **`/iyu:resume` surfaces self-decided step-4 entries alongside the briefing** instead of silently
  proceeding — decision · trade-off · to correct, the same shape `run-cycle`'s End-of-Run Report part 3
  uses for its Decisions Ledger. Confirm-not-approval: it doesn't wait on a reply, but it gives the
  human a quick "anything different?" look at what got decided for them.

## [1.32.0] — 2026-08-13

Usage analysis found `/iyu:handoff` doing double duty: called at session close as designed, and again
at session open — manually, since nothing else read the docs it wrote and briefed what was left
undecided. Splitting that second use into its own skill fixes both the redundant re-derivation (a
full evidence-reconstruction + hygiene pass run against a session that had not started yet) and a
durability gap (a decision settled in conversation at session-open had no write-back path until the
*next* `/iyu:handoff` tried to infer it from a git diff that might not even show it).

### Added

- **`/iyu:resume` — opens a session from the files `/iyu:handoff` left.** Read-only against
  `HANDOFF.md`/`ROADMAP.md` (no git-log reconstruction, no hygiene pass, nothing migrated to
  `HISTORY.md` — that stays entirely `/iyu:handoff`'s job), it presents in-flight/next for
  confirmation and **briefs** every decision handoff only flagged: grounded options, the cross-lens
  read, and a named recommendation with what it locks in — the same four-part shape
  `/iyu:handoff` used to produce at close, now produced fresh at open instead. It is the one skill in
  the plugin whose entire point is to pause and wait for an answer, and the moment one lands it is
  written into `HANDOFF.md`'s "Decided this session" section immediately, not deferred to the next
  handoff's reconstruction. Safe to self-invoke on the same narrow bar as `/iyu:handoff` (a fresh
  session with no stated task and an existing `HANDOFF.md`), since it only reads and appends one
  decision record.

### Changed

- **`/iyu:handoff` step 6 now *flags* decisions instead of *briefing* them.** A decision-class entry
  in "Waiting on you" is one line naming the choice — no options, no cross-lens read, no
  recommendation generated at close time, where they would sit stale until someone actually acts on
  them. Resource-blocked entries (a missing credential, an access grant) are unaffected — that shape
  was always a fact, not a decision, so `/iyu:handoff` keeps writing it in full.
- **`decision-briefing.md` and `decision-lenses.md`** now name `/iyu:resume` as the briefing consumer
  in place of `/iyu:handoff` step 6; `/iyu:handoff`'s use of `decision-briefing.md` narrows to §1's
  entry shapes only.
- **`continuity-docs.md`'s artifact table** notes `/iyu:resume` as a (partial) writer of
  `HANDOFF.md` — its `## Decided this session` section only; every other document and section stays
  `/iyu:handoff`'s alone.

## [1.31.0] — 2026-08-11

`/iyu:handoff` was the only one of five command skills with no irreversible step (no commit, no push,
no implement), which made locking it to manual-only an unjustified exception under the plugin's own
reversibility bias.

### Added

- **`/iyu:handoff` can self-invoke.** Only on a concrete session-ending or doc-staleness signal,
  announcing before it touches a file; the other command skills stay manual since each carries an
  irreversible or human-only step.
- **`continuity-docs.md` §5 — output language follows the session.** Templates are shown in English
  because the files defining them are English, not as an instruction to write output in English;
  reports and continuity docs now match the session's actual language, with machine-matched tokens
  (`HUMAN-NEEDED:`, decision IDs, …) staying literal regardless.

### Fixed

- Reports and continuity docs were defaulting to English even in a non-English session — the
  templates' own English text was being reproduced instead of translated.

## [1.30.0] — 2026-08-07

The skills listed the owner's decisions as bare questions. A question hands the whole investigation
back to the person with the least context on the work that produced it — so all three decision
surfaces now hand up a **briefing** instead: options, a multi-angle read, and a recommendation.

### Added

- **`skills/_shared/decision-briefing.md` — the shape a decision takes when it goes up.** Read by
  **`handoff` step 6 · `run-cycle` End-of-Run Report part 2 · `ship` step 0** — the same trio that
  shares `release-cadence.md`. The four parts are constant; the carrier differs: handoff writes a
  `HANDOFF.md` section, run-cycle a `RUN-SUMMARY` section, and **ship asks interactively and waits**,
  which is why its briefing lands *in the question* rather than in a document.
- **Decision briefing in `/iyu:handoff` step 6.** "Waiting on you" now holds two distinct entry
  shapes rather than one blurred list:
  - **Resource-blocked** (a missing credential, an access grant) keeps the short blocker · what was
    tried · what would unblock it form. There is nothing to choose there, and forcing an options
    table onto it produces filler.
  - **Decision-class** carries four things: the decision in one line; **at least two options** with
    their concrete consequences (usually one of them "defer"); a **cross-lens read** of how the
    leading options differ; and a **recommendation** naming one option, its reason, and **what it
    locks in** — the irreversibility being what the owner is actually deciding about.
  The slots live in the `HANDOFF.md` output template, not only in the prose: the template is what
  gets filled in. The chat report carries them too, since compressing a briefed decision back into
  "needs your input" would undo the step.
- **`skills/_shared/decision-lenses.md` — the five co-equal lenses, defined once.**
  근본/정석/표준/세련/철학, with 철학 deferring to `mindset`'s four-dimension guide. Two consumers,
  two purposes: `run-cycle` rule 2.5 reads them to **self-decide** a reversible choice without
  asking, `handoff` step 6 reads them to **brief** an irreversible one. Which purpose applies is
  settled by reversibility before the file is opened. Irreducible cross-lens conflict stays an
  escalation signal in both.

### Changed

- **`/iyu:run-cycle`'s End-of-Run Report part 2 and `/iyu:ship`'s step 0 use the same shape.** The
  run's deferred L2 decisions are briefed at report time — a synthesis of ledgers that already
  exist; the per-cycle `BLOCKED-ITEM:` entry format is deliberately **unchanged**, since those
  entries govern termination and adding briefing work to the parking path would slow the run.
  `ship` step 0 now poses the release-timing trade-off as options + recommendation, and its report
  records which option was chosen.
- **Three guards keep the briefing from inverting the plugin's autonomy bias.** A polished
  escalation format is an incentive to escalate more, so: options must be **observed, not invented**
  (feasibility and cost come from what was actually read; unknown cost stays "unknown" with the
  command that would settle it); *having* a recommendation never makes an entry human-only — a
  recommendable **reversible** choice belongs under "Decided this session" (this guard applies only
  where the consumer has an autonomy path, not to `ship`, whose decision is irreversible by
  definition); and **an empty section is a valid, often preferable outcome** — if everything left can
  be carried autonomously, the answer is "None", and manufacturing a decision to fill the slots is
  worse than a blank section. Silence is not consent: nothing proceeds on a recommendation by
  default.
- **Personas made explicit where they were missing.** `/iyu:handoff` works like a capable **team
  lead**, `/iyu:telemetry-az` like a capable **analyst** — matching `run-cycle`'s capable employee
  and `backlog-discover`'s owner-manager, which already said so.
- Rule 2.5 in `/iyu:run-cycle` now links the shared lens file instead of restating the list. Behavior
  is unchanged; it is the extraction's second consumer.
- **Rationale moved out of `run-cycle` and `backlog-discover` into their `references/`.** A loaded
  skill's body is a recurring token cost, so instruction stays inline and explanation moves out —
  `run-cycle` gains a `references/design-rationale.md` (why cycles, the cycle-numbered-roadmap
  failure, why STEP 5 derives, the L0–L3 rationale, worked gate examples, the unscoped-`Bash` and
  logs-are-memory decisions) and `backlog-discover` appends the same kind of material to its
  existing one. Guidance that *counters a rationalization in the moment* — "'I would need X' is not
  evidence that X is absent", "assumed blockers are how a run stalls with budget left" — stays
  inline deliberately: for a discipline rule, the justification is the mechanism. No behavior
  changes; both files move further under the 500-line guidance (483→471, 489→475).

## [1.29.0] — 2026-08-07

Addresses the second gap the usage analysis found — 1,587 distinct release-related requests across
107 projects, with `bump version, commit, push` and `push, cicd tracking` repeating near-verbatim
250+ times — plus the scheduling problem underneath it.

### Added

- **`/iyu:ship` — take finished work out, and confirm it landed.** Version bump → commit → push →
  **watch the CI run to completion**, reporting the failing step if it fails. The watching is the
  part that usually gets skipped: a push whose pipeline failed twenty minutes later is not a
  completed release.
  - **Staged, because the stages cost differently.** `bump + commit` is local; `push` reaches the
    remote and spends CI budget; `publish` reaches consumers and cannot be undone. `--commit-only`
    and `--no-publish` stop at each boundary.
  - **Step 0 asks whether now is the moment.** It reads the remaining backlog first, and if
    unfinished work would touch the same consumer-facing surface it reports the trade-off and asks
    rather than deciding. Publishing is irreversible and the project's rhythm is the project's to
    set — the skill surfaces the judgment, it does not impose one.
  - Never bumps MAJOR. Never fix-and-retries a red pipeline — it reports the cause and stops, since
    whether that is a code defect, a flaky run, or an infrastructure problem is a human call. Never
    reorders the backlog itself; that is `handoff`'s job.
- **`skills/_shared/release-cadence.md` — when releasing belongs in the order.** Read by `handoff`
  step 5, `run-cycle` STEP 5, and `ship` step 0. Deliberately separate from `continuity-docs.md`:
  `ship` must answer "is now the moment?" without importing doc-hygiene rules, and release placement
  is a scheduling rule that merely happens to be applied while writing those docs. Its core: release
  is three stages with three costs; **a release that will require a re-release shortly is close to
  no release at all**; and cadence is *declared by the project* (free-form) or inferred from tag
  history **with the inference stated** — never a fixed set of named tiers the skill sorts projects
  into.

### Changed

- **`/iyu:handoff` gained a re-ordering step.** Deriving *what* comes next and deciding *what order
  the rest sits in* are different jobs, and skipping the second is how a release ends up scheduled
  mid-phase — where publishing buys a version the next few items obsolete and each pushed pipeline
  spends a shared CI budget. The outcome is an **edit to the order** in `ROADMAP.md`/`HANDOFF.md`
  with a one-line reason at the marker, not a paragraph of reasoning the next session skips.
- **`run-cycle` STEP 5 applies the same placement test** to any release item in the backlog, and
  logs the move under Roadmap Revisions.
- **`run-cycle`'s "do not perform the release" rule now says why**, and points at `/iyu:ship`: a run
  ends at a commit because pushing spends CI budget and publishing cannot be undone. If the run left
  the project at a point worth releasing, the End-of-Run Report says so and stops there.

## [1.28.0] — 2026-08-07

Driven by measurement rather than guesswork: 27,121 recorded invocations over ~7 months were
analyzed to see which skills were actually used and what users kept typing by hand.

### Removed

**`/iyu:run`, `/iyu:issue`, and `/iyu:pr` are gone.** There is no rename mechanism for skills, so
invoking them now yields an unknown command — read this section before upgrading.

- **Triage moved, it did not disappear.** The `issue-triage` skill (automatic, conversational) is
  the replacement and is where the work was actually happening: ask "should I accept this?" or
  "review this PR" in conversation and it activates. It absorbed the removed skills' references —
  `response-templates.md`, `research-methodology.md`, `tone-rules.md` — and now links them from its
  body at the step where each applies.
- **`/iyu:run` is `/iyu:run-cycle` with a budget of 1.** It was the earlier, single-phase form and
  had no capability the cycle runner lacks.
- Usage across the analyzed period: `/iyu:run-cycle` 1,052 invocations; `/iyu:run` 187, none after
  2026-04; `/iyu:issue` 171, none after 2026-03; `/iyu:pr` 4. `/iyu:telemetry-az` is **kept** despite
  0 invocations in the analyzed account — it is in active use by others, which is also the caveat
  that applies to any single-account measurement.

### Added

- **`/iyu:handoff` — session closeout.** The largest unmet need the analysis found: 1,510 distinct
  requests across 75 projects to update `HANDOFF.md`/`ROADMAP.md`, record where things stand, or
  propose the next scope — *more than `run-cycle` was invoked*. `run-cycle` already did this, but
  only for its own runs, and most sessions are not cycle runs. The skill reconstructs the session
  from `git log` and the continuity docs rather than the conversation (which may already be
  compacted), applies the hygiene pass, derives next scope across the user/developer/operator
  lenses, and separates human-blocked decisions from reversible ones it made itself. It does not
  commit and does not implement — either would change the state it is describing.
- **`skills/_shared/continuity-docs.md` — one definition, four readers.** Root resolution, what
  belongs in each document, the hygiene pass, and next-scope derivation were duplicated across
  `run-cycle`, `backlog-discover`, and `telemetry-az`, and adding a fourth copy for `handoff` would
  have guaranteed drift. All four now link to this file instead.

### Changed

- **Default cycle budget 5 → 10.** Observed usage is 10 (54%), 20 (30%), 5 (12%); the old default
  matched almost nobody, and invocations that omitted the argument got an unintentionally short run.
- **`run-cycle` Plan Discovery reads `<root>/HANDOFF.md` before `ROADMAP.md`.** 40% of invocations
  pasted a handoff path by hand — the handoff's "Next" is the previous session's considered judgment
  about what to do now, while the roadmap is direction not yet narrowed to a session. This is where
  `/iyu:handoff` and `run-cycle` meet.
- **STEP 3 verification now drives the real surface for user-facing changes.** 17% of invocations
  appended "use playwright" or similar. A green test suite is not evidence that a UI or CLI change
  works; exercise it on a browser-automation MCP, the CLI, or the running service and report what
  was observed. No runnable surface: skip with a reason — never add a dependency for this.

## [1.27.0] — 2026-08-07

Conformance pass against the current Claude Code skill/plugin specification. Three of these were
features that could not run at all.

### Fixed
- **The `run-cycle` Stop hook judged from conversation instead of from disk.** It was a
  `type: prompt` hook — a single tool-less LLM call — while its instructions told it to glob the
  cycle logs, read the latest *and previous* log, and confirm the End-of-Run Report exists. It did
  produce correct verdicts much of the time, by reading the log content still present in the
  conversation, but that is exactly what its own opening line forbids ("do not rely on conversation
  memory"): after a compaction, or whenever the answer depends on a log this turn did not write, the
  evidence simply is not there. It is now a `type: agent` hook (tool access, up to 50 turns) with
  `timeout: 180`, so it reads what it is told to read.
- **The hook was reading a budget it never received.** `$ARGUMENTS` in a hook prompt is the hook
  input JSON (`session_id`, `transcript_path`, `cwd`, …), not the skill's invocation arguments, so
  the cycle budget was simply absent from every `completed < budget` comparison. Each cycle log
  header now carries `Budget:` / `Start:` / `Status:`, and the hook reads them from disk — the same
  durable-state-over-memory rule the rest of the skill already follows. Because the hook can only
  trust a log *this* run wrote, a cycle's log is opened as a header-only stub when the cycle starts
  (the first in Preparation) and flipped to `Status: complete` when it ends; the hook counts
  completed logs only, and treats a newest log with no header at all as "this run wrote nothing yet"
  rather than as budget exhaustion.
- **The hook's answer format did not match the contract.** Prompt and agent hooks must return
  `{"ok": true|false, "reason": "…"}`; the prompt asked for the words BLOCK and ALLOW. The output
  contract is now stated explicitly.
- **`/iyu:issue --save` and `/iyu:pr --save` could not write anything.** Both skills forked into
  `agent: Explore`, whose tool set excludes `Write` — and `allowed-tools` grants approval, not
  capability, so listing tools there never helped. Both now fork into `general-purpose`, which also
  restores automatic CLAUDE.md loading for skills whose whole job is philosophy alignment.
- **Both triage skills returned asynchronously.** Since Claude Code v2.1.218 a forked skill runs in
  the background by default, which does not fit an interactive triage. Both set `background: false`.
- **`marketplace.json` failed `claude plugin validate --strict`** — `homepage` and `license` sat
  under `metadata`, which only recognizes `pluginRoot`. They moved to the plugin entry, where they
  are valid. Both manifests now pass `--strict`.
- Cross-skill reference links (`../mindset/references/…`) resolved against the working directory
  rather than the skill directory. All skill-to-reference links now use `${CLAUDE_SKILL_DIR}`.
- The plugin README's version badge pointed at a non-existent `./plugin.json`, and doc links across
  both READMEs pointed at the retired `docs.anthropic.com` paths.

### Changed
- **`run-cycle` takes one parameter: the cycle budget.** `--dry-run` and `--no-commit` are gone, and
  the starting cycle number is no longer passed — Preparation derives it from the existing logs
  (highest index + 1). Anything written alongside the invocation is read as scope context. Removing
  the flags also removes the positional-argument collision that made `/iyu:run-cycle --dry-run` read
  `--dry-run` as the cycle count. `/iyu:run` keeps its flags and now parses them flags-first.
- `backlog-discover`'s design rationale moved to `references/design-rationale.md`, bringing
  `SKILL.md` back under the 500-line guidance with a summary and a link in its place.
- `backlog-discover` and `telemetry-az` descriptions were compressed and their trigger text split
  into `when_to_use` (1497 → 1188 and 810 → 767 characters). Nothing was being truncated: both skills
  are `disable-model-invocation: true`, so their descriptions never enter the skill listing where the
  1,536-character cap applies. `backlog-discover` sitting at 1497 was a trap waiting for the day that
  flag comes off, not a live defect.
- `plugin.json` gained `$schema`, `homepage`, `repository`, and `license`; `marketplace.json` gained
  `$schema` and moved `description`/`version` to the top level.
- `CLAUDE.md` documented commands and agents this plugin does not ship, in a format Claude Code has
  since merged into skills. It now describes the skill frontmatter actually in use, plus the two
  traps this release hit: `allowed-tools` is approval rather than capability, and a `type: prompt`
  hook cannot read files.

## [1.26.0] — 2026-08-04

### Changed
- **Continuity root replaces hardcoded doc paths (`run-cycle`, `backlog-discover`, `telemetry-az`,
  `run`)** — a run's five
  durable artifacts (`ROADMAP.md`, `HANDOFF.md`, `HISTORY.md`, `cycle-logs/`, `RUN-SUMMARY-*.md`)
  now live in one *resolved* directory instead of a literal path baked into the skill. Resolution
  is first-match: an existing `cycle-logs/` anchors the root at its parent; otherwise an existing
  `ROADMAP.md`/`HANDOFF.md` anchors it at its own directory; otherwise `claudedocs/` is created as
  the default. This lets a repo keep the set wherever it already does — including an umbrella repo
  that nests it per submodule (`claudedocs/<Submodule>/`) — instead of getting a second roadmap
  created beside the one it already maintains. All four skills resolve the same root by the same
  rules — so the roadmap `backlog-discover` proposes into is the one `run-cycle` consumes and
  `run` executes, and the `telemetry/` + `issues/` directories `telemetry-az` writes are the ones
  `backlog-discover`'s telemetry and archive-mining lanes read.
- **Stop hook resolves the log directory from disk** — it has no session context, so it globs
  `**/cycle-logs/cycle-*.md` and, when several exist (an umbrella repo), takes the directory
  holding the most recently modified log. All of its reads — latest log, previous log,
  `RUN-SUMMARY-*.md` — come from that one directory, so a sibling submodule's logs cannot leak
  into the cycles-completed count. When *nothing* matches, cycles completed is 0 and evaluation
  continues (a run that stopped before writing its first log still blocks); an unresolvable
  directory is explicitly not a reason to allow.

### Fixed
- **`run-cycle` created a roadmap it would never read back.** Plan Discovery searched for a bare
  `ROADMAP.md` (repo root) while the phase-backlog step created `claudedocs/cycle-logs/ROADMAP.md`
  — so a project that already kept a roadmap got a second, empty one written elsewhere. Both paths
  now resolve through the same rule.
- Continuity docs found *inside* `cycle-logs/` (the pre-1.26 placement) are migrated up to the
  resolved root by Preparation step 0, which also prevents `<root>/cycle-logs/` from resolving
  recursively.
- `/iyu:run` discovered a bare `ROADMAP.md` (repo root) and so could miss the roadmap
  `/iyu:run-cycle` maintains; it now looks where the repo actually keeps it.
- `run/SKILL.md` frontmatter `argument-hint` was not valid YAML (unquoted bracket text) — the
  same defect fixed for `run-cycle` in 1.24.0, missed on that pass. All eight skills' frontmatter
  now parses.
- CHANGELOG was missing the 1.25.0 entry (added below).

## [1.25.0] — 2026-08-01

### Added
- **`stewardship-check` activity (`backlog-discover`, sprint cadence, deepen-ladder lane ①)** —
  dependency currency, project configuration, doc/link hygiene, and repo hygiene, verified by
  *running* the checks rather than reasoning about them. Forward-looking discovery alone lets what
  already exists decay unobserved; this is the upkeep half of the same job.

### Changed
- **Stop-hook inputs become tokens rather than prose (`run-cycle`)** — the frontier verdict is
  written as `FRONTIER-OPEN:` / `FRONTIER-EXHAUSTED:`, read literally by the hook; neither token
  present means derivation was skipped, which is never a valid stop. Cycles are counted relative
  to `start_cycle` rather than by raw log-file count, so a repo carrying logs from an earlier run
  can no longer read as already over budget and allow a stop before any work is done.
- Rule 9 designated the normative home for the termination test; the trigger matrix, rule 2, and
  the value ladder defer to it instead of restating it. Philosophy alignment points at the shared
  four-dimension guide, with Dependency Direction separated out as a run-specific extra.
- Commit boundary stays one per run by default, splitting on verified-cycle boundaries only when a
  long run's single diff stops being reviewable. The End-of-Run Report closes with a backlog-refill
  pointer when the run ended on an exhausted frontier with budget left.
- **Cadence mechanisms repaired (`backlog-discover`)** — `nowUtc` established once via `date -u`
  (nothing previously obtained it, so a guessed timestamp could corrupt future due-checks);
  symptoms diagnosed in the last 3 runs suppressed (first-match-wins on an almost-always-true
  row-1 condition left six rows and a 14-item rotation pool unreachable); the always-cadence floor
  separated from the deepen ladder; stable item ids with re-discovery against the last two
  proposals; three `runUtc`-joined histories collapsed into one `history[]`; a first-run split that
  runs an ordered core to completion instead of touching twenty lanes shallowly; and `--dry-run`
  bounded to read-only lanes.

## [1.24.0] — 2026-08-01

### Added
- **Synthesis stage `P6` (`backlog-discover`)** — discovery no longer ends at a flat tagged list.
  Every run now produces a four-axis **현재 상태 진단** (비전 대비 지점 · 시장 내 자리 · 도메인
  적합성 · 내부 체력, each observed or explicitly "이번 주기 미관측") closing with a one-sentence
  verdict; an **중요도 판정** scoring 비전 기여도 × 철학 정렬 × 증거 강도 into a value score, with
  비용·리스크 scored separately and used only for placement; and a **단계 구성** onto 지금/다음/나중.
  Horizons are an *ordering, never a schedule* — no cycle numbers, dates, or durations, mirroring
  the roadmap-is-a-phase-backlog invariant. Scoring tables and overriding constraints live in the
  new `references/synthesis-rubric.md`.
- **Inquiry axis (`SW기술` / `도메인전문`) as a second, co-equal tag** — recorded per item alongside
  the value axis, aggregated per run in `state.json.inquiryAxisHistory`, and reported in the
  proposal. Research drifts naturally toward how the product is *built* while the subject area it
  is *for* gets treated as settled; the skew is now detectable, is its own diagnosable symptom
  ("도메인 이해가 정체돼 있다"), and is reported rather than silently rebalanced.
- **Five playbook activities** — `research-scan` (papers/theory, **two mandatory axes**: the
  implementation's algorithms *and* the subject area's own methods and evaluation criteria),
  `domain-practice` (the domain's standards bodies, normative change, practitioner workflows, and
  the tools domain experts reach for), `appropriate-tech` (adoption verdict `채택/시범/보류/기각`,
  central test: "does the problem it solves actually exist in this product?"), `positioning-review`
  (누구를 위한 것인가 / 무엇으로 선택받는가 / 무엇을 하지 않기로 했는가, tested against evidence),
  and `tooling-development` (repeated manual work asset-ized into scripts/harnesses/generators —
  team throughput, distinct from product refactoring). `benchmarking` additionally compares how each
  competitor *models the domain*, not only what it ships.
- **Dry-backlog deepen ladder (`P1`)** — when the always-on dogfooding floor yields little, dig
  successively: ① 실사용 → ② 기술 건전성·도구 → ③ 지식 (기술 이론 + 도메인 이론·실무) → ④ 시장·포지션,
  forcing the named activities due and stopping at the first productive lane. Only after ④ is
  "nothing to propose" a grounded verdict; the diagnosis is written either way.
- **Self-unblock check before parking (`run-cycle`)** — a `BLOCKED-ITEM` may only be parked after a
  bounded attempt to remove the blocker: is the resource actually missing (look, don't assume), is
  the "user-only decision" already answered in a governing doc / accepted issue / prior ledger
  entry, can a useful slice proceed without the blocked part, and is it really L2 rather than a
  reversible L1. Ledger entries now record what was tried, so an *assumed* blocker cannot stall a
  run that still has budget.

### Changed
- **Stop hook gains two enforcement clauses (`run-cycle`)** — the hook is the run's only durable
  enforcement surface, so it now also (a) performs a **ledger-continuity check** against the
  previous cycle log, blocking when an entry was neither carried forward nor resolved, and
  (b) requires the **End-of-Run Report to exist before any ALLOW**, including at the budget
  ceiling (the one permitted block there, resolved by writing the report).
- Process steps `P6`–`P8` renumbered to `P7`–`P9` to make room for synthesis; proposal template
  gains 현재 상태 진단, 우선순위 및 단계 구성, and 기술 채택 판정 sections plus per-item 판정/배치 fields.

### Fixed
- `run-cycle` frontmatter `argument-hint` was not valid YAML (an unterminated quoted scalar
  followed by bare bracket text); now a single quoted string.
- CHANGELOG was missing the 1.23.0 entry (added below).

## [1.23.0] — 2026-07-21

### Added
- **Continuity-doc hygiene (`run-cycle`)** — `ROADMAP.md`/`HANDOFF.md` hold remaining work only.
  STEP 5 migrates every completed phase/item found (pre-existing leftovers included) into a
  same-directory `HISTORY.md` pure index linking to cycle logs, rewrites the handoff to
  current + next only, and keeps a `> History:` link atop each continuity doc. A still-long doc
  (~200+ lines) after migration is treated as a "detail at the wrong layer" signal.

### Changed
- The lean check folds into the ladder-② doc-sync floor and the release-readiness Docs item.
  Hygiene never gates termination; Stop-hook logic unchanged.

## [1.22.0] — 2026-07-17

### Added
- **Autonomy leveling by stakes × reversibility (`run-cycle`)** — decision handling is now an
  explicit four-level overlay so the run behaves like a capable delegate instead of asking about
  every choice. **L0** (taste/convention) is decided silently; **L1** (a real trade-off but a
  *reversible* two-way-door choice) is self-decided, acted on immediately, and recorded
  `provisional`; **L2** (irreversible or human-only, other work independent) is batched; **L3**
  (run-fatal) issues HARD STOP. The bias is **in-dubio-pro-autonomy** — ambiguity between L1 and
  L2 resolves to L1 — with the sole exception that an irreducible cross-lens conflict escalates.
- **Decisions Ledger** — a persistent Carry-Forward bucket accumulating `provisional` L1
  self-decisions (decision · alternatives · trade-off · cross-lens rationale · cost-to-reverse ·
  status), carried forward and re-checked at each STEP 0. It *never gates termination* — the run
  proceeds on provisional decisions and lets the human confirm/reverse afterward.
- **End-of-Run Report** (`RUN-SUMMARY-{date}.md` + final chat response, generated on every
  termination path) — the delegate's report-to-manager in three parts: progress/achievements with
  evidence, deferred L2 decisions awaiting the human, and self-made L1 decisions each with its
  trade-off and a one-line "to correct". Anchored just before the final commit.

### Changed
- **Five decision lenses are co-equal, not a priority chain (`run-cycle` rule 2.5)** — the former
  `근본 > 정석 > 표준 > 세련 > philosophy` lexicographic order is replaced by weighing all five
  *together* and picking the option best across them as a whole. A one-line rationale log becomes,
  for L1, a full Decisions-Ledger entry.
- **Dual-channel correction intake** — a reverted L1 decision is absorbed from conversation
  (Preparation §1) *and* written durably to the ledger so a compaction cannot lose it, then
  re-opened at the next cycle's STEP 0 as new scope re-evaluated *together with whatever was built
  on top of it* (not a blind swap to the opposite option).
- L0–L3 are an explanatory overlay only: the `HUMAN-NEEDED:` / `BLOCKED-ITEM:` markers and the
  Stop-hook termination logic are unchanged (L2 = BLOCKED-ITEM, L3 = HARD STOP). Backward-compatible:
  arguments unchanged.

## [1.21.0] — 2026-07-03

### Changed
- **Active dogfooding — live use, not passive re-mining (`backlog-discover`)** — the always-on
  dogfooding activity is redefined from re-reading already-recorded friction to **driving the
  product live in a fresh, vision-anchored scenario** on its real runnable surface (CLI /
  library consumer-script / service HTTP; pure-GUI surfaces skip-with-reason), observing
  feature/UI/UX/app-flow gaps first-hand. An empty or recently-run backlog becomes a
  **deepen-signal** ("go use the product, re-check the vision"), not a done-signal. The
  mindset "no invention" rule is reconciled by a **run-evidence discriminator**: every
  active-use finding must carry commands run + behavior observed + steps walked, or it is
  dropped as a guess. Concrete defects route to `claudedocs/issues/`; only systemic/UX/vision
  gaps become proposal items. Adds `dogfooding.scenariosRun[]` scenario-rotation state.

## [1.20.0] — 2026-07-03

### Added
- **Playbook-driven backlog discovery (`backlog-discover`)** — a new skill, fully independent
  of `run-cycle` (which only *consumes* `ROADMAP.md`), that adaptively runs a convergent /
  emergent research playbook — vision-gap analysis, web/trend research, benchmarking,
  `telemetry-az` output reuse, voice-of-customer mining, technical-debt/security audits, plus
  deliberately emergent techniques (pre-mortems, subtraction sessions, chaos engineering) —
  selected via **persistent per-activity cadence** (`claudedocs/backlog-discovery/state.json`)
  and **self-diagnosed backlog symptoms**, falling back to round-robin rotation. Every
  discovery is tagged by source activity and value axis and lands in a **human-reviewed
  proposal document only** — `ROADMAP.md` is never auto-merged, since these discoveries are
  speculative/external rather than `run-cycle`'s narrow in-cycle derivation.

## [1.19.0] — 2026-07-01

### Changed
- **Human blockers no longer end the run prematurely (`run-cycle`)** — human blockers are
  now split into two kinds that behave oppositely. A **run-fatal HARD STOP** (`HUMAN-NEEDED:`,
  a constitution conflict or structural invalidation that poisons *all* remaining work) still
  terminates the whole run. But an **item-level `BLOCKED-ITEM:`** (one scope needs a credential
  or a user-only decision, while other work stays independent) is *parked* in a new persistent
  **Blocked-on-Human ledger** and the cycle **falls through to the next unblocked candidate**
  instead of stopping. This fixes the observed early-termination where the first human blocker
  killed the entire run even though independent backlog / carry-forward / emergent work remained.

### Added
- **Blocked-on-Human ledger** — a persistent Carry-Forward bucket that accumulates parked
  item-level blockers (scope + blocker + what would unblock it), carried forward and re-checked
  at each cycle's STEP 0. Added to the trigger matrix (🔵 BLOCKED row), STEP 5 buckets, and the
  cycle-log template.
- **Termination redefined** — the run now terminates only when **every** remaining candidate
  (backlog phase, Carry-Forward item, autonomous-eligible emergent capability, ladder signal)
  is done or parked in the ledger — i.e. no unblocked autonomous work remains anywhere — AND
  the frontier + ladder are explicitly judged exhausted. The Stop hook, value ladder, and rules
  2 / 2.5 / 9 were updated so an item-level blocker never forces ALLOW while unblocked work
  exists. Backward-compatible: arguments unchanged.

## [1.16.0] — 2026-06-26

### Added
- **Emergent scope derivation (`run-cycle`)** — STEP 5 (Derive Next) is now an *active
  derivation* engine, not just a reactive record. After building a capability, the cycle
  derives the natural follow-on its own output implies — from three stakeholder lenses
  (**user / developer-maintainer / operator**) — and runs every candidate through a
  **derivation gate**: pattern-following completion within the project's declared role
  becomes autonomous next scope, while anything opening a new product direction, paradigm,
  dependency, or real trade-off is routed to a human-decision proposal (never self-decided).
  This addresses the observed failure where a cycle found no defects, saw a stable roadmap,
  wrote "Next-Cycle Scope: none", and terminated even though the capability it just built
  was visibly incomplete (e.g. file upload with no validation / multi-file / safety follow-up).

### Changed
- **Termination requires explicit frontier-exhaustion judgment** — early stop now demands a
  *stated* "feature frontier exhausted" judgment in the cycle log (across all three lenses),
  not an unfilled blank. The Stop hook treats an empty Emergent Next Capability line as
  "derivation skipped" (continue), and only allows termination when both the frontier and the
  value ladder are explicitly exhausted. Cycle-log template adds an **Emergent Next Capability**
  line; value-ladder track ① now counts an autonomous-eligible emergent capability as main-loop
  work. Backward-compatible: arguments unchanged.

## [1.15.0] — 2026-06-24

### Changed
- **Just-in-time scoping (`run-cycle`)** — the runner no longer plans all `N` cycles
  upfront. Concrete scope now exists for **one cycle at a time** (the current one); the
  roadmap is a phase-level backlog that **never knows cycle numbers**, and each cycle's
  STEP 5 decides the *next* cycle's scope once it knows what that cycle revealed. `N` is
  now explicitly a **ceiling, not a target** — never pre-partitioned into `N` scopes.
  This fixes an observed failure where `/iyu:run-cycle N` produced a binding `Cycle 1 = …,
  Cycle N = …` table under a "directional" label, collapsing the multi-turn structure back
  into a single turn. Work too large for a cycle (or deserving its own) is now promoted to
  the next cycle instead of being pre-assigned. Backward-compatible: arguments and cycle-log
  format are unchanged.

## [1.14.0] — 2026-06-24

### Added
- **Release-readiness check (`run-cycle`)** — a lightweight checklist absorbed into
  the end-of-run commit step (skipped on `--no-commit` / `--dry-run`). Verifies version
  consistency across version-bearing files, CHANGELOG coverage, doc-sync, and packages
  the actual verification output as an evidence block in the final cycle log. It verifies
  and packages only — it never tags, publishes, or pushes; the release stays with human/CI.

## [1.13.0] — 2026-06-24

Identity release — formalizes the plugin's constitution and generalizes the
adaptive cycle into a full software-lifecycle model.

### Added
- **Constitution (`mindset`)** — three governing principles made explicit:
  Minimal Intervention, Critical-but-Constructive (Rule of Law), Adaptive Iteration.
- **Rule of Law / amendment protocol** — human instructions are subordinate to the
  project constitution (CLAUDE.md / philosophy / architecture). A conflict triggers a
  documented amendment (revise the instruction *or* propose a concrete diff to the
  governing doc), never silent compliance and never unilateral override.
- **No-invention rule** — data not directly observed stays "unknown"; guesses are
  never presented as fact (`mindset`, `run-cycle` execution rule 7.5).
- **Surplus-Cycle Value Ladder (`run-cycle`)** — when primary work is exhausted and
  cycles remain, the run climbs a lifecycle ladder instead of stopping:
  ① main loop → ② durable value (research → refactoring → docs/assets)
  → ③ stability (tests/monitoring → security/compliance → resilience)
  → ④ efficiency (DevOps → DX). Signal-gated; additive work is done in-cycle,
  invasive work is proposed for human decision.
- **Regression back-flow** — a defect surfaced in any surplus track returns the run
  to the main loop; defects always outrank surplus value.
- **Durable-state-over-conversation** — cycles reconstruct state from on-disk logs so
  the run survives native context compaction without an external reset loop.
- **Evidence-based verification** — completion is proven by command output, not asserted.
- **`AGENTS.md`** added to the plan-discovery chain.
- **Reference tables of contents** added to long reference files (>100 lines).

### Changed
- `run-cycle` HARD STOP trigger now follows the constitutional amendment protocol.
- Early-termination doc-sync gate generalized into the value ladder (doc-sync is its floor).
- Plugin `keywords` consolidated as the single source, mirrored into the marketplace entry.

## [1.12.1] — 2026

### Added
- `run-cycle`: documentation-consistency gate before early termination.

## [1.12.0] — 2026

### Added
- `telemetry-az`: run-over-run user-analytics report (cadence-normalized, bounded history).

## [1.11.1] — 2026

### Fixed
- `telemetry-az`: corrected `az` CLI usage; strengthened analysis.

## [1.11.0] — 2026

### Added
- `telemetry-az`: Azure Application Insights telemetry triage skill — defects,
  performance regressions, feature-drop signals; files issues for threshold-crossing findings.
