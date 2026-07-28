# Snitch: DevReady — entry point for non-Claude tools

This skill bundle is portable. The brain is `SKILL.md`; the tools are plain bash + jq
(`devready.sh detect | standards | perms | template`), and every artifact it proposes is
markdown or JSON written by the agent after user confirmation — nothing here requires
Claude Code to run.

## Universal bootstrap

If your tool needs a single-prompt bootstrap, paste this:

```
You are running the Snitch: DevReady repo-bootstrap skill. Read ./SKILL.md and follow
it exactly. Run ./devready.sh detect first and branch on .mode; read
./references/30-recipes.md for the per-mode flow. Never write product code or scaffold
the app; propose every artifact as a diff and wait for my confirmation. Follow the
"Context-file targeting" section: since this session is not Claude Code, the canonical
context file is AGENTS.md (with thin pointer files for other tools), and the
Claude-specific artifacts (.claude/commands, settings permissions, hooks template) are
offered only if the team also uses Claude Code. The commit gate and CI gate from
Recipe E apply regardless of tool.
```

## What every tool needs

1. **Run shell commands** — `devready.sh` needs bash + `jq` (`brew install jq`).
2. **Read and write repo files** — the artifacts are checked-in markdown/JSON.
3. **Ask the user a question mid-run** — the component plan and every artifact are
   confirmed before writing; if your tool can't pause, state assumptions explicitly and
   write nothing without a listed diff.

## What changes outside Claude Code

| Artifact | Claude Code | Other tools |
|---|---|---|
| Context file | `CLAUDE.md` | `AGENTS.md` canonical + per-tool pointers |
| Standards section (Recipe E) | same markdown | same markdown |
| Commit gate / CI gate | same — tool-agnostic | same — tool-agnostic |
| Agent-loop hooks (`settings-hooks`) | `.claude/settings.json` hooks | not bundled — rely on the commit gate |
| Slash commands, permissions allowlist | `.claude/` artifacts | skip unless the team also runs Claude Code |

## Updating the skill

This bundle is a snapshot; the current version is `metadata.version` in `SKILL.md`'s
frontmatter. The latest lives at https://snitchplugin.com.
