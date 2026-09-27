---
description: The issue-triage skill is chosen for a request phrased the way a user would type it, without naming the skill.
tags: [trigger]
max_turns: 6
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "This is a trigger test. If one of your available skills fits this request, load it; as soon as it has loaded, stop and reply with only the skill's name. Do not carry out the task."
---

Someone opened a pull request on our small JSON-parsing library that adds a YAML config loader. It's well written and tested. Should we merge it, and how should I reply?
