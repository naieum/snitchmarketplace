# snitch-flyio v1.0.0

Fly.io security + readiness — org/apps/machines/volumes/postgres/secrets/network/token posture and hardening.

## Install

Claude Code:

```
/plugin marketplace add naieum/snitchmarketplace
/plugin install snitch-flyio@snitch
```

Any other tool that loads Agent Skills: copy this folder into your tool's skills
directory (for example `~/.cursor/skills/` or `~/.codex/skills/`), then ask in
plain words for an audit.

The skill itself lives in [`SKILL.md`](SKILL.md). No build step, no server, no
telemetry; it runs on your model, against your code.

## License

MIT. © Snitch — [snitchplugin.com](https://snitchplugin.com)
