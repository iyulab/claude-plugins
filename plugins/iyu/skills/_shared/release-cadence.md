# Release cadence — when publishing belongs in the order

**This file is the single definition** of how release work is *placed* relative to remaining work.
`handoff` (deriving next scope), `run-cycle` (STEP 5), and `ship` (its precondition check) all read
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
