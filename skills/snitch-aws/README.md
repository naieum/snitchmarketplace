# snitch-aws v1.0.0

AWS security + readiness — IAM/S3/EC2/VPC/RDS/Lambda/CloudFront/CloudTrail/GuardDuty posture and hardening.

## Install

Claude Code:

```
/plugin marketplace add naieum/snitchmarketplace
/plugin install snitch-aws@snitch
```

Any other tool that loads Agent Skills: copy this folder into your tool's skills
directory (for example `~/.cursor/skills/` or `~/.codex/skills/`), then ask in
plain words for an audit.

The skill itself lives in [`SKILL.md`](SKILL.md). No build step, no server, no
telemetry; it runs on your model, against your code.

## License

MIT. © Snitch — [snitchplugin.com](https://snitchplugin.com)
