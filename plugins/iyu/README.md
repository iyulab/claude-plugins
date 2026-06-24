# IYU Plugin

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.14.0-blue.svg)](./plugin.json)

Productivity toolkit for open-source library maintainers and developers.

## Philosophy

**"Every issue is an opportunity"** - Move beyond accept/reject to find the best path forward.

**"Every contribution is a gift"** - Mentor, don't gatekeep. Merge and improve when feasible.

## Installation

```bash
/plugin marketplace add iyulab/claude-plugins
/plugin install iyu@iyulab-plugins
```

## Components

| Component | Type | Activation | Description |
|-----------|------|------------|-------------|
| **Mindset** | Skill | Auto | Shared "Critical but Constructive" philosophy + reference materials |
| **Issue & PR Triage** | Skill | Auto | Conversational triage advice with decision matrices |
| `/iyu:issue` | Skill | Manual | Full issue triage report (isolated context) |
| `/iyu:pr` | Skill | Manual | PR review with security focus (isolated context) |
| `/iyu:run` | Skill | Manual | Plan-driven development execution |
| `/iyu:run-cycle` | Skill | Manual | Iterative development cycles with Stop hook |
| `/iyu:telemetry-az` | Skill | Manual | Azure App Insights telemetry triage, issue discovery + run-over-run user analytics |

## Commands

### /iyu:issue

Systematic issue evaluation against project philosophy.

```bash
/iyu:issue https://github.com/user/repo/issues/123
/iyu:issue https://github.com/user/repo/issues/123 --quick
/iyu:issue ./docs/feature-request.md --save
/iyu:issue "Add support for Redis caching" --no-research
```

### /iyu:pr

PR review with security awareness and community-nurturing feedback.

```bash
/iyu:pr https://github.com/user/repo/pull/123
/iyu:pr #42 --quick
/iyu:pr #42 --security-focus --save
```

### /iyu:run

Plan-driven or input-driven development execution.

```bash
/iyu:run                                    # Auto-discover from plans
/iyu:run "Implement caching layer for API"  # Input-driven
/iyu:run --dry-run                          # Plan only
```

### /iyu:run-cycle

Iterative development cycles with evaluation and continuity tracking.

```bash
/iyu:run-cycle 5      # 5 cycles
/iyu:run-cycle 3 2    # 3 cycles starting from cycle 2
/iyu:run-cycle --dry-run
```

Each cycle: Scope → Research → Implement → Test → Evaluate → Carry-Forward.

Cycles maintain continuity — unresolved issues and pending decisions automatically propagate through the cycle chain.

When primary work finishes early and cycles remain, run-cycle does not stop idle. It climbs a **Surplus-Cycle Value Ladder** — investing the remaining budget across the full software lifecycle: **① main loop → ② durable value** (research → refactoring → docs/assets) **→ ③ stability** (tests/monitoring → security/compliance → resilience) **→ ④ efficiency** (DevOps → DX). It acts only where the project shows a concrete signal; additive/low-risk work is done in-cycle, invasive/opinionated work is proposed for human decision. Doc-sync is the always-applicable floor of this ladder.

Before the single end-of-run commit, run-cycle runs a **lightweight release-readiness check** — version consistency across version-bearing files, CHANGELOG coverage, doc-sync, and an evidence block of the actual test/build/lint output. It verifies and packages only; tagging, publishing, and pushing stay with the human / CI. Skipped on `--no-commit` / `--dry-run`.

### /iyu:telemetry-az

Azure Application Insights telemetry triage. Analyzes telemetry **since the last run**,
classifies defects / performance regressions / feature-drop signals, runs issue-triage
"1 → 10" discovery aligned with the project philosophy, and files issues for
threshold-crossing findings.

It also produces a **run-over-run user-analytics report** (purpose 2): active-user
growth/decline, feature & page preference shifts, and engagement trends — compared against
prior runs via a bounded history (last 12 runs). Comparisons are **cadence-normalized**
(per-day rates), so deltas hold whether you run it daily or weekly. User analytics is
report-only insight; it files an issue only when a usability drop is itself a defect.

```bash
/iyu:telemetry-az                              # Resume from last watermark, triage, file issues
/iyu:telemetry-az --since 2026-05-01T00:00:00Z # Override window start
/iyu:telemetry-az --dry-run                    # Report to chat only, no files, watermark unchanged
/iyu:telemetry-az --no-issues                  # Write report but file no issues
```

Per-repo settings live in `claudedocs/telemetry/config.json` (App Insights app id + thresholds);
the watermark and reports live under `claudedocs/telemetry/`. Issues follow the standard
`claudedocs/issues/` format. Requires `az login`.

## Decision Matrices

**Issue Triage:**

| | Philosophy HIGH | Philosophy LOW |
|--|----------------|----------------|
| Feasibility HIGH | ACCEPT | REDIRECT |
| Feasibility MED | ADAPT | DEFER/REDIRECT |
| Feasibility LOW | DEFER | DECLINE |

**PR Review:**

| | Quality HIGH | Quality LOW |
|--|-------------|-------------|
| Philosophy HIGH | APPROVE | MERGE_WITH_FIXES |
| Philosophy MED | APPROVE_WITH_NOTES | REQUEST_CHANGES |
| Philosophy LOW | REDIRECT | DECLINE |

**Severity Levels:**
| 🔴 Blocker | 🟠 Major | 🟡 Minor | ✨ Praise |

## Skills (Auto-Activated)

The plugin activates automatically when discussing issue evaluation or PR review:

- "Should I accept this feature request?"
- "Is this in scope for my project?"
- "Help me triage this pull request"
- "Review this PR for me"

## Plugin Structure

```
iyu/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── mindset/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── issue-triage/
│   │   └── SKILL.md
│   ├── issue/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── pr/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── run/
│   │   └── SKILL.md
│   ├── run-cycle/
│   │   └── SKILL.md
│   └── telemetry-az/
│       ├── SKILL.md
│       └── references/
└── README.md
```

## License

MIT
