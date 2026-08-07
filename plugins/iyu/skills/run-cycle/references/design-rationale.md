# Development Cycle Runner — design rationale

Why `/iyu:run-cycle` has the shape it does. Read this when changing the skill's structure; the skill
body itself carries only the rule that follows from each point.

## Why cycles at all

A single upfront N-cycle plan followed by sequential execution is indistinguishable from one large
implementation — the "cycle" structure adds no discovery value. Real iterative work requires each
cycle to:

1. Re-check assumptions made at the start
2. Absorb what previous cycles learned
3. Be able to **change the plan** when reality diverges
4. **Derive the follow-on its own output now implies** — work that could not have been specified
   before the cycle existed

The per-cycle structure exists to keep that overhead bounded while leaving room for mid-flight
re-planning.

## The failure mode the roadmap rule prevents

The seductive trap — observed in real runs — is to label a plan "directional" while filling it with
a **cycle-numbered scope table** (Cycle 1 = X, Cycle 2 = Y, … Cycle N = Z). That is not a directional
roadmap; it is a binding N-cycle plan wearing a directional label, and it collapses the multi-turn
structure back into a single turn.

Hence: the roadmap must not know cycle numbers. Concrete scope exists for exactly one cycle — the one
you are in. The scope of cycle K+1 is *not yours to decide now*; it is decided by cycle K's STEP 5,
because only then do you know what cycle K revealed. This is **just-in-time scoping**: plan one
cycle, run it, let it tell you the next.

## Why STEP 5 derives scope instead of only inheriting it

Just-in-time scoping has a second half that is easy to miss: a cycle's *own output is a source of
the next cycle's scope*. A capability, once built, implies follow-on work that could not have been
named before it existed — you build single-file upload, and only then do "validate the upload",
"accept multiple files", "handle the empty/oversized case" become concrete.

**Failing to derive this emergent scope is the early-termination failure the user feels as "it only
did the initial plan and quit"**: a cycle finds no defects, sees a stable roadmap, writes
"Next-Cycle Scope: none", and stops — even though the capability it just built is visibly incomplete
to any user, developer, or operator of it.

Deriving it is not scope creep, because the autonomy bound is strict (the derivation gate in
STEP 5): only pattern-following completion inside the project's **declared role** is taken
autonomously. Anything opening a new product direction, dependency, paradigm, or genuine trade-off
is routed to proposals. "Frontier exhausted" stays a legitimate terminal state — it just has to be a
*stated judgment* carried by the `FRONTIER-EXHAUSTED:` token, not an empty blank.

### Worked examples of the derivation gate

- **Autonomous-eligible** — the codebase already has a drag-drop pattern elsewhere, so extending it
  to the new surface is pattern-following; adding validation to a new upload path.
- **Discussion / proposal-only** — introducing drag-drop where no such pattern exists yet;
  "multi-file" when it would change the product's data model.

The distinction is not size. It is whether the project has already committed to the pattern.

## Why decisions are leveled L0–L3

The levels key on **two axes — stakes × reversibility (two-way vs. one-way door)**. A capable
delegate does not escalate by *importance* alone; they escalate what is **irreversible or
theirs-alone**, and self-decide what is reversible. Asking about every consequential-sounding choice
is the "asks the boss about every little thing" failure; deciding irreversible things alone is the
opposite failure. Reversibility is what separates them.

The levels are an **explanatory overlay**, not new machinery: they map onto constructs that already
existed, and the operational markers are unchanged (L2 keeps `BLOCKED-ITEM:`, L3 keeps
`HUMAN-NEEDED:`). The **in-dubio-pro-autonomy** bias — L1 when ambiguous — is safe precisely because
the Decisions Ledger makes nothing self-decided hidden or unrecoverable, and because the ledger
never gates termination.

## Why `allowed-tools` includes unscoped Bash

Development execution requires arbitrary build/test/lint/git commands across unknown projects;
scoping would require per-project edits. Accepted deliberately. Narrow-surface skills use a scoped
form (`Bash(gh *)`) instead.

## Why the logs are the memory

The skill runs on the **host agent's native loop and context management** — it does not wrap itself
in an external reset loop. But native context can be compacted or summarized mid-run, so a cycle
must never depend on remembering earlier cycles from conversation alone. Reconstructing state from
on-disk artifacts makes the run survive compaction transparently. This is the minimal-intervention
stance: do not rebuild context machinery the harness already owns — just keep durable state complete
enough to survive it.
