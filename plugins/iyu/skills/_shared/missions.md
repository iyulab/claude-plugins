# Missions — the shared definition

**Contents** — 1. What a mission is · 2. Why the setter is blind · 3. Where it lives · 4. The missions file · 5. Who may write what · 6. Verdicts and findings · 7. Where findings go · 8. Missions and the stage contract · 9. Products without a screen · 10. Cost

**This file is the single definition** of missions and walks. `walk` sets and walks them; other
skills that read them link here. Copies drift; link here.

Terms used the same way everywhere: **mission** (a user's purpose, set outside the product, ending in
an observable result), **persona** (who holds it), **variation** (the same mission off the happy
path), **setter** (the blind model call that writes missions), **walker** (the separate subagent that
tries them on the running product), **walk** (one pass of the walker, numbered).

---

## 1. What a mission is

A purpose that starts **outside the product** — a situation, a trigger — and ends in a result
someone could **observe**. It names no screen, button, command or endpoint. That is the difference
from a stage scenario ([stages.md](stages.md) §3): a scenario is a script for one build, telling the
observer where to click; a mission says only what the person wants, so walking it measures whether
they can *find* the way as well as whether the way works.

Missions are upstream, scripts are derived. A stage's scenarios are one build's answer to some of
the missions; the missions outlive the build.

## 2. Why the setter is blind

A list of user purposes written by someone who knows the build drifts toward what the build
already does — the gaps it should expose are exactly the ones its author cannot see. A rule such as
"do not open the code first" does not hold in a session that has already read it, and a subagent
starts inside the repository with file tools. So the setter is **a separate model call with no
tools, no settings, no project instructions, in an empty directory**
([walk/scripts/set-missions.sh](../walk/scripts/set-missions.sh)), and it receives only the
**purpose material**, quoted:

- the stage contract's `goal`, when there is a contract — the `goal` only;
- the project's own statement of what it is for and who it is for — the opening of the README or
  scope document, a landing page's copy;
- the use environment, when the project states it in its users' terms (device, setting,
  connectivity).

Quote, do not summarise: a summary in the words of a session that knows the code carries the code
back in. Leave out feature lists, usage and API sections, the roadmap, the contract's scenarios,
`user_can` and `surface` (they name the build's parts), and the non-goals — a setter told the non-goals writes missions around them, and finding
a purpose that runs into a non-goal is one of the things a walk is for (§7).

The walker cannot be blind the same way — it needs the tools to build and drive the product. It is
told to find the way as the persona would and to read source only after a verdict, to name a cause;
that is an instruction, not an enforced boundary. What is enforced is that it cannot change the
missions it is judged against (§5).

## 3. Where it lives

Under the continuity root ([continuity-docs.md](continuity-docs.md) §1):

| Artifact | Path | Written by |
|---|---|---|
| Missions + verdicts | `<root>/missions/missions.json` | the setter (mission text, via `walk`), the walker (verdicts) |
| The purpose material the setter saw | `<root>/missions/purpose.md` | `walk` |
| Walk reports | `<root>/missions/walks/<NN>.md` | the walker; `## Routing` by `walk` |
| Walk evidence | `<root>/missions/walks/<NN>/` | the walker |

**The missions file is a contract artifact, not a continuity doc**, like `<root>/stages/`: it keeps
achieved missions on purpose — walking them again is how a regression shows — so the completed-work
rule does not apply and `docs-lint` does not read it.

## 4. The missions file

```json
{
  "purpose": "missions/purpose.md",
  "set": [{"set": 1, "build": "a1b2c3d", "model": "sonnet"}],
  "personas": [
    {"id": "P1", "who": "Shift supervisor, uses it every morning", "skill": "daily", "motive": "start the shift knowing what broke overnight", "set": 1}
  ],
  "missions": [
    {"id": "M-07", "persona": "P1", "kind": "exception", "set": 1, "state": "active",
     "situation": "Back from a site check, an alarm call waiting",
     "trigger": "Needs to know whether the same unit failed the same way yesterday",
     "goal": "Yesterday's and today's readings for that unit side by side",
     "expects": ["lands back where they were after signing in", "every value shows when it was read"],
     "variations": [{"text": "yesterday has no data", "verdict": null},
                    {"text": "the session expires midway", "verdict": null}],
     "verdict": null, "walked": null}
  ]
}
```

- `kind`: `daily` · `first-use` · `exception` · `repeat` · `crossing`. A set mixes them.
- `state`: `active` or `retired`. Re-setting never deletes: the old missions become `retired`, so
  what used to be measured stays on record.
- `walked`: `{"walk": "<NN>", "build": "<commit>"}` — a walk number and a build, never a date.
- Ids are bookkeeping, assigned by `walk` in order (`M-01` …), and continue across sets.
- Default size of a set: 3–5 personas, 3–5 missions each. A starting point, not a ceiling — every
  walked mission is a real run of the product (§10).

## 5. Who may write what

| Field | Writer |
|---|---|
| persona and mission text (`who` … `variations[].text`) | **the setter only** — `walk` copies its output verbatim and adds `id`, `set`, `state` |
| `verdict`, `walked`, `variations[].verdict` | **the walker only** — the agent that judges is not the agent that builds |
| `state` → `retired` | `walk`, when it re-sets |

An implementer never edits a mission to make it pass. A mission that looks wrong is raised with
evidence (the walker's *Mission concerns*, or to the owner) and replaced by re-setting, which retires
it on the record.

## 6. Verdicts and findings

Verdicts, for a mission and for each variation: `achieved` · `friction` · `blocked` · `absent` ·
`unverified`. **`unverified` is a verdict, not a footnote**: a mission judged from code, a stub, or
not at all is `unverified`, never `achieved`.

Findings carry one type: `missing` · `broken-flow` · `discoverability` · `mismatch` · `robustness` ·
`defect` (with steps to reproduce) · `excess` (an entry point no walked mission passed through).

## 7. Where findings go

The walk observes and does not repair — mixing the two blurs the verdict. But a finding left in the
report is lost, so `walk` routes every one, and records the route under the report's `## Routing`:

| Finding | Route |
|---|---|
| `defect`, `robustness` | an issue draft (`<root>/issues/`) |
| `missing` · `broken-flow` · `discoverability` · `mismatch` | with an open stage: *inside the open stage* — a gap no signed scenario covers, or one a passing scenario misses, is a contract concern for the owner (scenarios change only through `charter`), and a bug in what a scenario covers is an issue draft; *a later stage* or anything else → `parking.md` ([stages.md](stages.md) §8). Without one: inside the project's declared role and reversible → a `ROADMAP.md` phase, recorded as a self-decision with how to undo it; a new direction, surface or dependency → a proposal for the owner |
| `absent` against a non-goal | not a finding — a promise deliberately not made; note it. Several missions on the same non-goal → an item for the next stage boundary |
| `excess` | an issue draft (a removal candidate); if it backs a claim the product makes, an item for the owner |
| a mission concern, or a contract that measures the wrong thing | for the owner, with the walk as evidence; the contract changes only through `charter` |

## 8. Missions and the stage contract

Missions are **not** a condition for passing a stage. A stage passes on its signed scenarios, bar,
claims and the owner's look ([stages.md](stages.md) §5). Missions are the outside measure of whether
that contract measures the right things: a walk that finds `blocked` or `absent` inside what a
passed stage says a user can do is evidence for the owner at the next stage boundary, not a failed
stage. Making missions a pass condition would widen a signed contract without a signature, and give
the builder a reason to want them loosened.

`walk` maps missions to stages in the routing — which missions some stage covers, which none does
(an empty rung of the ladder), which stage scripts no mission needs.

## 9. Products without a screen

The method does not change; the user does. A library's users are consuming developers, a CLI's are
operators and scripts, a service API's are integrating developers, an agent tool's are agents. The
setter brief carries the table. **Discoverability holds everywhere**: whether the README, help text,
tool descriptions and error messages tell the person the next move.

## 10. Cost

Every walked mission and variation is a real run of the product, and on a UI surface a browser
session — a heavy verification. Walk the whole set when the purpose material changed, at a stage
boundary, before a release, or when the owner asks; otherwise walk the missions not yet walked on
this build and those that pass through what changed.
