# Iyulab Claude Code Plugins

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub](https://img.shields.io/badge/GitHub-iyulab%2Fplugins-blue?logo=github)](https://github.com/iyulab/plugins)

A collection of Claude Code plugins for library maintainers and developers.

## Quick Start

```bash
# Add the marketplace
/plugin marketplace add iyulab/plugins

# Install the iyu plugin
/plugin install iyu@iyulab-plugins
```

## Available Plugins

### iyu

**Iyulab's productivity toolkit for library maintainers and developers**

| Component | Type | Activation |
|-----------|------|------------|
| Issue Triage | Skill | Auto (conversational) |
| Issue Analyzer | Agent | Auto (URL analysis) |
| `/iyu:issue` | Command | Manual (explicit call) |

#### Installation

```bash
/plugin install iyu@iyulab-plugins
```

#### Skills (Auto-Activated)

The plugin automatically activates when you discuss issue evaluation. Just ask naturally:

- "Should I accept this feature request?"
- "How should I respond to this issue?"
- "Is this in scope for my project?"
- "Help me triage this pull request"

#### Commands

| Command | Description |
|---------|-------------|
| `/iyu:issue` | Systematic issue evaluation with 7-phase workflow |

##### /iyu:issue Usage

```bash
# Triage a GitHub issue
/iyu:issue https://github.com/user/repo/issues/123

# Quick decision only (skip execution phases)
/iyu:issue https://github.com/user/repo/issues/123 --quick

# Triage and save report
/iyu:issue ./docs/feature-request.md --save

# Triage from text
/iyu:issue "User requests adding feature X..."
```

#### Decision Matrix

| | Philosophy Aligned | Philosophy Misaligned |
|---|---|---|
| **High Feasibility** | ✅ ACCEPT | ↗️ REDIRECT |
| **Medium Feasibility** | 🔄 ADAPT | ⏳ DEFER / ↗️ REDIRECT |
| **Low Feasibility** | ⏳ DEFER | ❌ DECLINE |

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
