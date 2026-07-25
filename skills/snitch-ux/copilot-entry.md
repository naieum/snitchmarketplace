# Snitch: UX — entry point for non-Claude tools

This skill bundle is portable. It works in Claude Code (native skill loading), Cursor, GitHub Copilot Chat, OpenAI Codex / ChatGPT with file access, Continue.dev, Cody, Amazon Q Developer — any AI coding tool that can read markdown files from disk and follow extended instructions.

The skill's brain is `SKILL.md`. Everything else is loaded on-demand by the agent following SKILL.md's directives: the reference library in `./references/` (14 files) holds the depth behind each cheat-sheet line.

## Universal bootstrap

If your tool needs a single-prompt bootstrap to engage the skill, paste this:

```
You are running the Snitch: UX review skill. Read ./SKILL.md and follow the
instructions there exactly. Do not summarize — execute the workflow described.
Start at Step 0: enumerate every user-facing surface in scope and confirm intent
with me before critiquing anything. Do not review the first page you open and
stop. Load reference files from ./references/ as SKILL.md directs — work from the
actual reference files, not from the cheat sheet alone. Run Step 3.5, the ethics
gate, BEFORE you open the persuasion catalog or apply any persuasion technique:
if the surface already contains fabricated urgency, fake scarcity, a hidden or
undisclosed cost, confirmshaming, or a cancellation harder than the signup, those
are findings and you do not optimise them — say so plainly, then finish the review.
Report coverage honestly at the end: every surface reviewed, and what you did not
cover and why.
```

## Tool-specific guidance

### Claude Code (native skill loading)

Skills load automatically from `~/.claude/skills/` or `./.claude/skills/`. Copy this directory to either location — the directory *is* the skill, there is nothing to install. Then invoke by name:

```
/skill snitch-ux
```

It also fires on its own when a request matches the description in SKILL.md's frontmatter (reviewing a page or flow, writing CTA copy, improving conversion, "make this clearer").

### Cursor

Cursor reads from `.cursorrules` or supports custom commands. Two options:

1. **Workspace bootstrap**: copy the universal bootstrap above into `.cursorrules` at the workspace root. Cursor will load it on every session in that workspace.
2. **Manual invocation**: open Cursor's Composer (Cmd+I), paste the bootstrap, point at `./skills/snitch-ux/SKILL.md`.

### GitHub Copilot Chat

Copilot Chat in VS Code can read files via `@workspace`. Run:

```
@workspace Read ./skills/snitch-ux/SKILL.md and execute the UX review skill exactly
as described — Step 0 scoping first, then the per-surface pass, then honest
coverage reporting.
```

For repeated use, save as a Copilot custom instruction (`.github/copilot-instructions.md`).

### OpenAI Codex / ChatGPT (with file access)

Upload the entire `snitch-ux/` directory to your conversation, then paste:

```
Treat this directory as a self-contained skill. Read SKILL.md and execute its
workflow. Load reference files from ./references/ on demand — clarity.md before
the clarity pass, review-checklist.md §10 and SKILL.md Step 3.5 (the ethics gate)
before you open principles.md, principles.md before applying persuasion, and the
rest of review-checklist.md before calling any surface done. The gate comes before
the catalog, never after it.
```

### Continue.dev

Continue supports custom slash commands via `~/.continue/config.json`:

```json
{
  "slashCommands": [
    {
      "name": "ux-review",
      "description": "Run Snitch: UX review",
      "step": "BootstrapSkillStep",
      "params": {
        "skillPath": "./skills/snitch-ux/SKILL.md"
      }
    }
  ]
}
```

Then in chat: `/ux-review`.

### Cody (Sourcegraph)

Cody supports custom commands via `.vscode/cody.json`:

```json
{
  "commands": {
    "ux-review": {
      "description": "Run Snitch: UX review",
      "prompt": "Read ./skills/snitch-ux/SKILL.md and execute the workflow.",
      "context": {
        "currentDir": false,
        "selection": false,
        "openTabs": false
      }
    }
  }
}
```

### Amazon Q Developer

Use Q's "@workspace" file context, then prompt:

```
Read the file at ./skills/snitch-ux/SKILL.md. Follow its instructions exactly —
scope the full surface first, run the clarity pass, then run the Step 3.5 ethics
gate BEFORE any persuasion technique (a surface with fake urgency, a hidden cost,
or a buried cancellation gets those reported as findings, not optimised), then the
persuasion pass, then the accessibility gate, and state what you did not cover.
The skill is self-contained.
```

## What every tool needs

Regardless of tool, the agent must be able to:

1. **Read markdown files** from the bundle (SKILL.md, references/*.md).
2. **Read source files** in the user's working directory — routes, page/view components, templates, layouts. Step 0's surface enumeration depends on this; without it the review degrades to whatever the user pastes in.
3. **Maintain conversation state** across the multi-step flow (scope → confirm → surface-by-surface pass → coverage report).
4. **Ask the user a question mid-run** (the host's clarifying-question tool, or plain chat). Step 0 requires confirming scope, goal, and audience rather than guessing. If your tool can't pause to ask, set `confirm-scope: false` in `snitch-ux.config.md` and state the assumed scope in the report.
5. **Write a markdown file** at the end (see `report-output` in `snitch-ux.config.md`).
6. **Fetch URLs or drive a browser** (optional) — needed only for reviewing a live site rather than a codebase. A screenshot tool (Playwright MCP, or your host's built-in browser) lets the agent judge visual hierarchy, active states, and tap targets directly instead of inferring them from source. Without it, live-site review degrades to reading the served HTML/CSS; codebase review is unaffected.

If your tool can do the first five, this skill works.

## Validating your tool's setup

After bootstrap, the agent should *not* start critiquing. It should scope first — something like:

```
Before reviewing, I found these user-facing surfaces:

  1. / — landing
  2. /signup — sign-up flow (3 steps)
  3. /app — dashboard (default / empty / loading / error states)
  4. /settings — account settings
  5. /pricing — plans + checkout

Which of these are in scope? And what's the goal — conversion, clarity,
accessibility, or a specific drop-off you're seeing?
```

If the agent asks a scoping question like that, the bootstrap succeeded. If it opens with a critique of the first page it read, the bootstrap is being interpreted as a description rather than instructions — try the universal bootstrap with stronger imperative language (e.g., "STOP. Before responding further, read ./SKILL.md and FOLLOW its instructions...").

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Agent summarizes the skill instead of running it | Tool interpreted SKILL.md as text to discuss | Use stronger imperative bootstrap; explicitly say "execute the workflow described, do not summarize" |
| Review covers one page and calls it done | Step 0 skipped | Re-prompt: "enumerate every route/page/flow and its states first, then confirm scope with me" |
| Findings are generic ("improve the hierarchy") | Agent worked from the cheat sheet, never opened `references/` | Require it: "open the reference file before each pass and quote the rule you're applying" |
| Recommendations feel manipulative | Persuasion lens applied without the guardrails | Point it at the Guardrails section and `references/inclusive-design.md`; set `high-stakes: true` in the config for vulnerable audiences |
| Agent halts mid-review asking permission for every Read | Tool requires per-action permission | Pre-authorize the bundle directory for read access |

## Updating the skill

This bundle is a snapshot. The latest version is at https://snitchplugin.com/ux. Updating means replacing the directory — check the `version` in SKILL.md's frontmatter against the published one.
