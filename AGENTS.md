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
hooks:                              # lifecycle hooks scoped to this skill
  Stop:
    - hooks:
        - type: agent               # `prompt` = single LLM call, no tools; `agent` = tool access
          timeout: 180
          prompt: |
            … respond {"ok": true|false, "reason": "…"}
---
```

Two traps worth restating, both hit this plugin before:

- **`allowed-tools` grants approval, not capability.** What a forked skill *can* do comes from its
  `agent` type — `Explore` has no `Write`, so a skill that saves a file must not fork into it.
- **A `type: prompt` hook cannot read files.** It is one LLM call over the hook input JSON. Any hook
  that inspects the repo needs `type: agent` (tools, up to 50 turns) or `type: command`. Its
  `$ARGUMENTS` is the hook input JSON, never the skill's invocation arguments.

## Current Plugins

### iyu (v1.33.0)

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
| `/iyu:run-cycle [N]` | Adaptive cycles: re-plan → design → execute → verify → reflect → derive-next, `N` a ceiling | capable **employee** |
| `/iyu:handoff` | Session closeout: continuity docs, next scope, re-ordering, decisions *flagged* (not briefed) | capable **team lead** |
| `/iyu:resume` | Session opener: reads what handoff left, *briefs* flagged decisions, records the pick immediately | the one **picking up the memo** |
| `/iyu:ship` | Bump → commit → push → watch CI → publish, each stage stoppable | — |
| `/iyu:backlog-discover` | Research playbook → diagnosis, ranking, staged proposal (never auto-merged) | capable **owner-manager** |
| `/iyu:telemetry-az` | App Insights triage: defect issues + report-only usage trends | capable **analyst** |

**Shared definitions live in `plugins/iyu/skills/_shared/` and are linked, never restated** — four
copies of a rule become four rules the moment one is edited:

| File | Defines | Read by |
|---|---|---|
| `continuity-docs.md` | root resolution · what belongs in each doc · hygiene pass · next-scope derivation | run-cycle, handoff, resume, backlog-discover, telemetry-az |
| `release-cadence.md` | three stages/three costs · the placement test · cadence declaration · reorder-don't-explain | run-cycle, handoff, ship |
| `decision-briefing.md` | the two entry shapes · the four parts of a briefing · the guards | run-cycle, resume, ship |
| `decision-lenses.md` | the five co-equal lenses (근본/정석/표준/세련/철학) | run-cycle (self-decide), resume (brief) |

The four canonical philosophy dimensions live only in
`skills/mindset/references/philosophy-alignment-guide.md`.

**Invariants — easy to break while editing a skill, expensive to notice later:**

1. **The Stop hook is the only enforcement surface, and it matches literal tokens.**
   `HUMAN-NEEDED:` · `BLOCKED-ITEM:` · `FRONTIER-OPEN:` · `FRONTIER-EXHAUSTED:` are strings the hook
   greps for. Rewording one silently disables the check it gates. The hook has no session context —
   anything it needs (budget, start index) must be written into the cycle log header.
2. **The roadmap is a phase backlog.** No cycle numbers, dates, or durations anywhere — in
   `run-cycle`'s roadmap or `backlog-discover`'s horizons. Concrete scope exists for one cycle only.
3. **Continuity docs hold remaining work only.** Completed work belongs in `HISTORY.md`.
4. **Autonomy bias is in-dubio-pro-autonomy.** L1 (reversible) is self-decided and recorded; only
   irreversible-or-human-only work escalates. A new rule that makes escalating easier or more
   attractive inverts this — check any decision-facing change against it.
5. **Keep `SKILL.md` under 500 lines, and move rationale to `references/`.** The line tip exists
   because a loaded skill's body is a recurring token cost; instruction stays inline, explanation
   moves out.

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
