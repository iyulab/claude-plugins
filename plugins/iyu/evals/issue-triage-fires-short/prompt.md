---
description: The issue-triage skill is still chosen for a short "triage this issue" request now that its description no longer lists trigger phrases.
tags: [trigger]
max_turns: 6
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "This is a trigger test. If one of your available skills fits this request, load it; as soon as it has loaded, stop and reply with only the skill's name. Do not carry out the task."
---

Can you triage this issue for me? A user wants our small Rust crate to ship prebuilt Windows ARM64 binaries.
