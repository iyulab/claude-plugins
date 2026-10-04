# hook-dryrun

Regression check for the `run-cycle` Stop hook,
[`plugins/iyu/skills/run-cycle/scripts/stop-gate.sh`](../../plugins/iyu/skills/run-cycle/scripts/stop-gate.sh).
Run it before releasing any change to the hook.

```powershell
pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1                        # every fixture, deterministic
pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1 -Fixture k-*
pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1 -LiveAudit -Repeat 3   # the real auditor model
```

Requires PowerShell 7 and, on Windows, Git for Windows — the script runs under the Git Bash that
Claude Code uses for hooks (`CLAUDE_CODE_GIT_BASH_PATH`, else the one beside `git`), never the WSL
`bash` that is often first on `PATH`.

## How it works

For each fixture the script copies `fixtures/<name>/tree` to a temp directory, writes the fixture's
`transcript` beside it, pipes a Stop hook input whose `cwd` is that directory into `stop-gate.sh`,
and checks the verdict, substrings of the reason or user message, whether the auditor was asked,
and that **no file in the tree changed** — the hook is an auditor and must never write.

The hook asks a model one thing: whether a `FRONTIER-EXHAUSTED:` claim with budget left holds up
against the roadmap and the ledgers. By default that auditor is a stub (`IYU_RUN_CYCLE_AUDITOR`)
returning the fixture's `auditor` verdict, so every run is deterministic, takes seconds, and one run
per fixture is enough. `-LiveAudit` runs the real auditor (`claude -p`, signed in) on the fixtures it
can reach, `-Repeat` times each; **a fixture passes only if every repeat passes** — a verdict that
holds two runs in three is one a real run can still trip over.

A failing run keeps its temp tree and prints where it is.

## Fixtures

Fixture trees store log directories as `_cycle-logs_`; the script renames them to `cycle-logs` in
the temp copy. Stored under their real name, they would be picked up by this repository's own Stop
hook and by continuity-root resolution, both of which look for `cycle-logs/cycle-*.md`.

| Fixture | Expected | What it pins down |
|---|---|---|
| `a-umbrella-complete-allow` | ALLOW | Budget reached, report beside the logs in an umbrella layout |
| `b-report-missing-block` | BLOCK | Reason gives the report under the resolved absolute `…/cycle-logs` directory, never the parent directory |
| `c-legacy-report-allow` | ALLOW | A report written before the `Run:` header existed still satisfies the check |
| `d-same-day-second-block-allow` | ALLOW | The covering `Run:` line is the second block of a same-day report |
| `e-numeric-newest-with-stub-block` | BLOCK | Newest log chosen by filename number with an in-progress stub present, even when an older log has the latest mtime |
| `f-stub-after-open-block` | BLOCK | Work remains, so the verdict is "keep working" — never a report demand, never the frontier-token shapes a stub has not written yet |
| `g-human-took-over-allow` | ALLOW | Work remains, but the human's latest message (from the transcript) is a new request — the run is paused, not driving |
| `h-run-still-driving-block` | BLOCK | The latest human message is the `/iyu:run-cycle` invocation; Stop-hook feedback in between is not human-authored |
| `i-exhausted-audit-pass-allow` | ALLOW | Early `FRONTIER-EXHAUSTED:` on the run's own last turn is audited, and passes against an empty roadmap |
| `j-exhausted-audit-fail-block` | BLOCK | The same claim fails against a roadmap with an unstarted, unparked phase; the reason names it |
| `k-ended-run-human-turn-allow` | ALLOW | a finished run (report covers its `Start:`), 190+ logs, header-less early logs with stale `FRONTIER-OPEN:`, and a later unrelated human request — no audit, no resumed work |
| `l-ended-run-no-transcript-allow` | ALLOW | The same tree with no readable transcript: the covering report alone shows the run is over |
| `m-own-final-turn-audit-unavailable-allow` | ALLOW | The auditor returns no verdict: the stop is allowed and the user is told the claim went unaudited |
| `n-headerless-newest-driving-block` | BLOCK | The run is driving but has not opened its stub; the reason gives the header to write |
| `o-headerless-newest-unknown-allow` | ALLOW | Nothing shows a run is driving and the newest log has no header: fail toward allowing |
| `p-first-cycle-in-progress-block` | BLOCK | This run's only log is its in-progress stub; the previous run's report covers a different `Start:` |
| `q-human-needed-report-block` | BLOCK | A run-fatal `HUMAN-NEEDED:` ends the run with budget left, but the report is missing |

Add a fixture as a new directory with a `tree/` and an `expect.json`:

```json
{
  "ok": false,
  "why": "one line, printed with the result",
  "reasonContains": ["…"],
  "reasonNotContains": ["…"],
  "reasonContainsFixtureRoot": true,
  "messageContains": ["…"],
  "auditor": "pass | fail: <reason> | none",
  "audited": false,
  "liveReasonContains": ["…"],
  "fill": { "dir": "claudedocs/_cycle-logs_", "from": 11, "to": 201 },
  "touch": { "claudedocs/_cycle-logs_/cycle-111.md": 10 },
  "transcript": [ { "type": "user", "origin": { "kind": "human" }, "message": { "role": "user", "content": "…" } } ]
}
```

- `auditor` is the stub's verdict (`none` prints no verdict). A fixture with `auditor` expects the
  auditor to be asked unless `audited` is `false`; a fixture without it expects it never to be.
- `liveReasonContains` replaces `reasonContains` under `-LiveAudit`, where the reason is the model's.
- `fill` generates complete logs from earlier runs, so a fixture can hold more logs than a
  file-listing tool returns.
- `touch` sets a file's modification time to *now + N minutes* after copying, to test that the hook
  does not rank logs by mtime.
- `transcript` (a list of JSON objects) is written as the session transcript beside the tree.

Fixtures `a` and `c` carry a report dated two weeks before the run. In real use the hook fires on
the day the report is written, so this is a stricter bar than normal operation — on purpose: it
checks that no date is ever the test.
