# Plan-tier matrix

Railway tiers (current as of 2026-Q2; verify on pricing page):

| Tier | Monthly | Usage cap | Key features |
|---|---|---|---|
| Trial | $0 | $5 lifetime | sandbox; sleep enabled |
| Hobby | $5/mo | $5 included | always-on supported; small projects |
| Pro | $20/mo per seat | $20 included | log drains, team workspaces, priority + email support |
| Enterprise | custom | custom | SOC 2 reports, custom contracts, dedicated support |

## Feature gating

| Feature | Required tier |
|---|---|
| Sleep on inactivity | trial / hobby (auto) |
| Always-on services | hobby+ |
| Multiple environments | hobby+ |
| Log drains to SIEM | pro+ |
| Team workspaces | pro+ |
| Custom domains (unlimited) | hobby+ |
| Higher usage caps | pro+ |
| SOC 2 / compliance docs | enterprise |
| SSO | enterprise |

## Cost shape

Railway bills by:
- vCPU-hours (compute)
- GB-hours (memory)
- GB-months (volumes)
- GB transfer (egress)
- Add-on container hours (Postgres / Redis count as services)

A single always-on Node service with 1 vCPU + 1 GB RAM costs ~$5–10/mo at modest traffic. Add Postgres add-on: ~$15–25/mo.

## `[locked: pro+]` findings

The skill never blocks on tier. It surfaces `⚪️ N/A [locked: pro+]` for plan-gated features (log drains, team workspaces) so the user knows what's worth upgrading for.

## Docs

- https://railway.com/pricing
- https://docs.railway.com/reference/usage
