# walk-setter-dryrun

Regression check for the blind mission setter,
[`plugins/iyu/skills/walk/scripts/set-missions.sh`](../../plugins/iyu/skills/walk/scripts/set-missions.sh)
([missions.md](../../plugins/iyu/skills/_shared/missions.md) §2). Run it after any change to the
script or to how it calls the model.

```powershell
pwsh scripts/walk-setter-dryrun/Invoke-WalkSetterDryRun.ps1            # deterministic, stubbed model
pwsh scripts/walk-setter-dryrun/Invoke-WalkSetterDryRun.ps1 -Live      # also the real call, 2 repeats
```

Requires PowerShell 7 and, on Windows, Git for Windows (the script runs under the Git Bash that
Claude Code uses).

## What it checks

The setter's value is that it cannot see the product, so most checks are about where it runs and
what reaches it.

- **Deterministic** (`IYU_WALK_SETTER` replaces the model with a stub): the stub ran outside the
  repository, in an empty directory that is gone afterwards; it received the brief and the purpose
  material; a fenced or prose-wrapped answer is reduced to the JSON object; no JSON, or a failing
  setter, exits `2`, writes nothing and says why on stderr; a usage error exits `64`.
- **`-Live`** (the real `claude -p` call, each repeat must pass): the caller stands in a project
  directory whose `CLAUDE.md` and `.claude/settings.json` carry canary strings, and passes the
  brief by a **relative** path. A probe brief asks the model to list its tools and every
  instruction in its context. Pass = no tools, and nothing matching the canaries, project
  instructions, memory, skills, plugins, MCP or hooks. The harness's own environment lines
  (working directory, date, model name) are expected and allowed.

Removing the `cd` into the empty directory, or `--setting-sources ''`, fails the isolation checks;
reading the brief after the `cd` fails `-Live` on the relative path.
