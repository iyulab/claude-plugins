# IYU Plugin

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.6.0-blue.svg)](./plugin.json)

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
| **Mindset** | Skill | Auto | Shared "Critical but Constructive" philosophy |
| **Issue & PR Triage** | Skill | Auto | Conversational triage advice with decision matrices |
| `/iyu:issue` | Command | Manual | Full issue triage report |
| `/iyu:pr` | Command | Manual | PR review with security focus |
| `/iyu:run` | Command | Manual | Plan-driven development execution |
| `/iyu:run-cycle` | Command | Manual | Iterative development cycles |
| **Issue Analyzer** | Agent | Auto | Autonomous issue analysis |
| **PR Reviewer** | Agent | Auto | Autonomous PR review |

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
| 🔴 Blocker | 🟠 Major | 🟡 Minor | 🟢 Nitpick | ✨ Praise |

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
├── commands/
│   ├── issue.md
│   ├── pr.md
│   ├── run.md
│   └── run-cycle.md
├── agents/
│   ├── issue-analyzer.md
│   └── pr-reviewer.md
├── skills/
│   ├── mindset/
│   │   └── SKILL.md
│   └── issue-triage/
│       ├── SKILL.md
│       ├── references/
│       └── examples/
└── README.md
```

## License

MIT
