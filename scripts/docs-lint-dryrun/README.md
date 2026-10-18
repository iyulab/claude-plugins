# docs-lint-dryrun

Regression check for the continuity-doc lint,
[`plugins/iyu/skills/_shared/scripts/docs-lint.sh`](../../plugins/iyu/skills/_shared/scripts/docs-lint.sh),
which runs the structural checks of
[`continuity-docs.md` §7](../../plugins/iyu/skills/_shared/continuity-docs.md) by code. Run it after
any change to the script or to the §7 rules it implements.

```powershell
pwsh scripts/docs-lint-dryrun/Invoke-DocsLintDryRun.ps1
pwsh scripts/docs-lint-dryrun/Invoke-DocsLintDryRun.ps1 -Fixture l10-*
```

Requires PowerShell 7 and, on Windows, Git for Windows — the script runs under the Git Bash that
Claude Code uses (`CLAUDE_CODE_GIT_BASH_PATH`, else the one beside `git`), never the WSL `bash` that
is often first on `PATH`.

## How it works

For each fixture the script copies `fixtures/<name>/tree` to a temp directory, runs the lint on it
with `DOCS_LINT_TODAY` fixed (default `2026-10-18`), and checks the exit code, **every code's verdict**
(so a fixture about one code is also clean on the other six), substrings the report must and must
not contain, and that **no file in the tree changed** — the lint only reads.

A failing run keeps its temp tree and prints the report and where the tree is.

## Fixtures

`pass-clean` is a tidy root; every other fixture is that tree with one change, so each one isolates
a single sub-check. Removing a check from the script fails the fixture named for it.

| Fixture | Expected | What it pins down |
|---|---|---|
| `pass-clean` | all PASS | Fenced `[x]`, URLs, anchors and code spans are not items or links to check; `L06` is always `UNCHECKED` |
| `crlf-bom-pass` | all PASS | CRLF line ends and a UTF-8 BOM (the harness rewrites the tree) change nothing |
| `missing-root-unchecked` | all UNCHECKED, exit 0 | No root, no verdict — never a failure |
| `l04-roadmap-checkbox-fail` | L04 FAIL | A checked box in `ROADMAP.md` |
| `l04-roadmap-leading-mark-fail` | L04 FAIL | An item whose text opens with a done mark |
| `l04-roadmap-table-cell-fail` | L04 FAIL | A table row with a done-only status cell |
| `l04-handoff-next-fail` | L04 FAIL | A checked item under `HANDOFF.md` `## Next` |
| `l04-midline-mark-pass` | PASS | A mark mid-line is a sub-piece, left to the pass |
| `l04-prose-roadmap-unchecked` | PASS, ROADMAP unchecked | A roadmap that marks nothing is not guessed at |
| `l05-missing-registered-fail` | L05 FAIL | A decision-class entry without `Registered` |
| `l05-resource-missing-tried-fail` | L05 FAIL | An entry with a `Blocker` also needs `Tried` and `Unblocks` |
| `l05-narrative-handoff-unchecked` | L05, L08 UNCHECKED | A `HANDOFF.md` outside the handoff format |
| `l07-broken-link-fail` | L07 FAIL | A relative link whose target is gone (anchor stripped) |
| `l10-history-over-cap-fail` | L10 FAIL | 31 live `HISTORY.md` entries |
| `l10-history-unrecognized-unchecked` | PASS, HISTORY unchecked | A table-form `HISTORY.md` is not counted |
| `l10-graduated-over-cap-fail` | L10 FAIL | 11 entries under `## 완료·졸업` |
| `l10-duplicate-heading-fail` | L10 FAIL | A duplicated `STRANDS.md` heading — reported, never repaired |
| `l10-lines-beneath-fail` | L10 FAIL | A line under a strand entry |
| `l01-long-item-warn` | L01 WARN, exit 0 | An item over 1,200 characters |
| `l01-korean-under-budget-pass` | PASS | Budgets count characters, not bytes |
| `l01-updated-line-warn` | L01 WARN | An `Updated` line over 300 characters |
| `l01-file-size-warn` | L01 WARN | `STRANDS.md` over 12,000 characters |
| `l08-stale-gate-warn` | L08 WARN | A gate registered more than 14 days before `today` |

Add a fixture as a new directory with a `tree/` and an `expect.json`:

```json
{
  "why": "one line, printed with the result",
  "exit": 1,
  "verdicts": { "L04": "FAIL" },
  "contains": ["ROADMAP.md:7  completed item: - [x] ..."],
  "notContains": ["..."],
  "today": "2026-11-01",
  "root": "nope",
  "crlf": true
}
```

- `verdicts` lists the codes that are not `PASS`; every other code must be `PASS`, except `L06`,
  which defaults to `UNCHECKED`.
- `root` lints a path relative to the copied tree instead of the tree itself.
- `crlf` rewrites every Markdown file with CRLF line ends and a UTF-8 BOM before the run.

Git Bash's `awk` already drops the CR before a line end, so on Windows `crlf-bom-pass` cannot tell
whether the script strips it itself; on Linux and macOS it can.
