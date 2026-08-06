# snitch-vercel v1.0.0

Vercel security + readiness — account/team/project/env/domains/deployments/protection/functions posture and hardening.

## Install

Claude Code:

```
/plugin marketplace add naieum/snitchmarketplace
/plugin install snitch-vercel@snitch
```

Any other tool that loads Agent Skills: copy this folder into your tool's skills
directory (for example `~/.cursor/skills/` or `~/.codex/skills/`), then ask in
plain words for an audit.

The skill itself lives in [`SKILL.md`](SKILL.md). No build step, no server, no
telemetry; it runs on your model, against your code.

## License

MIT. © Snitch — [snitchplugin.com](https://snitchplugin.com)
