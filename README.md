# IYULab Claude Code Plugins

A collection of Claude Code plugins for library maintainers and developers.

## Installation

```bash
# Add the marketplace
/plugin marketplace add iyulab/plugins

# List available plugins
/plugin list

# Install a specific plugin
/plugin install issue-triage@iyulab-plugins
```

## Available Plugins

### issue-triage

**Systematic issue evaluation workflow for library maintainers**

Evaluate external issues against your project's philosophy and scope with a structured 7-phase workflow.

```bash
/plugin install issue-triage@iyulab-plugins

# Usage
/issue https://github.com/user/repo/issues/123
/issue ./docs/feature-request.md
```

**Features**:
- Philosophy alignment scoring (1-5)
- Feasibility assessment
- 5-tier decision matrix (Accept/Adapt/Defer/Redirect/Decline)
- Automatic knowledge capture
- Professional response draft generation

[Read more](./plugins/issue-triage/README.md)

## Philosophy

**"Every issue is an opportunity"** - Our plugins help maintainers move beyond simple accept/reject decisions to find the best path forward for their projects.

## Contributing

1. Fork this repository
2. Create your plugin in `plugins/your-plugin-name/`
3. Update `.claude-plugin/marketplace.json`
4. Submit a PR

## Plugin Structure

```
plugins/
└── your-plugin/
    ├── .claude-plugin/
    │   └── plugin.json       # Plugin metadata (required)
    ├── commands/             # Slash commands
    │   └── command-name.md
    ├── agents/               # Custom agents (optional)
    ├── skills/               # Agent skills (optional)
    └── README.md             # Documentation
```

## License

MIT - See [LICENSE](./LICENSE) for details.

## Links

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Plugin Development Guide](https://docs.anthropic.com/en/docs/claude-code/plugins)
- [IYULab GitHub](https://github.com/iyulab)
