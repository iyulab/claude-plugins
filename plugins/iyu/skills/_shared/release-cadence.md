# Release cadence — when publishing belongs in the order

**This file is the single definition** of how release work is *placed* relative to remaining work.
`handoff` (deriving next scope), `run-cycle` (STEP 5, and its run-end release review — §5), and
`ship` (its precondition check) all read
it. It answers one question: **is now the moment, or does this belong after the work that is left?**

It does **not** decide a project's release policy. That varies — some projects publish on every
change, some batch until a milestone, some ship rarely because every release costs consumers an
install. The policy belongs to the project; this file only keeps the *ordering* honest.

---

## 1. Three stages, three costs

Treating "release" as one action is what puts it in the wrong place. It is three, and they get
scheduled differently because they cost differently:

| Stage | Reaches | Cost of doing it too often | Cost of doing it too rarely |
|---|---|---|---|
| **bump + commit** | Local history | ~none | Work is unrecoverable, review units get huge |
| **push** | The remote, and **CI** | Burns CI minutes/storage on every run; noisy history | Work exists on one machine only; collaborators blocked |
| **publish / release** | **Consumers** | Consumers pay upgrade cost for a version superseded next week; version numbers inflate | Fixes sit finished but undelivered |

Two consequences that follow directly:

- **push is cheap-but-not-free.** Frequent pushing keeps the remote current, which matters. But
  every push that triggers a pipeline consumes a shared, finite budget, so pushing after *each*
  small edit is waste. Batch to a coherent unit of work.
- **publish is the expensive one, and it is irreversible.** A version, once out, cannot be
  un-released. This is why it sits at a phase boundary rather than mid-phase.

---

## 2. The placement test

Before scheduling a release — or before running one — ask, in order:

1. **What remains that would touch the same consumer-facing surface?**
   Read the remaining backlog. If unfinished items would change the same API, output, UI, or
   packaged artifact, publishing now buys a version that the next few items obsolete. **A release
   that will require a re-release shortly is close to no release at all.**
2. **Is what is already finished worth delivering on its own?**
   The mirror of (1). A finished fix that consumers are waiting on outranks a tidy phase boundary.
   Undelivered value is also a cost.
3. **Does the project declare a cadence?** See §3. Follow it.
4. **Where is the nearest phase boundary?** Place the release there — the point where a coherent
   chunk is done and the next chunk starts somewhere else.

**When (1) and (2) genuinely conflict, that is a human decision, not a self-decided one.**
Publishing is irreversible. Surface the trade-off — what is finished, what remains, what a
re-release would cost — and let the human choose.

### The gate is a frozen batch, not the live backlog

Question (1) read against the whole backlog has only two answers on a long project: "something
remains" (so nothing ever ships) or "something is finished" (so every unit of work ships). Neither
is a gate. So when (1) defers a release, **cut the gate**: name the remaining items that touch the
same surface *as they are known now* — that set is the batch, and the release goes out when the batch
closes.

- **The batch is frozen at the cut.** Work discovered afterwards goes to the next batch, even when it
  touches the same surface. The one exception is a regression the batch itself introduced — that is
  part of closing it.
- **A gate already written down is the one to judge against.** A later session or run that finds a
  release marker with its batch reads whether *that* batch is closed; it does not re-cut the gate from
  the current backlog, which would move the line every time something new is found.
- **Write the batch at the marker**, per §4: `📦 release — after {A, B, C}; same CLI output`.

---

## 3. Project cadence declaration

A project may state its own release rhythm. Look for it in `CLAUDE.md`, the continuity root's
`ROADMAP.md`/`HANDOFF.md`, or a release/contributing doc — free-form prose is fine:

```
Release cadence: publish on every merged phase; push freely.
Release cadence: batch until a milestone — consumers reinstall manually.
Release cadence: pre-1.0, release whenever something is worth using.
```

**If no declaration exists, infer and say so.** Signals: interval between existing tags, release
history in `CHANGELOG.md`, whether the package is consumed by other repos, whether upgrading costs
the consumer anything (a library bump vs. an installer). State the inference explicitly — "no
declared cadence; tags roughly monthly, inferring milestone batching" — so a human can correct it.
Never pick a rhythm silently.

Do not classify the project into fixed named tiers. Cadence is a property the project states or the
evidence suggests, not a category to sort it into.

---

## 4. Reordering is an edit, not an opinion

When this test says a release belongs later, **the fix is to change the order in the file** —
`ROADMAP.md`'s phase sequence, `HANDOFF.md`'s "Next". A paragraph explaining that the release should
come later is advice the next session skips; a reordered list is what it reads first.

So:

- Place a release marker **at the phase boundary it belongs to**, not in the middle of a phase, and
  not at the top merely because it was requested first.
- Leave **one line** saying why it sits there: `— after Phase 3; Phase 3 changes the same CLI output`.
  One line, at the marker. Not a section.
- If reordering moved anything, say what moved and why in the response — a silently reordered
  backlog looks like drift.
- Reordering is **within** what is already there. Adding, dropping, or rescoping items is separate
  work with its own rules; do not smuggle it in as a reorder.

---

## 5. A release grant inside a run

A grant passed to `/iyu:run-cycle` alongside its budget ("push+ship 승인", "배포 승인", "release if
needed") is **permission, not an instruction**: the run *may* release when the gate says so, and is
not obliged to release at all. Someone who wants a release to happen invokes `/iyu:ship` — that is
the explicit instruction, and it still runs its own §2 check.

Each cycle of a run is self-contained, so each cycle's end looks like a phase boundary (§2's
question 4). A grant read cycle by cycle therefore releases once per cycle — the most expensive
cadence there is, for consumers and for the people who operate the release. So the grant is read
**once per run, at its end**:

1. **Cycles do not release.** A cycle that finishes something worth delivering records it and moves
   on. Two exceptions only, and the cycle log names which one applied:
   - **a defect users are hitting now** — an outage, a security exposure, corrupted or wrong data in
     production — whose fix cannot wait for the run to end;
   - **an external window with a fixed time** (a maintenance slot, a consumer's scheduled cutover)
     that closes before the run will.
2. **In the budget's final cycle, prefer closing over opening.** When a grant is present and the
   batch is still open, the last cycle the budget allows picks scope that closes it over scope that
   starts a new surface. A run that ends early ends on an exhausted frontier, so this matters only
   for the budget-bounded end.
3. **At run end, one release review** over everything the run left undelivered: is the tree at a
   verified, committed state; and, by §2 with the frozen gate, is the batch closed? Closed → release
   once, under the grant, and report what went where. Not closed → do not release, and hand the gate
   over (4).
4. **Hand an open gate over as an order plus an act.** The gate is not a question for the owner —
   the run can see which batch it waits on, so it writes the release marker into `HANDOFF.md`'s
   `## Next` at the boundary it belongs to, with the batch (§4). What the owner holds is only the act:
   a one-line owner-gated entry in "Waiting on you" — blocker = the release gate · tried = the marker
   · unblocks = a grant on the next run, or `/iyu:ship`, once the batch closes. The next run reads
   that marker as the gate (§2) instead of cutting a new one.

The two mid-run exceptions are the only releases a run makes before its end. Any other release in a
cycle log is the cycle-by-cycle reading this section exists to prevent.
