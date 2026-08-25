# Claude Code Plugins for Library Maintainers

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://code.claude.com/docs/en/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub](https://img.shields.io/badge/GitHub-iyulab%2Fclaude--plugins-blue?logo=github)](https://github.com/iyulab/claude-plugins)

A collection of Claude Code plugins for library maintainers and developers.

## Why these plugins — a thin governance layer, not a heavier harness

As mainstream harness / loop-engineering tooling grows heavier — an "OS wrapped around the model" — these plugins make the opposite bet: **stay thin and ride Claude Code's native loop, tools, and context management**, adding only the judgment a generic harness cannot supply. A custom layer is always slower to evolve than the harness beneath it, so the goal is to *fill gaps, never fence off* native features.

Three governing principles (the plugin's constitution):

- **Minimal Intervention** — hook around the native loop, never rewrite it. The thinner the layer, the longer it lives.
- **Critical but Constructive (Rule of Law)** — a maintainer, not a typist. Human instructions sit *below* the project's constitution (philosophy, architecture, design docs); a conflict triggers a documented amendment — revise the instruction, or amend the doc — never silent compliance and never unilateral override. Unobserved data stays "unknown" rather than guessed.
- **Adaptive Iteration** — don't stop at "it compiles". When primary work is done, surplus cycles climb a lifecycle ladder: durable value → stability → efficiency.

How that differs from the mainstream:

| | Mainstream harness / loop tooling | iyu |
|--|--|--|
| **Stance** | Wrap the model in an OS | Thin layer on Claude Code native |
| **Human instruction** | Ground truth to execute | Below the project constitution; corrected via amendment |
| **Termination** | Stops at delivery (compiles / marker hit) | Climbs the lifecycle ladder past delivery |
| **Feedback loop** | Ends at merge | Closed — production telemetry (App Insights) flows back to the backlog |

## Quick Start

```bash
# Add the marketplace
/plugin marketplace add iyulab/claude-plugins

# Install the iyu plugin
/plugin install iyu@iyulab-plugins
```

## Available Plugins

> **Versioning** — two independent version numbers exist by design: `marketplace.json → version` tracks the **marketplace registry** (structure of this catalog), while each plugin's `plugin.json → version` tracks that **plugin** itself. They advance separately. Per-plugin `keywords`, `homepage`, and `license` are sourced from `plugin.json` and mirrored into the marketplace entry — the marketplace's own `metadata` object only recognizes `pluginRoot`, so per-plugin fields belong on the entry, not there. See [CHANGELOG.md](./CHANGELOG.md) for the iyu plugin history.

### iyu (v1.36.0)

**Productivity toolkit for open-source library maintainers — adaptive iterative development, session continuity, issue triage, telemetry and backlog discovery**

#### How the skills fit together

They form one loop. Each hands its output to the next through **files in your repo**, not through
the conversation — so any of them can be picked up in a fresh session, after a compaction, or by
someone else.

```
   /iyu:backlog-discover ──proposes──▶  ROADMAP.md  ──▶ /iyu:resume ──▶ /iyu:run-cycle ──▶ /iyu:handoff ──▶ /iyu:ship
     what's worth doing?                what's left      open & decide    build & verify     close out &      take it out
             ▲                                                                                re-order          & watch CI
             │                                                                                                     │
             └────────────────── /iyu:telemetry-az ◀── what production says ◀──────────────────────────────────────┘
                                  defects → issues → back into the backlog
```

`/iyu:resume` also reads the `HANDOFF.md` the previous `/iyu:handoff` left, not just `ROADMAP.md` —
that is where the loop actually closes: `handoff` flags a decision at close, `resume` briefs and
settles it at the next open.

You do not need all of it. **Start with two:**

```bash
/iyu:run-cycle 10     # work through the backlog, verifying as it goes
/iyu:handoff          # when you stop — write down where things stand and what's next
```

That pair alone gives you the core benefit: work that resumes cleanly tomorrow. Add the others when
you feel the specific need.

| Reach for | What it does | When |
|---|---|---|
| `/iyu:run-cycle [N]` | Re-plan → execute → verify → reflect → derive next, N times | You have work to do. `N` is a ceiling, not a target — it stops early when the backlog is genuinely done |
| `/iyu:handoff` | Rewrites the continuity docs, derives next scope, re-orders what's left, **flags** pending decisions for `/iyu:resume` to brief | You're stopping, or the docs no longer match reality |
| `/iyu:resume` | Reads `HANDOFF.md`/`ROADMAP.md`, **briefs** the decisions handoff flagged with options + a recommendation, records the pick immediately | You're opening a session and a `HANDOFF.md` already exists |
| `/iyu:ship` | Bump → commit → push → watch CI to completion | A phase is finished and ready to leave the machine. Asks first whether now is the moment |
| `/iyu:backlog-discover` | Research playbook → diagnosis, ranking, staged proposal | The backlog is running dry, or `run-cycle` reported the frontier exhausted |
| `/iyu:telemetry-az` | Reads Azure App Insights, files issues for threshold-crossing findings | Periodically, to let production tell you what's actually broken |
| *(nothing — just talk)* | `mindset` and `issue-triage` supply triage matrices and maintenance judgment | They activate on their own, in conversation |

**Shared state lives in one directory**, resolved from your repo rather than hardcoded — an existing
`cycle-logs/` or `ROADMAP.md` anchors it, otherwise `claudedocs/` is created:

- `ROADMAP.md` — remaining work, phase-level. Never completed work, never cycle numbers
- `HANDOFF.md` — what's in flight and what's next
- `HISTORY.md` — an index of what's done, so the two above stay short enough to read in one pass

Every skill resolves that directory the same way, so they all land in the same place — including an
umbrella repo that keeps one set per submodule.

#### Installation

```bash
/plugin install iyu@iyulab-plugins
```

#### The two automatic skills

`mindset` and `issue-triage` need no invocation — they activate when the conversation calls for
them. Just ask naturally:

- "Should I accept this feature request?" · "Is this in scope for my project?"
- "How should I respond to this issue?" · "Review this PR for me"
- "Find similar bugs in the codebase"

#### Command reference

##### /iyu:run-cycle

```bash
# 10 adaptive cycles (default)
/iyu:run-cycle

# up to 20 cycles (N is a ceiling, not a target)
/iyu:run-cycle 20
```

Each cycle runs Re-plan → Design → Execute → Verify → Reflect → Derive-Next. **Just-in-time scoping**: only the current cycle is scoped concretely, and each cycle's outcome decides the next cycle's scope. The roadmap is a phase backlog — it never assigns scope to numbered cycles, so the run behaves like genuine multi-turn work rather than one upfront N-cycle plan.

##### /iyu:handoff

```bash
# Close out the session: continuity docs, next scope, pending decisions
/iyu:handoff
```

Rewrites `HANDOFF.md` to in-flight / next / waiting-on-you / decided / state-of-play, migrates
completed work into the `HISTORY.md` index, and derives the next scope. Reconstructs the session
from git and the continuity docs rather than from the conversation, so it still works after a
compaction. Does not commit and does not implement.

Decisions that are yours to make are **flagged, not briefed** — one line naming the choice, nothing
more. Briefing it (options, a cross-lens read, a recommendation) is `/iyu:resume`'s job, done fresh
right before someone is actually about to act on it rather than produced now and left to stale. When
nothing left needs you, the section simply says "None"; it never invents a decision to fill.

##### /iyu:resume

```bash
# Open the session: confirm state, brief and settle every flagged decision
/iyu:resume
```

Reads `HANDOFF.md`/`ROADMAP.md` as they stand — no git-log reconstruction, no hygiene pass, nothing
migrated to `HISTORY.md`; that stays entirely `/iyu:handoff`'s job. Presents in-flight/next for
confirmation, then **briefs** each decision handoff only flagged — options with their real
consequences, a cross-lens read (근본/정석/표준/세련/철학) of how the leading ones differ, and a
recommendation stating what it locks in — grounded in the repo as it stands right now. It is the one
skill here whose whole point is to pause and wait: the instant an answer lands, it is written into
`HANDOFF.md`'s "Decided this session" section immediately, so a session that ends before the next
`/iyu:handoff` doesn't lose it.

##### /iyu:ship

```bash
/iyu:ship --commit-only   # bump + changelog + commit
/iyu:ship --no-publish    # ...+ push + watch the CI run
/iyu:ship                 # ...+ publish, if the moment is right
```

Staged because the stages cost differently: commit is local, push spends CI budget, publish reaches
consumers irreversibly. Step 0 reads the remaining backlog first — if unfinished work would touch
the same consumer-facing surface, it lays out the options with a recommendation and waits, instead
of publishing a version the next few items obsolete; if nothing conflicts, it asks nothing. Watches
the pipeline to completion and, on failure, summarizes the failing step and stops rather than
pushing speculative fixes.

##### /iyu:telemetry-az

```bash
# Analyze Azure Application Insights since the last run, triage, and file issues
/iyu:telemetry-az

# Override the window start
/iyu:telemetry-az --since 2026-05-01T00:00:00Z

# Collect + triage + print report only (no files written, watermark not advanced)
/iyu:telemetry-az --dry-run

# Write the report but create no issue files
/iyu:telemetry-az --no-issues
```

Reads per-repo settings from `claudedocs/telemetry/config.json` (App Insights app id +
thresholds), resumes from a dedicated watermark file, classifies defects / performance
regressions / feature-drop signals, runs issue-triage "1 → 10" discovery aligned with the
project philosophy, and files issues only for threshold-crossing findings. Requires `az login`.

#### Decision Matrices

**Issue Triage:**

| | Philosophy Aligned | Philosophy Misaligned |
|---|---|---|
| **High Feasibility** | ✅ ACCEPT | ↗️ REDIRECT |
| **Medium Feasibility** | 🔄 ADAPT | ⏳ DEFER / ↗️ REDIRECT |
| **Low Feasibility** | ⏳ DEFER | ❌ DECLINE |

**PR Review:**

| Severity | Meaning |
|----------|---------|
| 🔴 Blocker | Must fix before merge |
| 🟠 Major | Should fix, or maintainer fixes post-merge |
| 🟡 Minor | Nice to have, non-blocking |
| ✨ Praise | Celebrate good work |

[Read more about iyu plugin](./plugins/iyu/README.md)

## Philosophy

**"Every issue is an opportunity"** - Our plugins help maintainers move beyond simple accept/reject decisions to find the best path forward for their projects.

## Marketplace Management

```bash
# List configured marketplaces
/plugin marketplace list

# Update marketplace metadata
/plugin marketplace update iyulab-plugins

# Remove marketplace
/plugin marketplace remove iyulab-plugins

# List installed plugins
/plugin list
```

## Contributing

1. Fork this repository
2. Create your plugin in `plugins/your-plugin-name/`
3. Add `.claude-plugin/plugin.json` and your `skills/` as needed
4. Update `.claude-plugin/marketplace.json`
5. Submit a PR

### Plugin Structure

```
plugins/
└── your-plugin/
    ├── .claude-plugin/
    │   └── plugin.json       # Plugin metadata (required)
    ├── commands/             # Slash commands
    │   └── command-name.md
    ├── skills/               # Auto-activating skills
    │   └── skill-name/
    │       └── SKILL.md
    ├── agents/               # Custom agents (optional)
    └── README.md             # Documentation
```

## Requirements

- [Claude Code CLI](https://code.claude.com/docs/en/overview) installed
- Claude Code version with plugin support

## License

MIT - See [LICENSE](./LICENSE) for details.

## Links

- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins)
- [Iyulab GitHub](https://github.com/iyulab)
