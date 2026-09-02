---
description: Summarize what I shipped recently from git history
argument-hint: "[since, e.g. '1 week ago']"
---

# What did I ship

Summarize my recent work for a standup/update.

1. Determine my git identity (`git config user.name` / `user.email`).
2. Read the log since **$ARGUMENTS** for my commits (`git log --author=<me> --since=...`).
   If `$ARGUMENTS` is empty, default the `--since` value to `1 week ago`.
3. Group by theme and produce a tight, copy-pasteable bullet summary of shipped work.

(Inert until the repo has commits — greenfield projects will report "no history yet".)
