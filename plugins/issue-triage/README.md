# Issue Triage Plugin

A Claude Code plugin for library maintainers to systematically evaluate external issues against project philosophy and scope.

## Philosophy

**"Every issue is an opportunity"** - This plugin helps you move beyond simple accept/reject decisions to find the best path forward for your project.

## Installation

```bash
# Add the plugin marketplace (if not already added)
/plugin marketplace add [your-marketplace]

# Install the plugin
/plugin install issue-triage@[marketplace-name]
```

## Usage

```bash
# Triage a GitHub/GitLab issue
/issue https://github.com/user/project/issues/123

# Triage a local issue document
/issue ./docs/feature-request.md

# Triage from pasted text
/issue "User requests adding feature X..."
```

## Workflow

The plugin executes a 7-phase workflow:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   INTAKE    │ → │  PHILOSOPHY │ → │ FEASIBILITY │ → │  DECISION   │
│             │    │  ALIGNMENT  │    │   REVIEW    │    │   MATRIX    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                               │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  RESPONSE   │ ← │  KNOWLEDGE  │ ← │    TASK     │ ←────────┘
│    DRAFT    │    │   CAPTURE   │    │  EXECUTION  │
└─────────────┘    └─────────────┘    └─────────────┘
```

## Decision Matrix

| | Philosophy Aligned | Philosophy Misaligned |
|---|---|---|
| **High Feasibility** | ✅ ACCEPT | 🔀 REDIRECT |
| **Medium Feasibility** | 🔄 ADAPT | 📚 DEFER / 🔀 REDIRECT |
| **Low Feasibility** | 📚 DEFER | ❌ DECLINE |

### Decision Types

- **✅ ACCEPT**: Fully aligned, implement as requested
- **🔄 ADAPT**: Good idea, implement differently
- **📚 DEFER**: Valuable but not now, add to roadmap
- **🔀 REDIRECT**: Out of scope, provide alternatives
- **❌ DECLINE**: Fundamentally misaligned, explain why

## Output

The plugin generates:

1. **Triage Report**: Complete analysis with scores and reasoning
2. **Knowledge Updates**: Project documentation and memory updates
3. **Response Draft**: Professional reply ready to post

## Best Practices

1. **Read CLAUDE.md first**: Ensure your project philosophy is documented
2. **Be honest**: The plugin encourages transparent reasoning
3. **Stay constructive**: Even declined requests get alternative suggestions
4. **Capture learning**: Each issue improves project documentation

## License

MIT
