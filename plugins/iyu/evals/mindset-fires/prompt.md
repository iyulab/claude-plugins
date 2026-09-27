---
description: The mindset skill is chosen for a request phrased the way a user would type it, without naming the skill.
tags: [trigger]
max_turns: 6
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "This is a trigger test. If one of your available skills fits this request, load it; as soon as it has loaded, stop and reply with only the skill's name. Do not carry out the task."
---

We maintain a lightweight CLI argument-parsing library. A user in the issue tracker wants us to add a full plugin system with dynamic loading. Let's talk through whether that belongs in the library.
