# Iyulab Claude Code Plugins

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub](https://img.shields.io/badge/GitHub-iyulab%2Fclaude--plugins-blue?logo=github)](https://github.com/iyulab/claude-plugins)

A collection of Claude Code plugins for library maintainers and developers.

## Quick Start

```bash
# Add the marketplace
/plugin marketplace add iyulab/claude-plugins

# Install the iyu plugin
/plugin install iyu@iyulab-plugins
```

## Available Plugins

### iyu (v1.9.0)

**Productivity toolkit for open-source library maintainers — adaptive iterative development, issue triage, PR review**

| Component | Type | Activation | Description |
|-----------|------|------------|-------------|
| `mindset` | Skill | Auto (background) | Shared "Critical but Constructive" philosophy |
| `issue-pr-triage` | Skill | Auto (conversational) | Decision matrices and triage advice |
| `/iyu:issue` | Skill | Manual | Full issue triage report |
| `/iyu:pr` | Skill | Manual | PR review with security focus |
| `/iyu:run` | Skill | Manual | Plan-driven development execution |
| `/iyu:run-cycle` | Skill | Manual | Adaptive iterative cycles (re-plan → execute → verify → reflect) |

#### Installation

```bash
/plugin install iyu@iyulab-plugins
```

#### Skills (Auto-Activated)

The plugin automatically activates when you discuss issue evaluation or PR review. Just ask naturally:

- "Should I accept this feature request?"
- "How should I respond to this issue?"
- "Is this in scope for my project?"
- "Help me triage this pull request"
- "Review this PR for me"
- "Find similar bugs in the codebase"

#### Commands

| Command | Description |
|---------|-------------|
| `/iyu:issue` | Systematic issue evaluation with root cause analysis |
| `/iyu:pr` | Professional PR review with security awareness |
| `/iyu:run` | Plan-driven development execution |
| `/iyu:run-cycle` | Adaptive iterative development cycles |

##### /iyu:issue

```bash
# Triage a GitHub issue
/iyu:issue https://github.com/user/repo/issues/123

# Quick decision only
/iyu:issue https://github.com/user/repo/issues/123 --quick

# Triage and save report
/iyu:issue ./docs/feature-request.md --save
```

##### /iyu:pr

```bash
# Full PR review
/iyu:pr https://github.com/user/repo/pull/123

# Quick review (critical issues only)
/iyu:pr https://github.com/user/repo/pull/123 --quick

# Security-focused review
/iyu:pr https://github.com/user/repo/pull/123 --security-focus
```

##### /iyu:run

```bash
# Auto-detect next phase from roadmap
/iyu:run

# Input-driven task execution
/iyu:run "Implement caching layer for API"

# Plan only, no execution
/iyu:run --dry-run
```

##### /iyu:run-cycle

```bash
# 5 adaptive cycles (default)
/iyu:run-cycle

# 10 cycles with adaptive re-planning
/iyu:run-cycle 10

# Preparation + directional roadmap only
/iyu:run-cycle 5 --dry-run
```

Each cycle runs Re-plan → Design → Execute → Verify → Reflect → Derive-Next. The roadmap is directional — later cycles may reshape it based on what earlier cycles reveal.

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
| 🟢 Nitpick | Optional style preference |
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
3. Add plugin.json, commands/, skills/, or agents/ as needed
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

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Claude Code version with plugin support

## License

MIT - See [LICENSE](./LICENSE) for details.

## Links

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Plugin Development Guide](https://docs.anthropic.com/en/docs/claude-code/plugins)
- [Iyulab GitHub](https://github.com/iyulab)
