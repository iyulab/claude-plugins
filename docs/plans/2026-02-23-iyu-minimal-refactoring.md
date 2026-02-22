# iyu Plugin Minimal Refactoring Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor iyu plugin to remove Claude-native redundancies, extract shared philosophy, and strengthen cycle continuity.

**Architecture:** Extract duplicated mindset to auto-skill, slim down commands by removing what Claude already does, strengthen cycle log continuity pattern.

**Tech Stack:** Markdown prompt files, YAML frontmatter, Claude Code plugin system

---

### Task 1: Create mindset auto-skill

**Files:**
- Create: `plugins/iyu/skills/mindset/SKILL.md`

Extract shared "Critical but Constructive" philosophy from all 4 commands into one `user-invocable: false` skill.

### Task 2: Refactor run-cycle.md (546 → ~200 lines)

**Files:**
- Modify: `plugins/iyu/commands/run-cycle.md`

Remove: philosophy section, project context reading, test command tables, coding convention reminders, 6 of 8 ASCII templates.
Keep: 5-step cycle structure, philosophy alignment scoring, evaluation criteria, execution rules, early termination.
Strengthen: Cycle log with Continuity/Carry-Forward pattern.

### Task 3: Refactor run.md (386 → ~150 lines)

**Files:**
- Modify: `plugins/iyu/commands/run.md`

Remove: Phase 0 Command Validation, philosophy section, detailed execution/cleanup/review instructions.
Keep: Input modes, plan discovery, philosophy alignment matrix, integration table.

### Task 4: Trim issue.md and pr.md

**Files:**
- Modify: `plugins/iyu/commands/issue.md`
- Modify: `plugins/iyu/commands/pr.md`

Remove philosophy/mindset sections (now in mindset skill). Keep all domain-specific content.

### Task 5: Strengthen agents

**Files:**
- Modify: `plugins/iyu/agents/issue-analyzer.md`
- Modify: `plugins/iyu/agents/pr-reviewer.md`

Make self-contained with embedded core logic instead of "Follow /iyu:command" pattern.

### Task 6: Narrow skill triggers

**Files:**
- Modify: `plugins/iyu/skills/issue-triage/SKILL.md`

Reduce 22 trigger phrases to ~10 maintainer-specific ones.

### Task 7: Update versions and READMEs

**Files:**
- Modify: `plugins/iyu/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `plugins/iyu/README.md`
- Modify: `README.md`
