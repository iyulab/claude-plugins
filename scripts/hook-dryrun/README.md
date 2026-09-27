# hook-dryrun

Regression check for the `run-cycle` Stop hook. The hook is `type: agent` — a model reading a prompt —
so it has no unit tests, and a one-sentence prompt edit can change what it blocks. Run this before
releasing any change to the hook prompt in `plugins/iyu/skills/run-cycle/SKILL.md`.

```powershell
pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1                 # every fixture, 3 runs each
pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1 -Fixture d-* -Repeat 5
```

Requires the `claude` CLI on `PATH`, signed in. Each run costs one short model session. Runs execute
concurrently (`-ThrottleLimit`, default 6 — the full suite takes about two minutes instead of about
twenty-five run one at a time); `-ThrottleLimit 1` runs them sequentially.

## How it works

For each fixture the script copies `fixtures/<name>/tree` to a temp directory, extracts the hook
prompt from the skill's frontmatter, substitutes `$ARGUMENTS` with a Stop hook input whose `cwd` is
that directory, and runs it with `claude -p`. It then checks the `ok` verdict, substrings of the
reason, and that **no file in the tree changed** — the hook is an auditor and must never write.

Write tools are deliberately available during the run: the agent hook's real tool set is documented
only as "tools like Read, Grep, and Glob", and a hook that writes must be observable here.

A failing run keeps its temp tree and writes the full stream-json transcript beside it
(`<tree>.trace.jsonl`) — the tool calls show *why* the hook decided what it did.

**A fixture passes only if every repeat passes.** A verdict that holds two runs in three is a prompt a
real run can still trip over.

## Fixtures

Fixture trees store log directories as `_cycle-logs_`; the script renames them to `cycle-logs` in
the temp copy. Stored under their real name, they would be picked up by this repository's own Stop
hook and by continuity-root resolution, both of which glob `**/cycle-logs/cycle-*.md`.

| Fixture | Expected | What it pins down |
|---|---|---|
| `a-umbrella-complete-allow` | ALLOW | Budget reached, report beside the logs in an umbrella layout |
| `b-report-missing-block` | BLOCK | Reason gives the report under the resolved absolute `…/cycle-logs` directory, never the parent directory |
| `c-legacy-report-allow` | ALLOW | A report written before the `Run:` header existed still satisfies the check |
| `d-same-day-second-block-allow` | ALLOW | The covering `Run:` line is the second block of a same-day report |
| `e-numeric-newest-with-stub-block` | BLOCK | Newest log chosen by filename number with an in-progress stub present, even when an older log has the latest mtime |
| `g-human-took-over-allow` | ALLOW | Work remains, but the human's latest message (from the transcript) is a new request — the run is paused, not driving |
| `h-run-still-driving-block` | BLOCK | The latest human message is the `/iyu:run-cycle` invocation; Stop-hook feedback in between is not human-authored |
| `f-stub-after-open-block` | BLOCK | Work remains, so the verdict is "keep working" — never a report demand, never the frontier-token shapes a stub has not written yet |

Add a fixture as a new directory with a `tree/` and an `expect.json`:

```json
{
  "ok": false,
  "why": "one line, printed with the result",
  "reasonContains": ["…"],
  "reasonNotContains": ["…"],
  "reasonContainsFixtureRoot": true,
  "touch": { "claudedocs/_cycle-logs_/cycle-111.md": 10 },
  "transcript": [ { "type": "user", "origin": { "kind": "human" }, "message": { "role": "user", "content": "…" } } ]
}
```

Fixtures `a` and `c` carry a report dated two weeks before the run. In real use the hook fires on
the day the report is written, so this is a stricter bar than normal operation — on purpose: it
checks that no date is ever the test.

`transcript` (a list of JSON objects) is written as the session transcript beside the tree, and its
directory is granted with `--add-dir`: a real transcript also lives outside the project.

`touch` sets a file's modification time to *now + N minutes* after copying, to test that the hook
does not rank logs by mtime.
