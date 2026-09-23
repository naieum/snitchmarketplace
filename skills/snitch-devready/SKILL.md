---
name: snitch-devready
description: "Bootstrap a repository for effective AI-assisted development. Auto-detects whether the repo is greenfield (no code yet), thin-greenfield (scaffold only), or brownfield (real code), then leaves behind the checked-in artifacts that make an AI coding agent smarter for the whole team: a short CLAUDE.md, slash commands, a screenshot/test feedback loop, an .mcp.json, a permissions allowlist, a two-tier coding standard (enforced vs advisory) wired to the repo's real gates (linters, hooks, CI) so the agent's code is machine-checked, not just advised — and a scoped extension surface, so the skills, plugins and MCP servers loaded against this repo are the ones work here actually needs. Use when asked to make this repo Claude-ready / dev-ready, onboard a codebase for Claude Code, set up Claude Code for a team/project, bootstrap a new project for AI development, set up coding standards for the agent, wire lint/test enforcement for AI-written code, or scope which skills / plugins / MCP servers this project loads and turn off the rest. Do NOT use for product or marketing decisions (use snitch-blueprint) or for writing the app itself."
license: MIT with Commons Clause
compatibility: Standalone skill — the bundled shell tools need bash + jq, and the `extensions` inventory reads plugin cost from the optional `claude` CLI when present; artifacts target Claude Code but the CLAUDE.md and standards artifacts serve any AI coding tool that reads repo context files.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/devready.sh:*)
metadata:
  author: Snitch
  version: 0.7.0
  homepage: https://snitchplugin.com
---

# Snitch: DevReady

Turn any repo into a first-class AI-development setup. The skill is a **thin tool
surface** — a `detect` classifier, a `standards` enforcement-surface scanner, an
`extensions` extension-surface inventory, and a few generators. **You orchestrate.** The script never mutates the user's project; you propose
artifacts as diffs and write them with Write/Edit only after the user confirms.

The core insight: most value comes from *checked-in context* — configure once, share with
the team, get a network effect. Three wrinkles this skill handles:

- The extract-based methodology (codebase Q&A, git history, "what did I ship") assumes
  existing code. **Greenfield has nothing to extract**, so the skill inverts — it
  *establishes* context before code exists.
- A coding standard that lives only in prose is advice, and agents (like people) drift
  from advice. **A rule only holds when a gate checks it** — so the standards move splits
  every rule into *enforced* (a linter, hook, or CI step fails on violation) or *advisory*
  (style to match), and wires the gates so the enforced tier stays enforced.
- Every skill, plugin and MCP server a contributor installed loads against *every* repo
  they open. The skill listing is resident in every turn and budgeted at roughly **1% of
  the context window**; past that it truncates and routing degrades. **A surface nobody
  scoped is a surface tuned for no project in particular** — so the extension-surface move
  scopes it to this repo and checks the answer in, where the team inherits it.

## Prerequisites
Run `${CLAUDE_SKILL_DIR}/devready.sh doctor`. `jq` is required (`brew install jq`);
`git` is optional (commit-depth classification) and the `claude` CLI is optional (plugin
cost figures for Recipe F — without it, plugin cost reads `unavailable`, never a guess). `${CLAUDE_SKILL_DIR}` is set by
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
- **A repo that already has both:** compare shared instructions for actual contradictions.
  An import plus tool-specific additions is valid, not drift. Preserve those additions and
  the team's existing canonical layout; propose merging only duplicated or conflicting rules.

Everything this skill writes into the context file — the spec sections, the standards
section from Recipe E — is plain markdown with no tool-specific syntax, so it works
wherever it lands. The tool-specific artifacts (`.claude/commands/`, settings
permissions, the hooks template) are Claude Code's; equivalents for other tools exist but
aren't bundled — say so rather than improvising one, and note that the *commit gate and
CI gate from Recipe E are tool-agnostic by nature* and cover every agent the team runs.

## The modes (branch here — full playbooks in references/30-recipes.md)

| `.mode` (or trigger) | Approach | Recipe |
|---|---|---|
| `brownfield` | extract-inward: codebase Q&A + git history | A |
| `greenfield` | establish-forward via the intent cascade (spec → scaffold → interview the gaps) | B |
| `thin-greenfield` | hybrid: infer stack, interview for domain intent only | C |
| brownfield repo, CLAUDE.md still has `<!-- INTENDED -->` tags | reconciliation | D |
| "set up coding standards" (standalone, or chained after A/C) | the standards move | E |
| "too many skills / MCPs", "cut the bloat", "what does this project need" (standalone, or chained after A/B/C) | the extension-surface move | F |

## Evidence and permission boundary

`standards` is a **presence-only inventory**, including its legacy `gates` and `gaps`
fields. Before calling a rule enforced, trace the real command, its selected files and
triggers, activation, and failure propagation. Check placeholder scripts, `continue-on-error`,
`|| true`, and skipped paths. CI execution is not proof of required merge checks; host
protection settings need separate evidence. Proposed or untested hooks remain unverified.
Do not run untrusted project scripts or install dependencies merely to classify the repo.

`extensions` is likewise **inventory and estimate only**. Its token figures are
approximations and a floor — they exclude CLAUDE.md, hook output and non-deferred MCP
schemas; `/context` is the exact live measurement, and say so when you report a number.
**MCP tool schemas are deferred behind ToolSearch by default**, so a server's tools cost a
name, not a schema: never claim a token saving for disabling one, and make the decluttering
case instead. Plugin costs come from `claude plugin details` — when it is unavailable, report
that, don't estimate around it. Never propose disabling a bundled skill or anything enabled by
managed policy.

Audit/proposal requests stop at evidence and diffs; they do not authorize artifact writes.
The generated permission starter grants no authority in the current session. Preserve existing
policy, and propose narrowly scoped commands only after inspecting what they execute.

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
| `.claude/settings.local.json` perms | Personal, reviewed preapprovals | optional — preserve policy; no stack executors by default |
| Extension surface (`skillOverrides` in `.claude/settings.json`) | The skills/plugins/MCP loaded here are the ones this repo needs (Recipe F) | from `extensions` output |
| Extensions section in CLAUDE.md / AGENTS.md | Records *why* the list is what it is, so nobody re-enables blind | pairs with the row above |
| `SKILL.md` (via `template skill-md`) | A project-authored skill, if the repo warrants one | optional |

Mark each row keep / skip with a one-line reason, confirm, then write artifacts as diffs.

## Generators (read-only; you apply the output)
```bash
${CLAUDE_SKILL_DIR}/devready.sh standards                  # → enforcement surface: defined vs gated + gaps
${CLAUDE_SKILL_DIR}/devready.sh extensions [--window N] [--no-cli]
#   → extension surface: skills + est. listing cost vs the ~1% budget, enabled plugins and
#     their cost, MCP servers by scope, and the overrides already in effect (with the
#     settings source that decided each one)
${CLAUDE_SKILL_DIR}/devready.sh perms <project_kind>       # → {permissions:{allow,deny,ask}} for the stack
${CLAUDE_SKILL_DIR}/devready.sh template <name>            # → a bundled template on stdout
#   names: claude-md | standards-claude-md | settings | settings-hooks | mcp-screenshot |
#          settings-extensions |
#          cmd-plan-then-build | cmd-build-feature | cmd-commit-push-pr | cmd-what-did-i-ship |
#          skill-md   # starter SKILL.md for a project that wants to author its own skill
```

`skill-md` emits a starter Agent Skill (verb-first trigger description with a negative-scope
clause, a lean imperative body, progressive-disclosure `references/` note). Offer it when the
repo would benefit from its own checked-in skill — don't write one unprompted.

## Artifacts this skill can produce (shared or personal as appropriate)
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
  projects propose a Playwright `.mcp.json` so the agent can *see* its output
  and iterate. Establish it from feature #1.
- **Extension surface** (`template settings-extensions`) — `skillOverrides` in the
  checked-in `.claude/settings.json` so the team inherits the scoped surface; plugin
  `false` flips and `disabledMcpjsonServers` in `.claude/settings.local.json`, because the
  user < project < local cascade would otherwise swallow them; user-scope MCP servers as
  printed `/mcp disable` lines the user runs. Plus a short **Extensions** section in the
  context file recording why — a decision record, not an inventory.
- **.claude/settings.local.json** — personal permissions, not a checked-in team artifact.
  `perms` starts with a few exact read-only git commands, with no stack executors preapproved.
  Add only reviewed operations the user wants to preapprove; never broaden an existing policy.

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
- **Never claim a token saving for disabling an MCP server.** Its tool schemas are
  deferred; the honest case is decluttering. Inventing the token case teaches the user a
  false model of their own context.
- **Never `claude mcp remove` to disable a server** — it permanently deletes the config, its
  env vars and headers, and wipes stored OAuth tokens. Disabling is reversible; that is not.
- **Never edit `~/.claude.json`.** Claude Code owns and rewrites it; print `/mcp disable
  <server>` for the user to run, and say it is per-project even for a user-scope server.
- **Never propose disabling a bundled skill or a policy-managed extension.** Keep is the
  default for everything else: the burden of proof is on "off", not on "keep".
- Keep CLAUDE.md short.
- Print only host-appropriate, relevant **manual follow-ups** the skill can't do: `/terminal-setup`, `/theme`,
  `/install-github-app`, macOS Dictation, and the keybindings (see recipes).

## Reference
- `references/30-recipes.md` — per-mode playbooks, the standards move (Recipe E), the
  extension-surface move (Recipe F), reconciliation, permissions map, manual follow-ups.
