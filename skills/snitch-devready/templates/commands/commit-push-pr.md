---
description: Commit current changes, push to a branch, and open a PR
---

# Commit, push, PR

1. Review the working tree (`git status`, `git diff`).
2. Infer the repo's commit-message style from recent `git log` and match it.
3. Confirm the intended branch before committing. Create a task branch first when needed;
   do not switch across unrelated dirty work. Stage only the reviewed task changes, preserving
   unrelated staged/unstaged edits. Commit, then push only the intended branch.
4. Open a pull request with a concise summary of what changed and why.

If no git repository or remote exists, report that boundary and ask before initializing
or adding a remote. Never commit everything merely because this is the first commit.
