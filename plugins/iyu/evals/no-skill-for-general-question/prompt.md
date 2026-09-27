---
description: A general programming question loads none of this plugin's skills — their descriptions must not over-trigger.
tags: [trigger]
max_turns: 4
timeout_seconds: 120
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "This is a trigger test. If one of your available skills fits this request, load it; as soon as it has loaded, stop and reply with only the skill's name. Do not carry out the task."
---

What's the practical difference between a Python list and a tuple, and when should I pick each?
