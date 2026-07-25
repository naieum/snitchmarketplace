# Snitch: Marketing — entry point for non-Claude tools

This skill bundle is portable. It works in Claude Code (native skill loading), Cursor, GitHub Copilot Chat, OpenAI Codex / ChatGPT with file access, Continue.dev, Cody, Amazon Q Developer — any AI coding tool that can read markdown files from disk and follow extended instructions.

The skill's brain is `SKILL.md`. Everything else (categories, references, souls) is loaded on-demand by the agent following SKILL.md's directives.

## Universal bootstrap

If your tool needs a single-prompt bootstrap to engage the skill, paste this:

```
You are running the Snitch: Marketing SEO audit skill. Read ./SKILL.md and follow
the instructions there exactly. Do not summarize — execute the workflow described,
including the anti-hallucination rules, the scan menu, and the post-scan actions
menu. The category catalog is in ./categories/ (120 files) and the references the
skill needs are in ./references/. The voice library for fix prose is in ./souls/
(23 files). Read soul JSON files before writing any voiced fix; the audit metadata
must include voice_reads_completed listing every soul you actually read.
```

## Tool-specific guidance

### Claude Code (native skill loading)

Skills load automatically from `~/.claude/skills/` or `./.claude/skills/`. If this bundle is at `./skills/snitch-marketing/`, run:

```
/skill snitch-marketing
```

### Cursor

Cursor reads from `.cursorrules` or supports custom commands. Two options:

1. **Workspace bootstrap**: copy the universal bootstrap above into `.cursorrules` at the workspace root. Cursor will load it on every session in that workspace.
2. **Manual invocation**: open Cursor's Composer (Cmd+I), paste the bootstrap, point at `./skills/snitch-marketing/SKILL.md`.

### GitHub Copilot Chat

Copilot Chat in VS Code can read files via `@workspace`. Run:

```
@workspace Read ./skills/snitch-marketing/SKILL.md and execute the SEO audit skill
exactly as described, including all anti-hallucination rules and category loading.
```

For repeated use, save as a Copilot custom instruction (`.github/copilot-instructions.md`).

### OpenAI Codex / ChatGPT (with file access)

Upload the entire `snitch-marketing/` directory to your conversation, then paste:

```
Treat this directory as a self-contained skill. Read SKILL.md and execute its
workflow. Load category files from ./categories/ on demand. Load soul files
from ./souls/ before writing voiced fixes.
```

### Continue.dev

Continue supports custom slash commands via `~/.continue/config.json`:

```json
{
  "slashCommands": [
    {
      "name": "seo-audit",
      "description": "Run Snitch: Marketing SEO audit",
      "step": "BootstrapSkillStep",
      "params": {
        "skillPath": "./skills/snitch-marketing/SKILL.md"
      }
    }
  ]
}
```

Then in chat: `/seo-audit`.

### Cody (Sourcegraph)

Cody supports custom commands via `.vscode/cody.json`:

```json
{
  "commands": {
    "seo-audit": {
      "description": "Run Snitch: Marketing SEO audit",
      "prompt": "Read ./skills/snitch-marketing/SKILL.md and execute the workflow.",
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
Read the file at ./skills/snitch-marketing/SKILL.md. Follow its instructions
exactly — anti-hallucination rules, scan menu, evidence requirements, voiced
remediations. The skill is self-contained.
```

## What every tool needs

Regardless of tool, the agent must be able to:

1. **Read markdown files** from the bundle (SKILL.md, categories/*.md, references/*.md, souls/*.json).
2. **Read source files** in the user's working directory (for source-mode audits).
3. **Fetch URLs** (for crawl-mode audits) — most tools provide this; if yours doesn't, source mode is still usable.
4. **Maintain conversation state** for the multi-step scan flow (menu → selection → category-by-category execution → report).
5. **Write a markdown file** at the end (`SEO_AUDIT_REPORT.md` in the working directory, by default).
6. **Run a shell / Bash command** (optional but recommended) — enables crawl-mode discovery (`whois` for domain age in STEP 0.6) and a few categories' evidence (`curl` / `file` for og:image dimensions in Cat 11, backlink/whois checks in Cat 69, SERP inspection in Cat 86). Without a shell, those degrade to Skip-with-reason rather than failing; the rest of the audit still runs.

If your tool can do the first five, this skill works; a shell adds the crawl-mode discovery and tool-backed evidence above.

## Validating your tool's setup

After bootstrap, the agent should produce this output (or equivalent):

```
SEO & Marketing Audit for [your project]

What would you like to scan?

[1]  Quick Audit (Recommended) — 10-13 highest-impact cats. ~5-10 min small site...
[2]  Technical SEO — 13 cats...
[3]  Content & Structure — 13 cats...
...
[17] Accessibility deep-dive — 13 cats...

[0]  Exit

Enter your choice (0-17):
```

If the agent presents the menu correctly, the bootstrap succeeded. If it summarizes or skips the menu, the bootstrap is being interpreted as a description rather than instructions — try the universal bootstrap with stronger imperative language (e.g., "STOP. Before responding further, read ./SKILL.md and FOLLOW its instructions...").

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Agent summarizes the skill instead of running it | Tool interpreted SKILL.md as text to discuss | Use stronger imperative bootstrap; explicitly say "execute the workflow described, do not summarize" |
| Categories not loading | Tool doesn't have file-read access to `./categories/` | Grant directory access OR upload the categories folder explicitly |
| Voiced fixes don't sound distinct | Soul JSONs not being read | Confirm the agent reads `souls/{slug}.json` before writing fixes; `voice_reads_completed` array in the report metadata is the verification |
| Agent halts mid-audit asking permission for every Read | Tool requires per-action permission | Pre-authorize the bundle directory for read access |

## Updating the skill

This bundle is a snapshot. The latest version is at https://snitchplugin.com/marketing.

Updates are versioned; the current version is `metadata.version` in `SKILL.md`'s frontmatter, the single source of truth. To update, re-download the bundle and replace the directory.
