<p align="center">
  <img src="assets/snitch-shield.png" alt="Snitch" width="120">
</p>

<h1 align="center">Snitch — Security Skill Marketplace</h1>

<p align="center">
  Evidence-based security &amp; readiness skills for AI coding agents.<br>
  One brand, à-la-carte install. <strong>Powered by Snitch.</strong>
</p>

---

A Claude Code **plugin marketplace** that bundles the Snitch family of security skills. Each skill
is its own plugin — install only the ones you need, and only those load into your agent's context.

## Install

Add the marketplace once, then install any plugin:

```
/plugin marketplace add naieum/snitchmarketplace
/plugin install snitch-cloudflare@snitch
```

> The repo is private during prep — `marketplace add` works while you're authenticated to GitHub
> with read access. The public product home is **[snitchplugin.com](https://snitchplugin.com)**.

## Catalog

| Plugin | Audits | Install |
|---|---|---|
| `snitch` | AI-written code — OWASP, CWE, data-flow, SARIF, compliance (HIPAA/SOC 2/PCI-DSS/GDPR) | `/plugin install snitch@snitch` |
| `snitch-marketing` | SEO / GEO (AI-search) / schema / Core Web Vitals | `/plugin install snitch-marketing@snitch` |
| `snitch-cloudflare` | Cloudflare zone/account/Workers/Pages/Tunnel/Access posture + hardening | `/plugin install snitch-cloudflare@snitch` |
| `snitch-aws` | AWS IAM/S3/EC2/VPC/RDS/Lambda/CloudTrail/GuardDuty posture + hardening | `/plugin install snitch-aws@snitch` |
| `snitch-azure` | Azure subscription/Entra/RBAC/Defender/storage/keyvault posture + hardening | `/plugin install snitch-azure@snitch` |
| `snitch-digitalocean` | DigitalOcean Droplet/Database/Spaces/App-Platform/DOKS/Firewall posture + hardening | `/plugin install snitch-digitalocean@snitch` |
| `snitch-flyio` | Fly.io org/apps/machines/volumes/postgres/secrets/network posture + hardening | `/plugin install snitch-flyio@snitch` |
| `snitch-railway` | Railway workspace/project/services/env/volumes/databases/domains posture + hardening | `/plugin install snitch-railway@snitch` |
| `snitch-vercel` | Vercel account/team/project/env/domains/deployments/functions posture + hardening | `/plugin install snitch-vercel@snitch` |

## What these skills do

- **`snitch` / `snitch-marketing`** — content-driven audit skills. They read your code (or crawl a
  URL) and report evidence-based findings with `file:line` precision. No false-positive guesswork.
- **The provider skills (`snitch-<cloud>`)** — thin bash tools the agent composes. They `detect` your
  project, `audit` your live cloud posture, apply **idempotent** hardening (`fix`), respond to
  incidents (`panic`), and give honest migration/scaling verdicts. Read-only tools emit JSON;
  mutations are explicit and confirmable.

## Licensing

Plugins carry their own licenses — see each skill's `LICENSE`:

- `snitch` and `snitch-marketing` — **MIT**.
- All `snitch-<provider>` security skills — **BUSL-1.1** (source-available; converts to Apache-2.0 on the change date).

---

<p align="center"><sub>Powered by <strong>Snitch</strong> · <a href="https://snitchplugin.com">snitchplugin.com</a></sub></p>
