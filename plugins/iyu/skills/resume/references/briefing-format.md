# resume — the briefing card

What step 6 hands the owner. One fixed skeleton, so the owner finds the same thing in the same place
every session, and so one short reply can answer many rows at once.

**Contents** — 1. Why a card · 2. The skeleton · 3. Row shapes · 4. The reply grammar · 5. Guards · 6. Example

## 1. Why a card

Sessions that opened with this skill produced dozens of section layouts for the same content ("current
state / where things stand / session summary", "waiting on you / what a person must resolve / owner
items"). Owners then spent their first message asking for the same thing in their own words — *list the
decisions and approvals, give a recommendation for each* — and answered with the shortest phrase that
covered everything ("approve all", "adopt the recommendations"). Two costs followed:

- the owner had to ask for the part of the briefing they act on;
- a bare "approve all" was ambiguous — did it open a push, a release, a message to someone outside?

The card puts what needs the owner **first**, gives every row a code the owner can answer by, and states
for every row what a yes opens.

## 2. The skeleton

Always this order. A section with nothing in it is one line ("None"), never dropped, never padded.
Write the labels in the session's language
([continuity-docs.md §5](../../_shared/continuity-docs.md#5-output-language)); the letters stay.

| Block | Holds | Owner's part |
|---|---|---|
| **State** (≤ 5 lines) | where things stand now; every staleness flag; what changed since the last handoff; the open stage, if a stage contract exists; one `Watching N — next check <date>` line when the handoff has a `## Watching` section, plus only the entries whose state changed | read |
| **Q — to confirm** | criterion requests (an irreducible lens conflict, a defective criterion) and any decision the project's own policy reserves for the owner — step 4 resolves nothing else this way; every other decision is a `D` | confirm or change |
| **G — to approve** | acts only a human may open (push, publish, issue or PR registration, a major bump, anything leaving the organization, spend, a new dependency) whose *decision* is already settled | approve |
| **H — to provide** | what only the owner can supply: a credential, an account screen, a physical step, a fact — never an item that only waits on time or a third party and that the agent can check by command (that is a Watching entry; its count is on the State line) | provide |
| **D — decided by me** | provisional decisions made this session, reversible, each with its reverse action | correct only |
| **C — code work** / **N — non-code work** | the settled `## Next`, in order, split as step 3 splits it | none unless marked |
| **Reply** | the grammar of §4, with one example built from this card's own codes | — |

Needs-the-owner blocks (Q, G, H) come before the decided-by-me block (D) and the plan (C, N) because
that is the order of what a reader must act on. Inside Q, G and H, order by what the answer opens, most
first (the rule `HANDOFF.md`'s "Waiting on you" already follows).

## 3. Row shapes

Codes are numbered per briefing (`Q1`, `G2`, `C3`). When the item already has a durable id, show it in
parentheses (`HD-54`, `D-172`, an issue number) — the owner may answer by either, and the briefing may be
read again after the code list has scrolled away.

**Q** — one line of the question, then at most three more:

> `Q1 (D-31)` Does the crash-recovery log become part of the public contract? — **Recommend yes**: it
> already behaves as one, and a contract is what lets consumers rely on it; locks in the field names.
> Alternative **no** wins if no consumer reads it. Would flip it: whether any consumer parses the log.
> **No reply →** `Q1` stands as recommended and nothing ships on it.

**G** — the act, what it opens, what to check first:

> `G1 (HD-12)` Push 4 local commits to `main`. **Opens: the push only** — no release. Decision settled in
> `D-31`. Checked: suite and build green at `a1b2c3d`.

**H** — what, why only the owner, where it lives (never the value):

> `H1` Add the repo to the release app's installation (account screen). Blocks: central publishing for it.

**D** — the decision and how to reverse it:

> `D2` Hotfix lane stays exempt from the 7-day train. **To correct:** drop the exemption line in the cadence file.

**C / N** — the work, marked by who can start it:

> `C1 [auto]` Fix the double-rebuild race; done when the concurrent test passes.
> `N2 [after G1]` Announce the release to the consumers once `G1` is pushed.

`[auto]` means the skill's autonomy rules already allow it, with no answer. `[after Gn]` / `[after Hn]`
names the one row it waits on. Never an unnamed wait.

## 4. The reply grammar

State these lines in the card, adapted to the codes present:

- **"adopt all"** → every `Q` at its recommendation and every `D` stands. It opens **no `G` and no `H`**.
- **"approve G1 G3"** or **"approve all G"** → opens exactly the acts those rows name, nothing beyond.
- **"Q2 → alternative"** or **"revert D3"** → the override. Step 5 asks the one alignment question
  (which criterion weighed differently) and records the answer.
- **"…, start"** → the explicit instruction step 6 requires: begin the `[auto]` work in the listed order.
- **No reply** → `Q` and `D` stand, no `G` runs, no `H` is assumed done.

A reply may also use the durable ids (`HD-12 approve`). If a reply could be read two ways, ask once — do
not widen it.

## 5. Guards

- **No quota.** Nothing is promoted to Q or G to fill a block. A reversible choice that a recommendation
  settles is a `D`, never a `Q` — a polished escalation format must not make escalating easier
  ([decision-briefing.md §3](../../_shared/decision-briefing.md)).
- **A Q is not an "A or B?"** It carries the recommendation and what stands without an answer.
- **A yes opens one thing.** A `G` row names its act; an "adopt" never reaches it.
- **Keep it short.** Aim for what fits a phone screen: about 2,500 characters, rarely beyond 4,000. More
  `D` than five → list five and give the count with the `HANDOFF.md` pointer. Rows that need nothing from
  the owner belong in `HANDOFF.md`, not here.
- **Same facts, one place.** The card points at `HANDOFF.md` entries; it does not restate them.

## 6. Example

```
State — Clean tree, one local commit ahead of origin. Nothing contradicts the recorded Next.
  Since the last handoff: 2 new requests arrived, 1 consumer replied (see N2).

Q — to confirm
 Q1 (D-31) Make the recovery log part of the public contract? — Recommend yes (locks in the field names).
    Alternative no if no consumer parses it. No reply → stands as yes; nothing ships on it.

G — to approve
 G1 (HD-12) Push 1 local commit. Opens: the push only. Suite and build green at a1b2c3d.

H — to provide
 None.

D — decided by me
 D2 Hotfix lane stays exempt from the 7-day train. To correct: drop the exemption line.

C — code
 C1 [auto] Fix the double-rebuild race — done when the concurrent test passes.
 C2 [after G1] Tag and publish the patch.

N — non-code
 N1 [auto] Answer the 2 new requests (drafts ready).
 N2 [auto] Approve the consumer's reply (issue 41) after reading its comment tail.

Reply — "adopt all" confirms Q1 and D2 and opens nothing else · "approve G1" opens the push only ·
        "Q1 → no" / "revert D2" overrides · add ", start" to begin the [auto] rows in order.
```
