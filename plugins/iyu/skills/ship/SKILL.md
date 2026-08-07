---
name: ship
description: Takes finished work out — bumps the version, commits, pushes, and watches the CI run to completion, reporting what failed if it fails. Checks first whether now is the right moment — if remaining backlog work would touch the same consumer-facing surface, it says so and asks rather than publishing a version the next few items obsolete.
when_to_use: Use when a phase of work is finished and ready to leave the machine. Typical asks - "bump version, commit, push", "push, cicd tracking", "bump+ship", "릴리즈해줘", "배포하고 액션 결과 봐줘". Not for mid-phase checkpoints; those are ordinary commits.
argument-hint: "[major|minor|patch] [--commit-only] [--no-publish]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Edit, TodoWrite, Bash
---

# Ship

Get finished work to where it needs to be, and confirm it landed. The last part is the part people
skip: a push whose pipeline failed twenty minutes later is not a completed release.

## Staged, because the stages cost differently

`bump + commit` is local and cheap. `push` reaches the remote and **spends CI budget**. `publish`
reaches **consumers and cannot be undone**. Each stage is reachable without the next:

| Invocation | Runs |
|---|---|
| `/iyu:ship --commit-only` | version bump + changelog + commit |
| `/iyu:ship --no-publish` | …+ push + CI watch |
| `/iyu:ship` | …+ publish, **if the project publishes and the moment is right** |

`$0`, when given, forces the bump level (`major` \| `minor` \| `patch`). Otherwise infer it from the
changes. **Never bump MAJOR on your own** — that is a human decision, and if the changes appear to
warrant one, stop and say so.

## Step 0: Is now the moment?

**Before anything else**, apply the placement test in
**[release-cadence.md](${CLAUDE_SKILL_DIR}/../_shared/release-cadence.md) §2**: read the remaining
backlog, and check whether unfinished work would touch the same consumer-facing surface this release
would expose.

If the test clears, say nothing and proceed — there is no question to ask.

If it does not, **ask, and put the analysis in the question** per
**[decision-briefing.md](${CLAUDE_SKILL_DIR}/../_shared/decision-briefing.md) §2**. Here the
briefing is the question itself, not a document section: the options, what each costs, and which one
you would pick, so the answer needs a judgment rather than an investigation.

> **The decision** — publish 1.4.0 now, or after the 4 remaining Phase 3 items?
> **Options** — (A) publish now: the 3 merged fixes reach consumers today, and Phase 3 changes the
> same CLI output, so a re-release follows within the week. (B) push without publishing
> (`--no-publish`): consumers wait, nothing is locked in, CI still validates. (C) publish now and
> batch Phase 3 into 1.5.0: same as A but the re-release is planned rather than reactive.
> **Lens read** — A is 표준 for a project that publishes per merge, but poor 근본 fit here: the
> surface is mid-change. B keeps the version line honest at the cost of delivery.
> **Recommendation** — B. The fixes are not urgent and Phase 3 lands soon. **Locks in**: nothing;
> publishing later stays open. A would lock in a version number consumers install and a changelog
> entry superseded next week.

Then **wait**. Do not decide this alone and do not treat the recommendation as pre-approval:
publishing is irreversible, silence is not consent (§3), the project's rhythm is the project's to
set (release-cadence §3 — read the declaration, or infer it *and say you inferred it*), and a
release that will need a re-release next week is close to no release at all.

`--commit-only` and `--no-publish` skip this check for the stages they exclude: committing and
pushing are not what the test guards.

## Step 1: Readiness

Items the project does not have are N/A — skip them, do not invent them.

1. **Clean tree, right branch.** `git status`. Uncommitted unrelated work, or sitting on a
   protected branch when the project uses PRs, stops the run — report, do not "helpfully" branch.
2. **Verification is current.** Run the project's tests/build/lint now, unless this session already
   ran them after the last change. **Their actual output is the evidence** — never ship on a recalled
   pass. Failing: stop.
3. **Version consistency.** Every version-bearing file agrees after the bump (package manifest,
   plugin/marketplace manifests, README badges, `Directory.Build.props`, whatever the project has).
   A mismatch is a defect to fix before committing, not a note to leave behind.
4. **Changelog.** If the project keeps one, this release has an entry describing what changed. Add
   it if missing.

## Step 2: Bump and commit

Bump per `$0` or inferred level (MINOR = backward-compatible features, PATCH = fixes and docs;
MAJOR never automatically). One commit for the release unless the work genuinely splits.

Write the message in the project's own convention — read recent `git log` and match it. **Do not
prefix it with anything this skill invented**; a reader should not be able to tell a skill wrote it.
Public repositories: keep internal context out of the message — describe what changed and under what
conditions, not who hit it or where.

## Step 3: Push

`git push`. If the project uses PRs and this is not a direct-push branch, open the PR instead and
report its URL — do not force a direct push.

## Step 4: Watch CI

If the push triggers a pipeline, follow it to completion rather than assuming:

```bash
gh run list --limit 1 --json databaseId,workflowName,headSha --jq '.[0]'
gh run watch <run-id> --exit-status --compact
```

The run may take a moment to register after the push; if the list is empty or shows an older SHA,
wait briefly and re-check once before concluding no pipeline exists.

- **Green** → report the workflow name and duration.
- **Red** → fetch the failing step's log (`gh run view <run-id> --log-failed`), summarize the actual
  cause, and stop. **Do not push a speculative fix on top.** A failed pipeline is a finding to report,
  not a loop to iterate in — the human decides whether it is a code defect, a flaky run, or an
  infrastructure problem.
- **No pipeline** → say so plainly.

## Step 5: Publish

Only when the project actually publishes (registry package, GitHub Release, deployment) **and** Step
0 cleared. Follow whatever the project's release path is — a tag that triggers a workflow, a
`publish` script, a manual release step.

If publishing is automated by the CI that Step 4 just watched, **that is the publish** — say so and
stop, rather than triggering a second path.

## Rules

1. **Evidence, not assertion.** Every claim in the report carries its output — the test result, the
   run conclusion, the published version. "It should be fine" is not a report.
2. **Never bump MAJOR.** Human decision, always.
3. **Never fix-and-retry a red pipeline.** Report and stop.
4. **Do not reorder the backlog here.** If Step 0 finds the release is mispositioned, say so —
   moving it is `/iyu:handoff`'s job, and doing it mid-release conflates two changes.
5. **Ask before the irreversible stage, not after.** Steps 2–4 are recoverable; Step 5 is not.

## Report

```markdown
## Ship — {version}

**Moment**: {cleared — or the options raised, which one was recommended, and which one you chose}
**Verified**: {actual test/build/lint output}
**Commit**: {sha} {subject}
**Push**: {branch → remote, or PR URL}
**CI**: {workflow · conclusion · duration, or "no pipeline"}
**Published**: {where, or "not published — <reason>"}
```
