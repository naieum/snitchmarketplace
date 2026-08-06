# snitch v9.2.0

Security audit for AI-written code — evidence-based findings (file:line + CWE/OWASP), data-flow tracing, SARIF, compliance evidence (HIPAA, SOC 2, PCI-DSS, GDPR).

## Install

Claude Code:

```
/plugin marketplace add naieum/snitchmarketplace
/plugin install snitch@snitch
```

Any other tool that loads Agent Skills: copy this folder into your tool's skills
directory (for example `~/.cursor/skills/` or `~/.codex/skills/`), then ask in
plain words for an audit.

The skill itself lives in [`SKILL.md`](SKILL.md). No build step, no server, no
telemetry; it runs on your model, against your code.

**Learn more:** [snitchplugin.com/security](https://snitchplugin.com/security) · [Docs](https://snitchplugin.com/docs/security) · [Docs as markdown](https://snitchplugin.com/docs/security.md)

## License

MIT. © Snitch — [snitchplugin.com](https://snitchplugin.com)
