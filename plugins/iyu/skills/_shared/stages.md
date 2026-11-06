# Stage contract — the shared definition

**Contents** — 1. What a stage is · 2. Where it lives · 3. The contract file · 4. Who may write what · 5. Passing a stage · 6. The claims ledger · 7. The seam · 8. Parking · 9. Budget defaults

**This file is the single definition** of the stage contract. `charter` writes it, `drive` works against
it, `accept` evaluates it, and `resume` / `handoff` / `backlog-discover` read it. Copies drift; link here.

Terms used the same way everywhere: **stage** (one step of the product, usable on its own), **ladder**
(the ordered list of stages), **scenario** (a script an observer follows), **bar** (the rubric and its
thresholds), **evaluator** (the separate subagent that judges), **owner** (the person who signs the
contract).

---

## 1. What a stage is

A **stage** is a product that **works on its own**: a skateboard, then a bicycle, then a motorcycle —
never a half-built car. The test for a stage is whether someone could use it for its purpose today and
see that it works with their own eyes. The ladder carries **order only**: no dates, durations or cycle
numbers, because those turn a ladder into a schedule that the next session re-plans.

`run-cycle` asks "what does the latest output imply next?" and may end when nothing is left. `drive`
asks "is the open stage done yet?" and ends only when it is, or when it needs something only the owner
can supply. Keep them in separate runs.

## 2. Where it lives

Under the continuity root (`continuity-docs.md` §1):

| Artifact | Path | Written by |
|---|---|---|
| Stage contract + status | `<root>/stages/stages.json` | `charter` (contract), the evaluator (status fields) |
| Interview record | `<root>/stages/charter-notes.md` | `charter` |
| Round plans and evaluation evidence | `<root>/stages/evidence/<stage-id>-<NN>[-plan].md` | `drive` (plans), the evaluator (evidence) |
| Parking lot | `<root>/stages/parking.md` | `drive`, any |

**The contract is a contract artifact, not a continuity doc.** It keeps passed scenarios on purpose —
they are what "done" is made of — so the "completed work lives in `HISTORY.md`" rule and the `L04`
check do not apply to it. `docs-lint` reads only `ROADMAP.md`, `HANDOFF.md`, `STRANDS.md` and
`HISTORY.md`.

## 3. The contract file

JSON, because a model edits structured data less casually than prose. Only the **open stage is
detailed**; later stages are a name and one line until the boundary before them re-opens the interview.

```json
{
  "goal": "Small teams keep shared meeting notes that stay findable.",
  "run": "./scripts/dev.sh",
  "bar": {
    "rubric": [
      {"id": "R1", "criterion": "A first-time user completes S1-1 without help", "threshold": "yes"},
      {"id": "R2", "criterion": "Visual polish against the calibration samples, 1-5", "threshold": ">= 4"}
    ],
    "calibration": [{"sample": "stages/evidence/calibration-1.png", "owner_scores": {"R2": "3"}}]
  },
  "stages": [
    {
      "id": "S1", "name": "Write and find a note", "status": "open",
      "user_can": ["create a note", "edit it", "find it again by a word in it"],
      "surface": "web",
      "scenarios": [
        {"id": "S1-1",
         "script": "Open the app. Click 'New note', type 'Q3 budget review', save. Reload the page. Type 'budget' in search. Expected: the note appears as the first result.",
         "passes": false}
      ],
      "claims": [{"id": "C1", "text": "Find any note by a word in it", "state": "goal"}],
      "non_goals": ["sharing", "mobile layout"],
      "owner_decisions": [{"id": "D1", "question": "Store notes locally or on a server?", "opens": "S1", "state": "open"}],
      "seam": {"contracts": ["api/notes.schema.json"], "invariants": ["the UI reads notes only through the notes API"]},
      "budget": {"max_rounds": 12, "stall_rounds": 3},
      "owner_accepted": false
    },
    {"id": "S2", "name": "Share a notebook", "status": "upcoming", "sketch": "invite a teammate to read and edit"}
  ]
}
```

`"calibration": "pending"` (in place of the list) means the owner has not scored any output yet.

`status` moves `upcoming` → `open` → `passed`. Exactly one stage is `open`. `run` is the one command
that builds and starts the product; the evaluator and every new session start from it.

## 4. Who may write what

| Field | Writer |
|---|---|
| `scenarios[].passes`, `claims[].state`, `status` → `passed` | **the evaluator only** — the agent that judges is not the agent that built |
| `owner_decisions[].state`, `bar.calibration` (replacing `pending`) | whoever records the owner's answer or scores, quoting them in `charter-notes.md` |
| `owner_accepted` | set after the owner says so in the conversation, with the quote recorded |
| everything else (goal, run, bar, scenario text, non-goals, seam, budget, ladder) | **the owner**, through `charter` |

An implementer who finds the contract wrong raises it with the owner, with the evidence; the contract
changes through `charter`. Scenarios, thresholds and non-goals stay as signed while a stage is being
built, because loosening them to make a stage pass is the failure this contract exists to prevent.

## 5. Passing a stage

A stage is `passed` when **all** hold, as of the latest evaluation:

1. every scenario has `passes: true`;
2. every rubric threshold is met;
3. every claim of the stage is `works`;
4. `owner_accepted` is true — the owner has seen the demo.

(1)–(3) are the evaluator's verdict from a **running build**, never from fixtures, mocks or the
implementer's account. (4) is the owner's eyes on the demo: one look, "pass" or "adjust".

## 6. The claims ledger

A claim is something the product's mock, landing page or pitch **promises**. Its state is the honest
distance between the promise and the build:

- `goal` — promised, not built · `first` — a first version runs · `works` — verified on a running
  build by the evaluator.

A stage's claims are the promises that stage must keep. Output that states a claim as fact uses only
`works` claims; the rest is phrased as design intent. A mock element that needs a capability the build
lacks is classed once, in the interview: **build it**, **assemble it from existing parts**, or **fold
it** (drop the promise for this stage).

## 7. The seam

Where a mock or UI meets the core, the boundary is a **contract** (schema, API, event shape) that the
mock's fixtures and the real implementation both satisfy. Swapping mock for real is then a change
behind the contract, and UI work cannot leak into the core. The owner reviews the seam — contracts,
invariants, the few decisions — at stage start, one or two pages. Conformance afterwards is checked by
running the contract's tests and dependency-direction checks.

## 8. Parking

Anything discovered outside the open stage — an idea, a later stage's need, a tangent — is appended to
`parking.md` with one line of why, and left there. At the stage boundary the owner, through `charter`,
decides what joins the next stage.

## 9. Budget defaults

Used when the contract leaves `budget` out; the owner can set other values in `charter`.

- `stall_rounds: 3` — one round without progress can be noise, two can be one approach tried twice;
  three in a row means the builder has run out of approaches it can see, which is when a question to
  the owner is cheaper than another round.
- `max_rounds: 12` — a ceiling on unattended cost for one stage. A stage that needs more than about a
  dozen scenario-sized rounds is usually two stages; the escalation says so.

Progress, for the stall rule, is *scenarios passing + rubric items at threshold* on the latest
evaluation.
