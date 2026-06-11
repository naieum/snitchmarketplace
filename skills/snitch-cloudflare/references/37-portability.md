# 37 — Portability (Claude Code / Agent SDK + OpenAI Codex)

This skill targets two runtimes: Anthropic (Claude Code + Claude Agent SDK) and
OpenAI Codex. Both now implement the same Agent Skills core (`SKILL.md` with
`name` + `description`, a Markdown body, and `scripts/`/`references/`), so one
folder serves both. All real logic is in the agent-agnostic `snitch-cloudflare.sh`
+ `references/`; only the manifest layer differs.

## Conformance rules this skill follows (keep them when editing)

- **Frontmatter is the "boring core" only:** `name` + `description`. Do not make
  Claude-only keys (`allowed-tools`, `disable-model-invocation`, `paths`, hooks,
  `context: fork`, `argument-hint`) load-bearing — Codex does not honor them. Put
  any such intent in the Markdown body or in `agents/openai.yaml`.
- `name` ≤ 64 chars, lowercase/digits/hyphens, no leading/trailing/`--`, and
  **must equal the skill's directory name** (`snitch-cloudflare`).
- `description` ≤ 1024 chars; states what it does AND when to use it (triggers).
- **Reference the CLI by a path relative to the skill folder** — never a machine-
  specific absolute path. In Claude use `${CLAUDE_SKILL_DIR}/snitch-cloudflare.sh`;
  otherwise `bash snitch-cloudflare.sh` from the skill dir. The script resolves
  its own location via `BASH_SOURCE`, so `lib/`/`references/`/`templates/` resolve
  regardless of CWD.
- Reference docs use relative paths (`references/NN-*.md`); progressive
  disclosure — keep `SKILL.md` lean and link out.
- CLI keeps a portable shebang (`#!/usr/bin/env bash`) and the executable bit.

## Placement

Canonical folder (directory name `snitch-cloudflare`):

- **Claude Code:** `~/.claude/skills/snitch-cloudflare/` (user) or
  `<repo>/.claude/skills/snitch-cloudflare/` (project).
- **Claude Agent SDK:** auto-discovered from the same locations when
  `settingSources`/`setting_sources` includes `"user"`/`"project"` (the default).
  Skills can't be registered programmatically — they must be filesystem folders.
- **Codex:** `~/.agents/skills/snitch-cloudflare/` (user) or
  `<repo>/.agents/skills/snitch-cloudflare/` (project). Codex follows symlinks,
  so point one at the other instead of duplicating:

  ```sh
  mkdir -p ~/.agents/skills
  ln -s ~/.claude/skills/snitch-cloudflare ~/.agents/skills/snitch-cloudflare
  ```

  Optionally pin it in `~/.codex/config.toml` (then restart Codex):

  ```toml
  [[skills.config]]
  path = "/Users/<you>/.agents/skills/snitch-cloudflare/SKILL.md"
  enabled = true
  ```

## Codex caveats (call out to users)

- **Network egress is OFF by default** in Codex's sandbox (`workspace-write`).
  Every live tool here hits the Cloudflare API, so it will be blocked or prompt
  for approval. Run with network enabled (e.g. enable `network_access`, the
  full-auto preset, or approve the escalation). `agents/openai.yaml` declares
  `requirements.network_access: true` as a hint.
- **Approval model differs:** Codex defaults to `approval_policy = "on-request"`.
  Read-only subcommands are low-risk, but a first invocation (and any egress) may
  prompt. `mutating` tools (`fix`, `panic`) should always prompt — keep them so.
- **Don't rely on a global `~/.codex/AGENTS.md`** (not reliably auto-loaded);
  prefer the user-level skill dir or a small repo `AGENTS.md` pointer.

## What is NOT portable (and the replacement)

| Claude-only | Portable replacement |
|---|---|
| `allowed-tools` frontmatter | Claude settings / Agent SDK `allowedTools`; Codex sidecar policy |
| `${CLAUDE_SKILL_DIR}` substitution | also accept relative `bash snitch-cloudflare.sh` |
| `~/.claude/skills` path | symlink into `~/.agents/skills` for Codex |
| custom prompts / slash commands | deprecated in Codex — use the skill description instead |
