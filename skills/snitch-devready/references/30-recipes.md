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
8. Run the **extension-surface move** (Recipe F) — offer it; a brownfield repo has a real
   answer to "what does work here need", which is what that recipe judges against.
9. If a previous greenfield run left `<!-- INTENDED -->` tags, RECONCILE (Recipe D).

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
6. Offer the **extension-surface move** (Recipe F) — on greenfield the stack is a decision,
   not an observation, so judge fit against the stack the interview just settled and lean
   harder toward keep: this repo has no track record yet.
7. Print manual follow-ups (see below).

## Recipe C — thin-greenfield (scaffold present, no domain code)

Hybrid of A and B:
1. Infer stack from the existing scaffold (skip stack questions).
2. Interview for *domain* intent only (what is this going to be?).
3. Write the same artifacts as Recipe B, but commands/feedback-loop reflect the real
   scaffold's scripts (read `package.json` scripts, etc.).
4. Run the standards move (Recipe E) and offer the extension-surface move (Recipe F).

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

## Recipe F — the extension-surface move (what this repo loads)

The premise: every skill, plugin and MCP server a contributor has installed is loaded
against *every* repo they open, whether or not this repo has any use for it. The listing
that tells the agent which skills exist is resident in every turn and is budgeted at
roughly **1% of the context window** — past that, entries get truncated and skill routing
degrades. So the cost of an unscoped surface is not just tokens; it is the agent picking
the wrong tool, or not finding the right one.

Recipe E gates the code. This recipe scopes the *agent*. Both leave a checked-in artifact:
the repo records which extensions the work here needs, so a fresh clone, a new teammate and
a CI agent all get the same lean surface without each person tuning their own machine.

Run standalone when asked ("too many skills/MCPs", "cut the bloat", "which extensions does
this project need"), or as the tail of Recipe A / B / C.

**Not a duplicate of `/doctor`.** Claude Code's `/doctor` audits the *user's machine* from
*their usage history* — personal hygiene across every project. This recipe audits *this
repo* against *what the repo is* and writes the answer into the repo. When the user's real
problem is "my whole setup is bloated everywhere", point them at `/doctor` and stop; when
it is "this project doesn't need most of this", that is Recipe F. Say which one you are
doing.

1. **Inventory the surface:**
   ```bash
   ${CLAUDE_SKILL_DIR}/devready.sh extensions            # add --no-cli to skip the `claude` subprocess
   ```
   Emits `.skills` (each with scope, `user_invoked`, and an estimated listing cost),
   `.plugins` (effective on/off per plugin *and which settings source decided it*),
   `.mcp.servers` (by scope, with `disabled_for_project`), `.skill_overrides` already in
   effect, and `.totals`. Pass `--window` when the session window is not 200k.

   Check `.host` first. A null `project_key` means no entry for this path was found in
   `~/.claude.json`, so **every MCP server reads as enabled whether or not it is** — treat
   the disabled column as unknown and say so rather than proposing a disable that is
   already in place. `policy_settings` naming a file means managed settings are in play.

2. **Get the cost story right before you report anything.** The estimates are estimates and
   the surfaces do not cost alike:
   - **Skills are resident.** Their listing entries are in context every turn. This is the
     real lever, and `.totals.over_budget_by` is the number worth showing.
   - **MCP tool schemas are deferred** behind the ToolSearch tool by default: the tool
     *name* is resident, the schema is fetched on demand. **Never claim a token saving for
     disabling an MCP server.** The honest case for switching one off is decluttering —
     one less connection to start, authenticate and keep alive, and less for the agent to
     sift. Check your own context to confirm: deferred tools arrive as a names-only list,
     resident tools arrive with full schemas.
   - **Plugin numbers come from `claude plugin details`**, not from us. When
     `.totals.plugin_cost_complete` is false, `.totals.plugin_cost_unknown_for` names the
     plugins whose cost is unknown (`cost_source` `unavailable`, or `claude-cli-partial`
     when the output did not fully parse) — report the gap rather than filling it with a
     guess. Abbreviated figures are dropped on purpose: no number beats a wrong one.
   - `.totals` is a floor: it excludes CLAUDE.md, hook output and non-deferred MCP schemas.
     `/context` is the exact live measurement; recommend it and say yours is disk-based.

3. **Present the surface table** before proposing anything. Judge each row on **project
   fit** — what `detect` says this repo *is* (`.mode`, `.stacks`, `.project_kind`, `.ui`)
   — not on whether it has been used lately. Usage history is `/doctor`'s evidence, not
   this recipe's.

   | Extension | Kind | Est. always-on | Fits this repo? | Verdict |
   |---|---|---|---|---|
   | `higgsfield-generate` | skill (user) | ~268 tok | no — media generation, this is a Rust CLI | off |
   | `cloudflare@cloudflare` | plugin | ~1,769 tok | yes — deploys to Workers | keep |
   | `coplay-mcp` | MCP (user) | deferred, ~0 | no — Unity editor | declutter |

   **Take a position on every row.** A row you will not judge is a row you should not have
   listed. Two rows you never judge, and never propose disabling: **bundled/built-in**
   skills, and anything enabled by **managed policy** (`.host.policy_settings` names the
   file when one is present) — those are not the user's to switch off here.

4. **Keep is the default; the burden is on "off".** A skill that plausibly serves this repo
   stays, even if it is idle today. This move trims what is clearly foreign to the project,
   not everything the user cannot currently justify. When a skill is borderline, prefer
   `"name-only"` (still routable, cheap listing) or `"user-invocable-only"` (off the
   model's list, still typable as `/name`) over `"off"`.

5. **Propose the writes as diffs, into the file that makes them take effect.** The home is
   not a style choice — the settings cascade is user < project < local, and picking wrong
   means the setting is silently ignored:

   | Surface | Key | File |
   |---|---|---|
   | Skill (user-, project- or plugin-provided) | `skillOverrides: {"<name>": "off"}` | `.claude/settings.json` — **checked in, the team artifact** |
   | Plugin | `enabledPlugins: {"<plugin>@<marketplace>": false}` | `.claude/settings.local.json` — a `false` in project settings cannot override a user-settings `true` |
   | `.mcp.json` server | `disabledMcpjsonServers: ["<name>"]` | `.claude/settings.local.json` |
   | user/local-scope MCP server | `disabledMcpServers` in `~/.claude.json` | **the user runs `/mcp disable <name>`** — print it, never write that file |

   `template settings-extensions` emits the annotated fragment. Use `.plugins.effective`
   and `.skill_overrides` `source` fields to confirm which file has to change.

6. **Write the repo's reasoning down.** Add a short **Extensions** section to
   CLAUDE.md/AGENTS.md: what the repo keeps and why, what is off and why. Without it the
   next contributor re-enables things blind, and the next agent has no idea the list was
   deliberate. Keep it to a few lines — this is a decision record, not an inventory; the
   settings file is the inventory.

7. **Close with reversal, and with what did not change.** Every disable ships with its undo
   (`/mcp enable <name>`, `/plugin`, or deleting the `skillOverrides` line), and the
   `/mcp disable` toggle is **per-project even for a user-scope server** — say so, and tell
   the user to repeat it in other projects where the server should be off. Changes to
   settings files take effect in the next session, not this one.

Anti-patterns this recipe refuses:
- Claiming token savings for deferred MCP tools. The decluttering case is real; the token
  case is not, and inventing it teaches the user a false model of their own context.
- `claude mcp remove` as a way to "disable". It permanently deletes the server config, its
  env vars and headers, and wipes its stored OAuth tokens. Disabling is reversible; this is
  not. Never propose it for this purpose.
- Editing `~/.claude.json` directly. Claude Code owns that file and rewrites it; hand the
  user `/mcp disable` instead.
- Proposing disables for bundled skills or policy-managed extensions.
- A purge dressed as an audit. If the table's verdict column is almost all "off", the
  recipe was run as a cleanup crusade rather than a fit assessment — recheck against
  `detect` before showing it.

---

## Manual follow-ups (only for the applicable host; the skill cannot do these)

These are one-time, machine-level steps (Claude Code hosts):
- `/terminal-setup` (Shift+Enter for newlines)
- `/theme` (light/dark/colorblind)
- `/install-github-app` (@mention Claude on issues/PRs)
- `/mcp disable <server>` / `/mcp enable <server>` — the only way to scope a user- or
  local-scope MCP server to this project (Recipe F proposes these; the user runs them).
  Per-project even for a user-scope server, and it takes effect on the next launch.
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
