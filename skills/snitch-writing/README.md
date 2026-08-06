# snitch-writing v0.1.0

Controlled technical writing (ASD-STE100-derived) plus a deterministic anti-slop linter — rewrite docs, READMEs, error messages, and runbooks so they cannot be misread.

## Install

Claude Code:

```
/plugin marketplace add naieum/snitchmarketplace
/plugin install snitch-writing@snitch
```

Any other tool that loads Agent Skills: copy this folder into your tool's skills
directory (for example `~/.cursor/skills/` or `~/.codex/skills/`), then ask in
plain words for an audit.

The skill itself lives in [`SKILL.md`](SKILL.md). No build step, no server, no
telemetry; it runs on your model, against your code.

**Learn more:** [snitchplugin.com/writing](https://snitchplugin.com/writing) · [Docs](https://snitchplugin.com/docs/writing) · [Docs as markdown](https://snitchplugin.com/docs/writing.md)

## License

MIT. © Snitch — [snitchplugin.com](https://snitchplugin.com)
