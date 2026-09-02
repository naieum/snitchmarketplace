<p align="center">
  <img src="assets/snitch-shield.png" alt="Snitch" width="120">
</p>

<h1 align="center">Snitch</h1>

<p align="center">
  <strong>AI writes your code fast. Snitch checks it.</strong><br>
  Eleven free Agent Skills for AI-built products: audits for security, SEO and
  marketing, UX, paid-ads readiness, and app-store readiness, plus a build-time
  blueprint, a marketing foundation and drafting skill, persuasive page structure,
  controlled technical writing, a repo bootstrap for AI development, and a router
  that tells you which one fits.<br>
  Every finding cites the exact file and line. No proof, no finding.
</p>

<p align="center">
  <a href="https://snitchplugin.com">snitchplugin.com</a> ·
  <a href="https://snitchplugin.com/docs">Docs</a> ·
  <a href="https://snitchplugin.com/lab/cream">The Lab</a> ·
  <a href="https://snitchplugin.com/self-audit">Self-audit</a> ·
  <a href="https://snitchplugin.com/llms.txt">For agents</a>
</p>

---

A skill is a plain folder of instructions your AI coding tool reads. There is no build step, no
server, no account, and no telemetry. Skills run inside your coding tool, on your model, against
your code. Nothing phones home.

They load in any tool that reads Agent Skills: Claude Code, Codex, Cursor, GitHub Copilot,
Gemini CLI, Windsurf, Goose, Cline, Zed, OpenCode, and 60+ more.

## Install

**Claude Code — all skills, one command:**

```
/plugin marketplace add naieum/snitchmarketplace
/plugin install snitch@snitch
```

**Any terminal — snitch-security only:**

```
curl -fsSL https://snitchplugin.com/snitch.sh | sh
```

**Every other tool — copy one folder:**

```
git clone https://github.com/naieum/snitchmarketplace
cp -r snitchmarketplace/skills/<name> <your tool's skills directory>/
```

Common skills directories: `~/.cursor/skills/`, `~/.codex/skills/`. Check your tool's docs.
Then ask in plain words: *"run a snitch security scan."*

## The skills

| Skill | Version | What it does |
|---|---|---|
| [`snitch`](skills/snitch) | 9.5.0 | Is your AI-written code secure? Scans it for real vulnerabilities and proves each one with file and line evidence. [Site](https://snitchplugin.com/security) · [Docs](https://snitchplugin.com/docs/security) |
| [`snitch-marketing`](skills/snitch-marketing) | 1.15.0 | Why isn't your site ranking or converting? Audits your SEO, AI-search visibility, page speed, accessibility, and how well the pages persuade, with evidence for every finding. [Site](https://snitchplugin.com/marketing) · [Docs](https://snitchplugin.com/docs/marketing) |
| [`snitch-ux`](skills/snitch-ux) | 0.10.0 | Will people actually use this screen? Reviews your interface and its on-screen copy for clarity and honest persuasion. [Site](https://snitchplugin.com/ux) · [Docs](https://snitchplugin.com/docs/ux) |
| [`snitch-focusedcopy`](skills/snitch-focusedcopy) | 0.2.0 | Is your landing page copy in the wrong order? Restructures it around a widely taught sales-call framework and checks every claim. [Site](https://snitchplugin.com/focusedcopy) · [Docs](https://snitchplugin.com/docs/focusedcopy) |
| [`snitch-devready`](skills/snitch-devready) | 0.5.0 | Is your repo ready for an AI coding assistant? Sets up the config, commands, and permissions it needs. [Site](https://snitchplugin.com/devready) · [Docs](https://snitchplugin.com/docs/devready) |
| [`snitch-docwriter`](skills/snitch-docwriter) | 0.4.1 | Does your writing sound like AI wrote it? Rewrites docs in plain controlled English and scores the result. [Site](https://snitchplugin.com/docwriter) · [Docs](https://snitchplugin.com/docs/docwriter) |
| [`snitch-adsready`](skills/snitch-adsready) | 0.4.0 | Ready to run paid ads? Checks your pixels, conversion tracking, and consent setup across ten ad platforms. [Site](https://snitchplugin.com/adsready) · [Docs](https://snitchplugin.com/docs/adsready) |
| [`snitch-storeready`](skills/snitch-storeready) | 0.3.1 | Will Apple or Google reject your app? Audits it against both stores' submission rules before you submit. [Site](https://snitchplugin.com/storeready) · [Docs](https://snitchplugin.com/docs/storeready) |
| [`snitch-cmo`](skills/snitch-cmo) | 0.3.0 | Don't have a marketing strategy yet? Builds one from your product's real facts: who to sell to, what the price you already charge says about you, your brand story and your names. Then drafts the posts and sales copy for you to publish. [Site](https://snitchplugin.com/cmo) · [Docs](https://snitchplugin.com/docs/cmo) |
| [`snitch-blueprint`](skills/snitch-blueprint) | 0.3.0 | Not sure what to build, or what to charge for it? Decides your audience, pages, price, and build order — before you write code, or partway through a build nobody made those calls on. [Site](https://snitchplugin.com/blueprint) · [Docs](https://snitchplugin.com/docs/blueprint) |
| [`snitch-router`](skills/snitch-router) | 0.2.0 | Not sure which skill you need? Ask this one and it points you to the right skill or flow. [Site](https://snitchplugin.com/router) · [Docs](https://snitchplugin.com/docs/router) |

## Platform hardening skills

Posture audits + idempotent hardening for the platform you deploy on:

| Skill | Version | Platform |
|---|---|---|
| [`snitch-cloudflare`](skills/snitch-cloudflare) | 1.0.0 | Cloudflare — zone, Workers, Pages, Tunnel, Access |
| [`snitch-aws`](skills/snitch-aws) | 1.0.0 | AWS — IAM, S3, EC2, VPC, RDS, Lambda, CloudTrail, GuardDuty |
| [`snitch-azure`](skills/snitch-azure) | 1.0.0 | Azure — Entra, RBAC, Defender, storage, Key Vault |
| [`snitch-digitalocean`](skills/snitch-digitalocean) | 1.0.0 | DigitalOcean — Droplets, Spaces, DOKS, firewalls |
| [`snitch-flyio`](skills/snitch-flyio) | 1.0.0 | Fly.io — apps, machines, volumes, Postgres, secrets |
| [`snitch-railway`](skills/snitch-railway) | 1.0.0 | Railway — services, env, volumes, databases, domains |
| [`snitch-vercel`](skills/snitch-vercel) | 1.0.0 | Vercel — projects, env, deployment protection, functions |

## The method

Every skill enforces the same rules:

- **Evidence or it didn't happen.** A finding without a file and line does not ship.
- **Passes are results, not silence.** Clean categories come with proof, not a checkmark.
- **Honest coverage.** Skips are stated with reasons. "3 of 11 surfaces" means 3 of 11.
- **Read-only scans.** Auditing and fixing are separate phases, always.
- **We audit ourselves.** [snitchplugin.com/self-audit](https://snitchplugin.com/self-audit) is
  this family's own skills run against its own site, findings published — including the open ones.

Want proof the method matters? [Eight AI models ran the same audit on the same
codebase.](https://snitchplugin.com/lab/cream) One found the missing buy button. One cited a
line that says the opposite of its claim.

## For agents

Reading this programmatically? Everything you need in one fetch:

- Structured manifest: [snitchplugin.com/skills.json](https://snitchplugin.com/skills.json)
- Full reference: [snitchplugin.com/llms-full.txt](https://snitchplugin.com/llms-full.txt)
- Raw-markdown docs: `https://snitchplugin.com/docs/<slug>.md`

## License

**Free to use, not to sell.** MIT with the Commons Clause: use the skills anywhere
(including at work), modify them, share them — every copy and derivative must keep
the license and credit Snitch. Selling the skills, or a product or service whose
value derives substantially from them, is not permitted. Full text in
[`LICENSE`](LICENSE). © Snitch — [snitchplugin.com](https://snitchplugin.com)
