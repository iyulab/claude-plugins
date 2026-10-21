# AGENTS.md

Guidance for coding agents working in this repository. Claude Code reads it through the one-line
`CLAUDE.md` at the repo root, which imports this file.

## Repository Overview

Claude Code plugin marketplace - a collection of plugins designed for library maintainers and developers.

**Philosophy**: "Every issue is an opportunity" - plugins help maintainers find the best path forward beyond simple accept/reject decisions.

## Architecture

### Marketplace Structure

```
.claude-plugin/
└── marketplace.json          # Root registry (plugins list, version metadata)

plugins/
└── [plugin-name]/
    ├── .claude-plugin/
    │   └── plugin.json       # Plugin metadata (name, version, keywords)
    ├── skills/               # Every component of this plugin
    │   └── [skill-name]/
    │       ├── SKILL.md      # Skill definition (frontmatter + body)
    │       └── references/   # Supporting documentation, loaded on demand
    ├── evals/                # `claude plugin eval` cases (results/ is git-ignored)
    └── README.md
```

**Custom commands are skills.** Claude Code merged the two: a flat `commands/*.md` file and a
`skills/<name>/SKILL.md` both produce `/<plugin>:<name>` and behave identically. Skills are the form
to write — they add a directory for supporting files and the frontmatter that controls invocation.
This plugin ships skills only; there is no `commands/` or `agents/` directory.

### Skill frontmatter — the fields this plugin uses

```yaml
---
name: skill-name                    # last segment of /iyu:<name> for a plugin skill
description: What it does + when    # description + when_to_use capped at 1,536 chars in the listing
argument-hint: "[total_cycles]"     # autocomplete hint only
disable-model-invocation: true      # user-invoked only; keeps the description out of context
user-invocable: false               # Claude-invoked only (mindset)
allowed-tools: Read, Glob, Bash(gh *)   # pre-approval for the invoking turn — NOT a restriction
context: fork                       # run in an isolated subagent
agent: general-purpose              # which agent type the fork uses
background: false                   # wait for the fork in the invoking turn (default: true)
hooks:                              # registered once the skill is invoked, for the rest of the session
  Stop:
    - hooks:
        - type: command             # a script; `prompt` = one LLM call, `agent` = an LLM with tools
          command: 'sh "${CLAUDE_PLUGIN_ROOT}/skills/run-cycle/scripts/stop-gate.sh"'
          timeout: 300
---
```

Traps worth restating, all hit this plugin before:

- **`allowed-tools` grants approval, not capability.** What a forked skill *can* do comes from its
  `agent` type — `Explore` has no `Write`, so a skill that saves a file must not fork into it.
- **A `type: prompt` hook cannot read files.** It is one LLM call over the hook input JSON. Any hook
  that inspects the repo needs `type: agent` (tools, up to 50 turns) or `type: command`. Its
  `$ARGUMENTS` is the hook input JSON, never the skill's invocation arguments.
- **Hooks on one event run in parallel, and any block wins.** A `command` hook cannot screen an
  `agent` hook beside it: each must be right on its own about when it blocks. In a skill's
  frontmatter, `${CLAUDE_PLUGIN_ROOT}` expands in a `command` and `${CLAUDE_SKILL_DIR}` does not; an
  `agent` hook's Bash obeys the session's permission mode, so it cannot be relied on to run a script.

## Current Plugins

### iyu (v1.46.0)

Productivity toolkit for open-source maintainers. **Design principle**: teach Claude what is
*different* about a project, not how to develop software — skills supply decision frameworks, Claude
handles the rest natively.

**A skill's own `SKILL.md` is the normative source for its behavior.** This section says what each
skill is and when to reach for it; it does not restate their mechanics. `plugins/iyu/README.md` is
the user-facing description. Read the skill file before changing a skill.

| Skill | What it is | Persona |
|---|---|---|
| `mindset` | Auto-activating "critical but constructive" maintenance philosophy | — |
| `issue-triage` | Auto-activating decision matrices for issue/PR triage discussions | — |
| `/iyu:run-cycle [N]` | Adaptive cycles: re-plan → design → execute → verify → reflect → derive-next, `N` a ceiling; early termination is audited against the backlog, not self-declared | capable **employee** |
| `/iyu:handoff` | Session checkpoint — at close (main use), mid-session before `/clear`, and as `run-cycle`'s last step: continuity docs, next scope, re-ordering, decisions *flagged* (not briefed) | capable **team lead** |
| `/iyu:resume` | Session opener: reads what handoff left, synthesizes/reprioritizes against current state, *briefs and pre-decides* flagged and derived decisions — researching, bounded, to reach a recommendation that becomes the provisional decision — records it immediately (applying a reorder to `## Next`), leaves the owner only blockers, owner-gated acts, and criterion requests, turns an override into a criterion question, then stops short of execution | capable **employee opening the session** |
| `/iyu:ship` | Bump → commit → push → watch CI → publish, each stage stoppable | — |
| `/iyu:backlog-discover` | Research playbook → diagnosis, ranking, staged proposal (never auto-merged) | capable **owner-manager** |
| `/iyu:telemetry-az` | App Insights triage: defect issues + report-only usage trends | capable **analyst** |

**Shared definitions live in `plugins/iyu/skills/_shared/` and are linked, never restated** — four
copies of a rule become four rules the moment one is edited:

| File | Defines | Read by |
|---|---|---|
| `continuity-docs.md` | root resolution · what belongs in each doc · one home per fact · hygiene pass · next-scope derivation · structural checks (`L01`–`L10`) | run-cycle, handoff, resume, backlog-discover, telemetry-az |
| `release-cadence.md` | three stages/three costs · the placement test (with a named receiver) · the frozen-batch gate, fixed before the work · cadence declaration incl. minimum interval · reorder-don't-explain · a run's release grant (permission, read once at run end) | run-cycle, handoff, ship |
| `decision-briefing.md` | the entry shapes (resource-blocked incl. owner-gated act · decision-class · criterion request) · the four parts of a briefing · the guards (decide ≠ act; ask for resources and criteria, never a pick) | run-cycle, resume, ship |
| `decision-lenses.md` | the five co-equal lenses (근본/정석/표준/세련/철학) · what is *not* a lens (scope size, request count, pre-1.0 breaking) · reversibility belongs to the act, not the edit · the four causes a pick won't form — (b)/(c) trigger bounded research, (a)/(d) turn into a criterion request | run-cycle (self-decide), resume (brief), mindset, philosophy-alignment-guide |
| `scripts/docs-lint.sh` | the §7 structural checks of `continuity-docs.md` as a read-only script — verdict per code, exit 1 only on an error-class violation, `UNCHECKED` whenever no verdict is reached | handoff, run-cycle (through `continuity-docs.md` §3 step 7) |

The four canonical philosophy dimensions live only in
`skills/mindset/references/philosophy-alignment-guide.md`.

**Invariants — easy to break while editing a skill, expensive to notice later:**

1. **The Stop hook is the only enforcement surface, and it matches literal tokens.**
   `HUMAN-NEEDED:` · `FRONTIER-OPEN:` · `FRONTIER-EXHAUSTED:` and the header lines `Budget:` ·
   `Start:` · `Status:` · `Run: cycles a–b` are strings the hook parses. Rewording one silently
   disables the check it gates. The hook has no session context — anything it needs must be written
   into a header. On the exhaustion path it hands `FRONTIER-EXHAUSTED:` to a separate read-only
   auditor model, with the latest log, the one before it and `<logs dir>/../ROADMAP.md`, to check it
   as a *claim* rather than accept it as a fact — a token the same agent both writes and reads is not
   verification.
2. **The roadmap is a phase backlog.** No cycle numbers, dates, or durations anywhere — in
   `run-cycle`'s roadmap or `backlog-discover`'s horizons. Concrete scope exists for one cycle only.
3. **Continuity docs hold remaining work only.** Completed work belongs in `HISTORY.md`.
4. **Autonomy bias is in-dubio-pro-autonomy.** L1 (reversible) is self-decided and recorded; only
   irreversible-or-human-only work escalates. A new rule that makes escalating easier or more
   attractive inverts this — check any decision-facing change against it.
5. **Measure a `SKILL.md` in tokens, not lines, and move rationale to `references/`.** The official
   500-line tip is a proxy for a token cost, and a proxy is gameable — `run-cycle` once passed it at
   476 lines while carrying 54KB on ~115-character lines. Two real ceilings sit behind it: a loaded
   body is a recurring cost on every turn, and **auto-compaction re-attaches only the first 5,000
   tokens of each skill** (~18,500 characters), with 25,000 shared across all re-attached skills. So
   a body past that line loses its tail exactly when a long run needs it. Instruction stays inline,
   explanation moves out — and **what a skill needs on every iteration goes before what it needs once
   per run**, with the rest reachable through a link named early enough to survive the cut.
6. **The Stop hook's BLOCK reason is the one instruction channel compaction cannot truncate.** It
   is a script that reads the logs, so a block restates the literal contract it turns on
   (invariant 1's tokens, the report's absolute path, opening line and parts). Keep it that way when
   editing the hook.
7. **Everything mechanical in the hook is a script; a model is asked only what needs reading.**
   The hook was an `agent` hook, and its recurring failures were a model doing bookkeeping: ranking
   logs by name or mtime instead of by number, missing the newest log once there were more than the
   100 files `Glob` returns, reading a header-less log from an earlier run as this run's, naming a
   second directory and then demanding the report there. So `scripts/stop-gate.sh` owns the takeover
   check, log resolution, numbering, counting, tokens and the report check, and a model sees only the
   exhaustion audit — handed resolved absolute paths, only read tools (`--tools Read,Grep,Glob`), and
   one question. Every failure to reach a verdict fails toward allowing: a premature stop is escaped
   by invoking again, a run that cannot end is not. The script runs at every turn end for the rest of
   the session, under Git Bash on Windows where each process costs a tenth of a second or more —
   parse with one `awk` per input, never a pipeline per file.
8. **The hook reads; it never writes — and every change is tested before release.**
   `scripts/hook-dryrun/` pipes a hook input into the script for each fixture and asserts the verdict,
   the reason, whether the auditor was asked, and unchanged file hashes. The auditor is a stub there
   (`IYU_RUN_CYCLE_AUDITOR`), so the suite is deterministic; `-LiveAudit` runs the real auditor on the
   fixtures that reach it, and passes a fixture only when every repeat does. Run the deterministic
   suite after any hook change and `-LiveAudit` after editing the audit prompt. A failure mode no
   fixture catches gets a fixture, and removing the gate it protects should make that fixture fail.
   `_shared/scripts/docs-lint.sh` follows the same rules — it reads and never writes, a check that
   reaches no verdict passes as `UNCHECKED`, one awk scans every document — and has its own suite,
   `scripts/docs-lint-dryrun/`, one fixture per sub-check, every code's verdict asserted. Run it after
   any change to the script or to the rules in `continuity-docs.md` §7 it implements.
9. **A skill's `description`/`when_to_use` is behavior, and the trigger evals are its test.** A
   model-invoked skill that is never chosen does nothing — `mindset` sat at 0/3 until its description
   said what it does and when. After editing either field, run
   `claude plugin eval plugins/iyu --ablation none --no-publish` and keep `no-skill-for-general-question`
   passing so a wider description does not over-trigger. `version` and every other per-plugin field
   live only in `plugin.json`, never on the marketplace entry.

## Adding a New Plugin

1. Create `plugins/[name]/` with `.claude-plugin/plugin.json`
2. Add commands, skills, or agents as needed
3. Register in `.claude-plugin/marketplace.json`
4. Add README.md documenting usage

## Plugin Installation (End Users)

```bash
/plugin marketplace add iyulab/claude-plugins
/plugin install iyu@iyulab-plugins
```
