---
name: snitch-devready
description: "Bootstrap a repository for effective AI-assisted development. Auto-detects whether the repo is greenfield (no code yet), thin-greenfield (scaffold only), or brownfield (real code), then leaves behind the checked-in artifacts that make an AI coding agent smarter for the whole team: a short CLAUDE.md, slash commands, a screenshot/test feedback loop, an .mcp.json, a permissions allowlist — and a two-tier coding standard (enforced vs advisory) wired to the repo's real gates (linters, hooks, CI) so the agent's code is machine-checked, not just advised. Use when asked to make this repo Claude-ready / dev-ready, onboard a codebase for Claude Code, set up Claude Code for a team/project, bootstrap a new project for AI development, set up coding standards for the agent, or wire lint/test enforcement for AI-written code."
license: MIT
compatibility: Standalone skill — the bundled shell tools need bash + jq; artifacts target Claude Code but the CLAUDE.md and standards artifacts serve any AI coding tool that reads repo context files.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/devready.sh:*), Bash(/Users/ianmuench/.claude/skills/snitch-devready/devready.sh:*)
metadata:
  author: Snitch
  version: 0.4.0
  homepage: https://snitchplugin.com
---

# Snitch: DevReady

Turn any repo into a first-class AI-development setup. The skill is a **thin tool
surface** — a `detect` classifier, a `standards` enforcement-surface scanner, and a few
generators. **You orchestrate.** The script never mutates the user's project; you propose
artifacts as diffs and write them with Write/Edit only after the user confirms.

The core insight: most value comes from *checked-in context* — configure once, share with
the team, get a network effect. Two wrinkles this skill handles:

- The extract-based methodology (codebase Q&A, git history, "what did I ship") assumes
  existing code. **Greenfield has nothing to extract**, so the skill inverts — it
  *establishes* context before code exists.
- A coding standard that lives only in prose is advice, and agents (like people) drift
  from advice. **A rule only holds when a gate checks it** — so the standards move splits
  every rule into *enforced* (a linter, hook, or CI step fails on violation) or *advisory*
  (style to match), and wires the gates so the enforced tier stays enforced.

## Prerequisites
Run `${CLAUDE_SKILL_DIR}/devready.sh doctor`. `jq` is required (`brew install jq`);
`git` is optional (used for commit-depth classification). `${CLAUDE_SKILL_DIR}` is set by
Claude Code to this skill's directory, so the script resolves from any working directory.

## Always start here
```bash
${CLAUDE_SKILL_DIR}/devready.sh detect
```
This emits JSON with `.mode` ∈ `greenfield | thin-greenfield | brownfield`, plus
`.stacks`, `.package_managers`, `.project_kind`, `.ui`, `.spec_files`, `.git`, and
`.existing_artifacts`. **Branch on `.mode`.** Then read
`references/30-recipes.md` for the full per-mode flow.

## Context-file targeting (tool-agnostic)

The context artifact is one document; **where it lands depends on which agent tools the
team uses**. `.existing_artifacts` reports what's already present (`claude_md`,
`agents_md`, `cursor_rules`, `copilot_instructions`, `gemini_md`, `windsurf_rules`);
confirm with the user when it's ambiguous.

- **Claude Code only** → `CLAUDE.md`, as the recipes describe.
- **Multiple tools, or non-Claude** → **`AGENTS.md` is the canonical file** (most agent
  CLIs and editors read it natively), and each tool that doesn't gets a thin pointer, not
  a copy: a `CLAUDE.md` containing `@AGENTS.md` (Claude Code follows imports), a
  `.github/copilot-instructions.md` that says "follow AGENTS.md", and so on. **One
  canonical document, N pointers — never N diverging copies.**
- **A repo that already has both** with different content is a finding, not a choice:
  show the diff, merge into the canonical one, demote the other to a pointer.

Everything this skill writes into the context file — the spec sections, the standards
section from Recipe E — is plain markdown with no tool-specific syntax, so it works
wherever it lands. The tool-specific artifacts (`.claude/commands/`, settings
permissions, the hooks template) are Claude Code's; equivalents for other tools exist but
aren't bundled — say so rather than improvising one, and note that the *commit gate and
CI gate from Recipe E are tool-agnostic by nature* and cover every agent the team runs.

## The modes (summary — details in references/30-recipes.md)

- **brownfield** → *extract-inward*: codebase Q&A + git history → a SHORT CLAUDE.md
  describing reality, document the test runner as the feedback loop, propose
  permissions/commands/MCP — and run the **standards move** (Recipe E) so the CLAUDE.md
  carries the enforced/advisory split. (Recipe A)
- **greenfield** → *establish-forward* via the **intent cascade**:
  1. read a spec if `.spec_files` is non-empty,
  2. infer stack/commands from any partial scaffolding,
  3. interview (AskUserQuestion) only for the gaps,
  then write a north-star CLAUDE.md (with `<!-- INTENDED -->` tags), commands, a
  feedback-loop MCP if `.ui`, and a stack-seeded permissions allowlist. **Delegate
  the actual app build to the agent** — never scaffold or write product code. (Recipe B)
- **thin-greenfield** → hybrid: infer stack from the scaffold, interview for *domain*
  intent only, then write the same artifacts. (Recipe C)
- **reconciliation** → if a repo is now `brownfield` but CLAUDE.md still has
  `<!-- INTENDED -->` tags, reconcile each section (realized / diverged / dropped).
  (Recipe D)
- **standards** → the enforcement move, runnable standalone ("set up coding standards")
  or as the last step of Recipe A/C: scan what the repo defines vs what it gates, close
  the gap, and write the two-tier standards section. (Recipe E)

## Plan before you write (show this first)

After `detect` and picking the recipe, present a **component plan** table and get a yes before
writing anything (pairs with the "never silently overwrite" rule). Fill the last column from the
`detect` output + mode, so the user sees exactly what will land and why:

| Artifact | What it gives the team | This repo? |
|---|---|---|
| `CLAUDE.md` / `AGENTS.md` (per context-file targeting above) | Shared, checked-in context — the network-effect win | yes — {mode} flavor |
| Coding-standards section + hooks | The agent's code is machine-checked, not advised (Recipe E) | brownfield/thin — from `standards` output |
| `.claude/commands/` | Repeatable slash-command workflows | yes / skip |
| Feedback loop (`.mcp.json` screenshot, or the test runner) | Lets the agent *see* its output and iterate | only if `.ui` / has tests |
| `.claude/settings.local.json` perms | Stops re-prompting on common commands | yes — {project_kind} |
| `SKILL.md` (via `template skill-md`) | A project-authored skill, if the repo warrants one | optional |

Mark each row keep / skip with a one-line reason, confirm, then write artifacts as diffs.

## Generators (read-only; you apply the output)
```bash
${CLAUDE_SKILL_DIR}/devready.sh standards                  # → enforcement surface: defined vs gated + gaps
${CLAUDE_SKILL_DIR}/devready.sh perms <project_kind>       # → {permissions:{allow,deny,ask}} for the stack
${CLAUDE_SKILL_DIR}/devready.sh template <name>            # → a bundled template on stdout
#   names: claude-md | standards-claude-md | settings | settings-hooks | mcp-screenshot |
#          cmd-plan-then-build | cmd-build-feature | cmd-commit-push-pr | cmd-what-did-i-ship |
#          skill-md   # starter SKILL.md for a project that wants to author its own skill
```

`skill-md` emits a starter Agent Skill (verb-first trigger description with a negative-scope
clause, a lean imperative body, progressive-disclosure `references/` note). Offer it when the
repo would benefit from its own checked-in skill — don't write one unprompted.

## Artifacts this skill produces (all checked in, shareable)
- **CLAUDE.md** — short; greenfield uses `template claude-md` with `INTENDED` tags,
  brownfield describes reality. Keep it tight (context bloat is the failure mode).
- **Coding-standards section** (`template standards-claude-md`) — the two-tier
  enforced/advisory split, filled from the `standards` scan so every "enforced" line
  names a gate that actually runs. Advisory rules that matter get promoted into tooling,
  not repeated louder.
- **Claude Code hooks** (`template settings-hooks`) — the gates wired into the agent's
  loop: a fast file-scoped check after each edit, the fuller verify on stop.
- **.claude/commands/** — `/plan-then-build`, `/build-feature` (feedback-loop-first),
  `/commit-push-pr`, `/what-did-i-ship`.
- **Feedback loop** — the highest-leverage artifact. Document the test runner; for UI
  projects propose a Playwright/Puppeteer `.mcp.json` so the agent can *see* its output
  and iterate. Establish it from feature #1.
- **.claude/settings.local.json** — a stack-appropriate `perms` allowlist + a conservative
  deny list, so common commands aren't re-prompted.

## Hard rules
- **Never write product code or scaffold the app** (no `npm create`, no source/tests) —
  that's delegated to the agent, guided by the artifacts. Tooling config proposed by
  Recipe E (a linter config, a hooks block) is artifact, not product code — but it follows
  the same diff-and-confirm rule as everything else.
- **Never silently overwrite** an existing CLAUDE.md / settings / .mcp.json — show a diff
  and merge.
- **Never weaken an existing gate.** If the repo already lints/tests stricter than the
  starter templates, the templates lose. Recipe E adds gates and promotes rules; it never
  relaxes, disables, or inline-suppresses an existing check.
- Keep CLAUDE.md short.
- Always print the **manual follow-ups** the skill can't do: `/terminal-setup`, `/theme`,
  `/install-github-app`, macOS Dictation, and the keybindings (see recipes).

## Reference
- `references/30-recipes.md` — per-mode playbooks, the standards move (Recipe E),
  reconciliation, permissions map, manual follow-ups.
