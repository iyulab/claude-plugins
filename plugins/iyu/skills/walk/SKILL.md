---
name: walk
description: Measures a product from its users' purposes instead of its own feature list — a blind setter (a separate, tool-less model call that sees only what the project says it is for) writes personas and missions, an independent walker subagent tries each mission and its variations on the running product as that person would, and every finding is routed to an issue draft, the roadmap, the stage parking lot, or the owner. Changes no product code.
argument-hint: "[--reset] [--all] [mission ids]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Agent
---

# Walk — try the product the way its users would

The point is order: **fix what people come to do before looking at what the product does**, then
find out whether they can do it. Missions, the blind setter, field ownership and where findings go:
**[missions.md](${CLAUDE_SKILL_DIR}/../_shared/missions.md)** — read it first.

## Process

### 1. Resolve and decide what to walk

Resolve `<root>` ([continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §1).

- **No `<root>/missions/missions.json`, or `--reset`** → set missions first (step 2).
- **Otherwise** → walk: the ids in `$ARGUMENTS`; with `--all`, every `active` mission; with neither,
  the `active` missions whose `walked.build` is not the current build, plus those passing through
  what changed since their last walk (missions.md §10).

### 2. Set missions — blind

1. **Gather the purpose material and nothing else** (missions.md §2): quote it verbatim with its
   source path into `<root>/missions/purpose.md`. With a stage contract, its `goal` comes first. If
   the project states no purpose anywhere — no contract goal, no README or scope document that says
   what it is for and for whom — stop: say what is missing and that `/iyu:charter` or a README
   opening would supply it. Do not write a purpose yourself.
2. **Run the setter**: `sh "${CLAUDE_SKILL_DIR}/scripts/set-missions.sh"
   "${CLAUDE_SKILL_DIR}/references/setter.md" <root>/missions/purpose.md <a temp file>`. Exit `2`
   means no JSON came back — run it once more, then stop and report. Do not write missions yourself
   or ask a subagent to: either would see the code.
3. **Record verbatim** into `missions.json` (schema in missions.md §4): personas and missions as
   returned, adding only `id`, `set`, `state: active`, variation objects with `verdict: null`, and a
   `set` entry with the current commit. With `--reset`, mark every earlier mission `retired` first.
   Show the user the personas and mission goals in a short list, and the setter's `unclear` lines.

### 3. Walk — independent

Pick `NN`, the next unused walk number. Dispatch **one** `Agent` call (`subagent_type:
general-purpose`) whose prompt is the full text of
[references/walker.md](${CLAUDE_SKILL_DIR}/references/walker.md) followed by absolute paths to
`missions.json` and `<root>/missions/walks/`, the walk number, the missions to walk, the surface, and
the command that builds and starts the product (the stage contract's `run`, else the project's
documented one, else "none"). Pass nothing about how the product is built inside.

### 4. Route — every finding has somewhere to go

Read the report. Only now compare it with the project's own records: the stage contract and its
non-goals, `parking.md`, `ROADMAP.md`, the issue drafts. Route each finding by missions.md §7 —
write the issue drafts, the `ROADMAP.md` phases with their self-decision record, the `parking.md`
lines — and fill the report's `## Routing`: each finding's route, and the mission × stage map
(missions.md §8).

### 5. Report

A few lines: verdict counts, the findings by type with where each went, what was `unverified` and
why, and the mission concerns. Name what the owner should look at — only the routes that need them.

## Standing rules

- **No product code changes.** Defects go to issue drafts; building is `drive`'s or `run-cycle`'s.
- **The setter's text and the walker's verdicts are theirs** (missions.md §5). This skill copies,
  numbers, routes — it does not reword a mission or reconsider a verdict.
- **A walk is a heavy verification.** Walk only what step 1 selected; `--all` is for a stage boundary,
  a release, a changed purpose, or when asked.
- Output language: [continuity-docs.md](${CLAUDE_SKILL_DIR}/../_shared/continuity-docs.md) §5.
