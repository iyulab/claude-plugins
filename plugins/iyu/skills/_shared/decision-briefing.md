# Decision briefing — how a decision goes up to the human

**This file is the single definition** of the shape a decision takes when it leaves the agent and
reaches the person who owns it. Three consumers read it:

| Consumer | Where the briefing lands |
|---|---|
| `resume` step 4 | the **"Waiting on you"** section of `HANDOFF.md`, briefed at the moment someone is about to act on it |
| `run-cycle` End-of-Run Report part 2 | the **deferred-decisions (L2)** section of `RUN-SUMMARY-{date}.md` |
| `ship` step 0 | the **question itself** — asked interactively, and the run waits for the answer |

`handoff` still *writes* the "Waiting on you" section, but only the entry shape (§1) — it names a
decision-class item in one line and stops there. The four-part briefing below is produced by `resume`,
not by `handoff`: flagging happens where the decision is discovered (session close), briefing happens
where it is about to be acted on (session open) — the same split `run-cycle` already draws between its
per-cycle `BLOCKED-ITEM:` ledger entry and its End-of-Run Report synthesis (§3).

A question hands the whole investigation back to the person with the *least* context on the work
that produced it. A briefing hands over the analysis and asks only for the judgment. That is the
difference this file exists to enforce.

---

## 1. Two entry shapes — do not force one on both

- **Resource-blocked** (a missing credential, an access grant, an unavailable dependency) →
  **blocker (what's missing, and why it stops the work) · what was already tried · what would
  unblock it (the concrete credential/grant/step to obtain it, not just its name).** No options, no
  recommendation: there is nothing to choose, only something to supply. An options table here is
  filler, and filler teaches the reader to skim the section.

  **"Concrete" means the step, never the secret.** Name what to obtain and where it lives — the
  environment variable, the config key, the grant to request, the machine-local doc that records the
  address. Never write the operational value itself: no host IPs or hostnames, connection strings,
  credentials, tokens, or API keys. This is not a public-repo rule that a private repo can relax —
  these entries are written into files that get committed, and a value is far harder to remove from
  history than to leave out in the first place. Nothing is lost by it: the diagnostic content is the
  *failure*, not the address. `production DB (<env: APP_DB_HOST>) unreachable — 1433 timeout, DNS
  resolves` carries every bit of the debugging value that the literal address would, and travels
  safely.
- **Decision-class** (irreversible, or genuinely the human's to make) → the four parts below.

---

## 2. The four parts of a decision-class briefing

1. **The decision, in one line** — what is actually being chosen, stated so it can be answered.
2. **Options — at least two, usually one of them "do nothing / defer"** — each with its concrete
   consequence. **Options must be observed, not invented**: feasibility, cost, and blast radius come
   from what was actually read — the files, the dependents, the tests, the remaining backlog. Three
   plausible-sounding options nobody checked are worse than two real ones. An unknown cost stays
   "unknown", named with the command that would settle it.
3. **The cross-lens read** — how the *leading* options differ across the five co-equal lenses in
   **[decision-lenses.md](./decision-lenses.md)** (근본/정석/표준/세련/철학). Only the lenses that
   actually separate the options; one that reads the same for all of them is noise. This is the
   multi-angle part: "elegant but breaks convention", "canonical but poor structural fit".
4. **The recommendation — one named option, its reason, and what it locks in.** One or two
   sentences. **What it locks in** is the part that is easy to omit and hardest to recover from: the
   migration, the published version, the API consumers will depend on. That irreversibility is what
   the human is actually being asked about. **This slot is filled in every briefing but one.** A
   recommendation that doesn't form on the first pass is a signal to go and get what's missing:
   [decision-lenses.md's "When a recommendation can't be formed"
   table](./decision-lenses.md#when-a-recommendation-cant-be-formed) says whether (b) external
   information or (c) an internal anchor is absent, and how to settle each — both bounded, both
   ending in a recommendation. The slot is left unfilled **only for (a), an irreducible value
   conflict**, and only once (b) and (c) are ruled out. Never manufacture a preference to fill it —
   and never report "cannot recommend" without saying what you did to try.

---

## 3. Guards

**Silence is not consent.** Never write "proceeding on the recommendation unless you object" for an
irreversible decision. The entry waits. (`ship` step 0 is the interactive case: ask, then wait — do
not treat a recommendation as pre-approval for the stage that cannot be undone.)

**A recommendation does not make an entry human-only** — *applies where the consumer has an autonomy
path* (`resume`, `run-cycle`). If you can recommend an option **and** the choice is reversible, that
is the signal to decide it and record it as a self-made reversible decision instead. A polished
escalation format is an incentive to escalate more; this guard is what keeps it from quietly
rewriting the autonomy contract. It does **not** apply to `ship` step 0, where the decision is
irreversible by definition and always the human's.

**An empty section is a valid outcome — often the best one.** If everything that remains can be
carried autonomously, the section is `None` and that is the report. A format with slots creates
pressure to fill them; manufacturing a decision to have something to brief is worse than a blank
section, because it trains the reader that this section wastes their time, and the entry that
genuinely needs them gets skimmed with the rest. Do not promote an L1 choice, a taste question, or a
"just so you know" into a decision to avoid an empty list. (`ship` step 0 is the same: the placement
test clearing means no question is asked at all.)

**Brief where decisions are reported, not where work is parked.** In `run-cycle`, the per-cycle
`BLOCKED-ITEM:` entry keeps its existing short form — those ledger entries govern termination, and
adding briefing work to the parking path slows the run. The briefing happens once, at the End-of-Run
Report, synthesizing ledgers that already exist. `handoff`/`resume` draw the identical split across two
skills instead of two steps: `handoff` only names a decision-class item (§1's short entry shape,
applied to a decision rather than a blocker); `resume` is where the full four-part briefing happens,
grounded fresh in whatever is true when someone is actually about to act on it.

**Write the briefing in the session's language**, per
**[continuity-docs.md §5](./continuity-docs.md#5-output-language)** — the four-part shape is the
contract, not the English wording of these examples. Decision IDs (`HD-01`) stay literal.
