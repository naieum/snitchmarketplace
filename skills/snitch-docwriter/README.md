# snitch-docwriter v0.2.0

Controlled technical writing (ASD-STE100-derived) plus a deterministic anti-slop linter — rewrite docs, READMEs, error messages, and runbooks so they cannot be misread.

## Install

Claude Code:

```
/plugin marketplace add naieum/snitchmarketplace
/plugin install snitch-docwriter@snitch
```

Any other tool that loads Agent Skills: copy this folder into your tool's skills
directory (for example `~/.cursor/skills/` or `~/.codex/skills/`), then ask in
plain words for an audit.

The skill itself lives in [`SKILL.md`](SKILL.md). No build step, no server, no
telemetry; it runs on your model, against your code.

**Learn more:** [snitchplugin.com/docwriter](https://snitchplugin.com/docwriter) · [Docs](https://snitchplugin.com/docs/docwriter) · [Docs as markdown](https://snitchplugin.com/docs/docwriter.md)

## License

**Free to use, not to sell.** MIT with the Commons Clause: use the skills anywhere
(including at work), modify them, share them — every copy and derivative must keep
the license and credit Snitch. Selling the skills, or a product or service whose
value derives substantially from them, is not permitted. Full text in
[`LICENSE`](LICENSE). © Snitch — [snitchplugin.com](https://snitchplugin.com)
