# IYU Plugin

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](./plugin.json)

Iyulab's productivity toolkit for library maintainers and developers.

## Philosophy

**"Every issue is an opportunity"** - Move beyond simple accept/reject decisions to find the best path forward for your project.

**"Every contribution is a gift"** - Honor the effort contributors invest. Mentor, don't gatekeep.

**"Accept and improve > Reject and explain"** - When feasible, merge and fix minor issues yourself. Lower contribution barriers.

**"Fix N, Prevent M"** - When resolving a bug (N), automatically detect and fix similar latent defects (M) across your codebase.

## Installation

```bash
# Add the marketplace
/plugin marketplace add iyulab/claude-plugins

# Install the plugin
/plugin install iyu@iyulab-plugins
```

## Features

This plugin provides comprehensive issue triage, PR review, and bug resolution:

| Component | Type | Activation | Use Case |
|-----------|------|------------|----------|
| **Issue & PR Triage** | Skill | Automatic | Conversational analysis and advice |
| `/iyu:issue` | Command | Manual | Full formatted issue triage report |
| `/iyu:pr` | Command | Manual | Professional PR review with security focus |
| **Issue Analyzer** | Agent | Automatic | Autonomous issue analysis |
| **PR Reviewer** | Agent | Automatic | Autonomous PR review |

### New in v1.3.0: Professional PR Review

When reviewing pull requests, the plugin provides:

1. **Security-Aware Review** - OWASP-informed vulnerability scanning
2. **Community-Nurturing Feedback** - Warm, constructive responses
3. **Flexible Decisions** - Beyond approve/reject: MERGE_WITH_FIXES lets you accept and improve
4. **Code Quality Assessment** - Severity-classified findings (🔴🟠🟡🟢✨)

| Decision | When to Use |
|----------|-------------|
| APPROVE | Ready to merge as-is |
| APPROVE_WITH_SUGGESTIONS | Approve with non-blocking ideas |
| MERGE_WITH_FIXES | Accept; maintainer fixes minor issues |
| REQUEST_CHANGES | Good direction, needs specific fixes |
| REDIRECT | Wrong approach; guide to better path |
| DECLINE | Fundamentally misaligned with project |

### New in v1.2.0: Deep Bug Resolution

When an issue is detected as a bug, the plugin automatically:

1. **Root Cause Analysis** - Goes beyond symptoms to find the true underlying cause
2. **Similar Pattern Detection** - Finds all similar code patterns that may have latent defects
3. **Solution Research** - Researches best practices and latest methods for complex bugs

| Feature | Trigger | Output |
|---------|---------|--------|
| Bug Detection | Auto (labels, keywords, patterns) | BUG / FEATURE_REQUEST / ENHANCEMENT |
| Root Cause Analysis | Bug detected | Hypothesis tree, cause chain |
| Pattern Detection | Bug detected | Risk-rated pattern list (Critical/High/Medium/Low) |
| Solution Research | Complex bug detected | Best practices with sources |

## Skills (Auto-Activated)

### Issue Triage

The plugin automatically activates when you discuss issue evaluation. Just ask naturally:

- "Should I accept this feature request?"
- "How should I respond to this issue?"
- "Is this in scope for my project?"
- "Evaluate this GitHub issue for me"
- "Help me triage this pull request"
- "Decline this request appropriately"
- "Find similar bugs in the codebase"
- "Do a root cause analysis on this bug"
- "Fix this bug comprehensively"

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

# Quick decision only (skip deep analysis phases)
/iyu:issue https://github.com/user/repo/issues/123 --quick

# Triage and save report to file
/iyu:issue ./docs/feature-request.md --save

# Skip web research even for complex bugs
/iyu:issue https://github.com/user/repo/issues/123 --no-research

# Triage from pasted text
/iyu:issue "User requests adding feature X..."
```

### /iyu:pr

**Professional PR review with security awareness and human-friendly feedback**

Use this command for thorough, community-nurturing PR reviews.

```bash
# Full PR review
/iyu:pr https://github.com/user/repo/pull/123

# Quick review - critical issues only
/iyu:pr https://github.com/user/repo/pull/123 --quick

# Security-focused review (detailed vulnerability scan)
/iyu:pr https://github.com/user/repo/pull/123 --security-focus

# Review and save report
/iyu:pr #42 --save
```

**PR Review Workflow**:
```
STATUS CHECK -> UNDERSTANDING -> CODE QUALITY -> SECURITY
-> PHILOSOPHY ALIGNMENT -> DECISION -> COMMUNITY ENGAGEMENT -> RESPONSE
```

**Code Review Severity Levels**:
| Level | Meaning |
|-------|---------|
| 🔴 Blocker | Must fix before merge |
| 🟠 Major | Should fix, or maintainer can fix post-merge |
| 🟡 Minor | Nice to have, non-blocking |
| 🟢 Nitpick | Optional style preference |
| ✨ Praise | Celebrate good work |

**Response Principles**:
- Lead with gratitude
- Celebrate what's good first
- Explain "why" for every criticism
- Offer to help ("I can fix this")
- End encouragingly

**Workflow**:

```
INTAKE -> [BUG DETECTION] -> [ROOT CAUSE] -> [PATTERN DETECTION] -> [RESEARCH]
       -> PHILOSOPHY -> FEASIBILITY -> DECISION -> EXECUTION -> KNOWLEDGE -> RESPONSE
```

Phases in brackets are conditionally executed:
- `BUG DETECTION`: Auto-classifies issue type
- `ROOT CAUSE`: Only for bugs (High/Medium confidence)
- `PATTERN DETECTION`: Only for bugs - finds similar code patterns
- `RESEARCH`: Only for complex bugs (5+ files, unfamiliar territory, etc.)

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
│   ├── issue.md                              # Issue triage command
│   └── pr.md                                 # PR review command (NEW in v1.3.0)
├── agents/
│   ├── issue-analyzer.md                     # Issue analysis agent
│   └── pr-reviewer.md                        # PR review agent (NEW in v1.3.0)
├── skills/
│   └── issue-triage/
│       ├── SKILL.md                          # Combined issue & PR triage skill
│       ├── references/
│       │   ├── decision-examples.md
│       │   ├── response-templates.md
│       │   ├── philosophy-alignment-guide.md
│       │   ├── pattern-detection-guide.md
│       │   └── research-methodology.md
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
