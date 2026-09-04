# snitch-devready — orchestration recipes

The skill is a thin tool surface; YOU (the agent) drive the flow. Always:
1. Run `detect` and branch on `.mode`.
2. Gather context appropriately for the mode.
3. **Show every proposed artifact as a diff and get confirmation before writing.**
   Never silently overwrite an existing CLAUDE.md / settings / .mcp.json — merge.
4. Print only relevant follow-ups for the user's actual host. Audit-only requests stop
   before writes and do not require product interviews unrelated to the requested checks.

Every recipe below says "CLAUDE.md" for brevity; the actual target follows **SKILL.md's
context-file targeting** — `AGENTS.md` as canonical with per-tool pointers when the team
runs more than Claude Code. The content is the same markdown either way.

---

## Recipe A — brownfield (real code present)

The extract-inward methodology:
1. Codebase Q&A: explore languages, entry points, how to run/test/build.
2. Read git history for conventions (commit style, ownership).
3. Generate a SHORT CLAUDE.md from REALITY (no `INTENDED` tags) using the 6-criteria
   bar: commands, architecture, non-obvious patterns, conciseness, currency, actionability.
4. Detect the test runner → document it as the feedback loop. If UI, propose the
   screenshot MCP (`template mcp-screenshot`).
5. `perms <project_kind>` → propose merged `.claude/settings.local.json`.
6. Offer the slash commands (skip ones already present).
7. Run the **standards move** (Recipe E) — brownfield repos have real conventions and
   usually real gaps between what's defined and what's gated.
8. If a previous greenfield run left `<!-- INTENDED -->` tags, RECONCILE (Recipe D).

## Recipe B — greenfield (empty / near-empty)

Run *establish-forward* via the intent cascade:
1. **Read a spec if available.** Use `detect`'s `.spec_files`. If present, read them and
   draft the CLAUDE.md spec from them.
2. **Infer from any partial scaffolding.** Use `.stacks`, `.package_managers`,
   `.project_kind`, and read `package.json`/`Cargo.toml`/etc. to pre-fill stack + commands.
3. **Interview for the gaps only** (AskUserQuestion), e.g.:
   - What are you building? (one paragraph) — skip if a spec answered it.
   - Confirm/override stack + deploy target (pre-filled from inference).
   - Testing philosophy / how should Claude verify its work? (the feedback loop)
4. Write artifacts (config + spec ONLY — never product code):
   - CLAUDE.md from `template claude-md`, filled in, keeping `<!-- INTENDED -->` tags.
   - `.claude/commands/` from the four command templates.
   - `.claude/settings.local.json` from `perms <project_kind>`.
   - If `.ui == true`: `.mcp.json` from `template mcp-screenshot` (pick one server).
5. **Delegate the build.** Do NOT scaffold the app or write source. Tell the user Claude
   will build it next, guided by these artifacts, establishing the feedback loop from
   feature #1 (offer `/build-feature` as the entry point).
6. Print manual follow-ups (see below).

## Recipe C — thin-greenfield (scaffold present, no domain code)

Hybrid of A and B:
1. Infer stack from the existing scaffold (skip stack questions).
2. Interview for *domain* intent only (what is this going to be?).
3. Write the same artifacts as Recipe B, but commands/feedback-loop reflect the real
   scaffold's scripts (read `package.json` scripts, etc.).

## Recipe D — reconciliation (re-run after code exists)

When `detect` returns `brownfield` but CLAUDE.md still contains `<!-- INTENDED -->`:
1. For each INTENDED section, compare against actual code/commands.
2. Mark each: **realized** (drop the tag, keep), **diverged** (update to match reality,
   drop the tag), or **dropped** (remove the section).
3. Result: a normal brownfield CLAUDE.md with no INTENDED tags.

## Recipe E — the standards move (enforced vs advisory)

The premise: a coding standard that lives only in prose is advice, and advice drifts —
for a human team and doubly for an agent whose context resets every session. A rule holds
when a *gate* checks it. This recipe measures the gap between what the repo defines and
what it gates, closes it, and writes the standard in two tiers so the agent knows which
rules are hard.

Run standalone when asked ("set up coding standards", "make the agent follow our style"),
or as step 7 of Recipe A / the tail of Recipe C.

1. **Scan the enforcement surface:**
   ```bash
   ${CLAUDE_SKILL_DIR}/devready.sh standards
   ```
   Emits `.defined` (linters, formatters, typecheck, tests), `.gates` (commit hooks, CI
   files, Claude Code hooks), and `.gaps` (missing file signals, mechanically determined).
   This is presence-only evidence. Trace each actual command, scope, trigger, activation,
   and failure status before populating the table. A config, echo-only hook, or CI step with
   `continue-on-error` is not an enforced gate. Required merge checks need host evidence.
   Test new gates in an authorized safe context, including a known failing input and host
   event semantics, before calling them enforced; a template alone proves nothing.
2. **Present the coverage table** before proposing anything — defined vs gated per layer:

   | Layer | Defined | Gated at commit | Gated in CI | Gated in agent loop |
   |---|---|---|---|---|
   | Lint | eslint | ✗ | ✓ | ✗ |
   | Format | prettier | ✓ (lint-staged) | ✓ | ✗ |
   | Types | tsc | ✗ | ✓ | ✗ |
   | Tests | vitest | ✗ | ✓ | ✗ |

   The interesting rows are *defined but ungated* (the standard exists as advice) and
   *gated in CI only* (the agent finds out after pushing, not while working).
3. **Read the existing configs before proposing changes** — the repo's real rules, not the
   starter assumptions. If the team already argued a rule into `.eslintrc`, it's settled;
   never relax it (Hard rule: never weaken an existing gate).
4. **Propose the closes, smallest first, as diffs:**
   - **Commit gate** where none exists: lint-staged/husky (node), pre-commit (python), or
     the stack's equivalent — running the *already-defined* tools only. **This is the
     tool-agnostic gate**: it catches every agent and every human, whatever editor or CLI
     produced the commit. On a multi-tool team it is the close that matters most.
   - **Agent-loop gate** (`template settings-hooks` — Claude Code's hooks schema): a fast
     file-scoped check after each Edit/Write, the fuller verify on Stop. Highest-leverage
     for Claude Code users — the agent gets the violation while the file is still open,
     not in review. Other tools' loop-hook equivalents aren't bundled; for them the
     commit gate is the answer, and say so rather than improvising a config.
   - **Missing layer configs** only when `.gaps` names them AND the user wants them: a
     starter linter/formatter config matching the stack's dominant convention. Propose,
     don't push — a team that chose not to lint may have a reason; record their answer.
5. **Write the two-tier standards section** (`template standards-claude-md`) into
   CLAUDE.md: every *enforced* line names the gate command that checks it; *advisory*
   holds the conventions no tool checks (naming, error-handling shape, comment policy —
   extracted from the codebase in Recipe A, or from the interview in B/C). Keep the
   advisory list short: **when an advisory rule is worth arguing about twice, the fix is
   promotion into tooling, not more prose.**
6. **Adoption guidance for the user** (print, don't file): start with consensus rules that
   address real pain, expand incrementally; on a legacy codebase gate *changed files
   only* first (lint-staged / `--diff` modes) so the standard doesn't demand a big-bang
   cleanup; revisit the advisory tier when the team or product shifts.

Anti-patterns this recipe refuses:
- Writing a long aspirational style guide with no gates (that's the failure it exists to fix).
- Disabling or downgrading an existing rule to make the current codebase pass — the gate
  gates *new* work; use changed-files-only modes for legacy.
- Duplicating what the linter already enforces into CLAUDE.md prose — the enforced tier
  *names* the gates; it doesn't restate their rulebooks. Context is precious.

---

## Manual follow-ups (only for the applicable host; the skill cannot do these)

These are one-time, machine-level steps (Claude Code hosts):
- `/terminal-setup` (Shift+Enter for newlines)
- `/theme` (light/dark/colorblind)
- `/install-github-app` (@mention Claude on issues/PRs)
- Enable macOS Dictation to speak prompts (System Settings → Accessibility)
- Learn the keybindings: Shift+Tab (cycle permission modes), `!` (bash mode — run a
  shell command straight into the conversation), `@` (mention files), Esc (interrupt),
  Ctrl+O (verbose transcript), Ctrl+R (history search), `claude --resume` / `--continue`.
  Run `?` inside a session for the full, environment-specific list.

## Permissions map (reviewed operations only)

`perms <project_kind>` accepts the detected kind for compatibility but preapproves no
stack execution. It emits exact read-only git operations and illustrative ask/deny rules.
Inspect actual scripts before proposing exact build/test commands. Generic interpreters,
package managers, installation, git mutations, and publishing are not automatic allowances.
These rules are not a sandbox or a complete destructive-command detector. Review the host's
current permission semantics; preserve stricter existing settings. Personal settings stay local.
