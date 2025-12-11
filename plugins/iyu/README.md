# IYU Plugin

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](./plugin.json)

Iyulab's productivity toolkit for library maintainers and developers.

## Philosophy

**"Every issue is an opportunity"** - This plugin helps you move beyond simple accept/reject decisions to find the best path forward for your project.

## Installation

```bash
# Add the marketplace
/plugin marketplace add iyulab/plugins

# Install the plugin
/plugin install iyu@iyulab-plugins
```

## Features

This plugin provides three ways to help with issue triage:

| Component | Type | Activation | Use Case |
|-----------|------|------------|----------|
| **Issue Triage** | Skill | Automatic | Conversational issue analysis and advice |
| `/iyu:issue` | Command | Manual | Full formatted triage report |
| **Issue Analyzer** | Agent | Automatic | Autonomous issue analysis |

## Skills (Auto-Activated)

### Issue Triage

The plugin automatically activates when you discuss issue evaluation. Just ask naturally:

- "Should I accept this feature request?"
- "How should I respond to this issue?"
- "Is this in scope for my project?"
- "Evaluate this GitHub issue for me"
- "Help me triage this pull request"
- "Decline this request appropriately"

Claude will automatically apply the triage framework:
1. Understand the request (surface vs. underlying need)
2. Assess philosophy alignment (1-5 scoring across 4 dimensions)
3. Evaluate feasibility (complexity, breaking changes, maintenance)
4. Apply decision matrix
5. Suggest response approach

## Agents

### Issue Analyzer

An autonomous agent that provides structured triage analysis for GitHub/GitLab issues.

**Triggers automatically when:**
- Analyzing a GitHub/GitLab issue URL
- Evaluating feature requests against project scope
- Assessing contribution alignment with project philosophy

**Example:**
```
"Analyze this issue: https://github.com/user/repo/issues/123"
```

## Commands

### /iyu:issue

**Systematic issue evaluation with full formatted report**

Use this command when you need a complete, structured triage report.

```bash
# Triage a GitHub/GitLab issue
/iyu:issue https://github.com/user/repo/issues/123

# Quick decision only (skip execution phases)
/iyu:issue https://github.com/user/repo/issues/123 --quick

# Triage and save report to file
/iyu:issue ./docs/feature-request.md --save

# Triage from pasted text
/iyu:issue "User requests adding feature X..."
```

**Workflow**:

```
INTAKE -> PHILOSOPHY -> FEASIBILITY -> DECISION -> EXECUTION -> KNOWLEDGE -> RESPONSE
```

**Decision Matrix**:

| | Philosophy Aligned | Philosophy Misaligned |
|---|---|---|
| **High Feasibility** | ACCEPT | REDIRECT |
| **Medium Feasibility** | ADAPT | DEFER / REDIRECT |
| **Low Feasibility** | DEFER | DECLINE |

**Decision Types**:
- **ACCEPT**: Fully aligned, implement as requested
- **ADAPT**: Good idea, implement differently
- **DEFER**: Valuable but not now, add to roadmap
- **REDIRECT**: Out of scope, provide alternatives
- **DECLINE**: Fundamentally misaligned, explain why

**Output**:
1. **Triage Report**: Complete analysis with scores and reasoning
2. **Knowledge Updates**: Project documentation updates
3. **Response Draft**: Professional reply ready to post

## Best Practices

1. **Document your project philosophy**: Ensure CLAUDE.md describes your project's core principles
2. **Be honest**: The plugin encourages transparent reasoning
3. **Stay constructive**: Even declined requests get alternative suggestions
4. **Capture learning**: Each issue improves project documentation

## Troubleshooting

### Skill not activating

If the skill doesn't activate on your queries:
- Try using explicit trigger phrases like "triage this issue" or "should I accept"
- Ensure the plugin is properly installed with `/plugin list`

### Issue URL fetch fails

If WebFetch can't retrieve issue content:
- Verify the URL is publicly accessible
- For private repos, paste the issue content directly
- Use the file path option with a local copy

### Missing project context

If you see "No CLAUDE.md found" warning:
- Create a CLAUDE.md in your project root with your project's philosophy
- Or use README.md as a fallback (less accurate evaluation)

### Report not saving

If `--save` flag doesn't work:
- Ensure you have write permissions to the project directory
- The `claudedocs/` directory will be created automatically

## Plugin Structure

```
iyu/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── issue.md
├── agents/
│   └── issue-analyzer.md
├── skills/
│   └── issue-triage/
│       ├── SKILL.md
│       ├── references/
│       │   ├── decision-examples.md
│       │   ├── response-templates.md
│       │   └── philosophy-alignment-guide.md
│       └── examples/
│           ├── sample-triage-accept.md
│           ├── sample-triage-adapt.md
│           ├── sample-triage-defer.md
│           ├── sample-triage-redirect.md
│           └── sample-triage-decline.md
└── README.md
```

## License

MIT
