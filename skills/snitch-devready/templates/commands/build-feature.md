---
description: Build a feature test-first / check-first, then iterate until it passes
argument-hint: "<feature description>"
---

# Build a feature (feedback-loop first)

Feature: **$ARGUMENTS**

Establish the check BEFORE the implementation — this is how Claude verifies its
own work (see the Feedback loop section in CLAUDE.md):

1. Define the success check first:
   - Logic/back-end → write a **failing test**.
   - UI → state the visual/behavioral expectation (and screenshot the current state
     via the configured MCP).
2. Implement the smallest change to satisfy it.
3. Run the check (tests or screenshot-compare). If it fails, iterate — repeat 2–3
   times rather than guessing.
4. Only consider it done when the check passes. Then `/commit-push-pr`.
