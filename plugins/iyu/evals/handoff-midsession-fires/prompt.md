---
description: The handoff skill is chosen for a mid-session checkpoint before clearing the context, not only at session end.
tags: [trigger]
max_turns: 6
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "This is a trigger test. If one of your available skills fits this request, load it; as soon as it has loaded, stop and reply with only the skill's name. Do not carry out the task."
---

We're halfway through this refactor and the conversation is getting long. Before I clear the context, save where we are and what's next so we can pick it straight back up.
