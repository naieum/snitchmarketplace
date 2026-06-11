# Recipes

Offline mirror of orchestration recipes. The agent synthesizes; tools provide facts.

## Audit / harden

Run digests in parallel.

```
bash snitch-digitalocean.sh doctor
bash snitch-digitalocean.sh detect
bash snitch-digitalocean.sh state account digest
bash snitch-digitalocean.sh state droplets digest
bash snitch-digitalocean.sh state databases digest
bash snitch-digitalocean.sh state firewalls digest
bash snitch-digitalocean.sh state apps digest
bash snitch-digitalocean.sh state loadbalancers digest
bash snitch-digitalocean.sh state kubernetes digest
bash snitch-digitalocean.sh state vpcs digest
bash snitch-digitalocean.sh state dns digest
bash snitch-digitalocean.sh state monitoring digest
bash snitch-digitalocean.sh state cost digest
```

Then:

1. Compare digests against `references/02-network-vpc-firewalls.md`, `03-droplets.md`, `05-managed-databases.md`, `06-app-platform.md`.
2. Fetch a slice only when a digest signals it (`state droplets list` if features missing; `state firewalls list` if `mgmt_port_open_world_count > 0`).
3. Render the report per "Report format" below.
4. Ask which areas to fix. Run `bash snitch-digitalocean.sh fix <area>` then `bash snitch-digitalocean.sh verify`.

## "Should I migrate to DigitalOcean?"

Offline; no token required.

```
bash snitch-digitalocean.sh detect
bash snitch-digitalocean.sh fit-matrix <stack>
bash snitch-digitalocean.sh stack-docs <stack>
```

`WebFetch` the URLs, then `WebSearch` `<stack> digitalocean security best practices <year>`. Lead with the verdict.

DO is strong for traditional web stacks. For serverless / edge-first, surface gaps: no L7 WAF, no DNSSEC on managed DNS, no global CDN beyond Spaces CDN.

## Database honesty

| Source | Path |
|---|---|
| MySQL | Managed MySQL via `mysqldump` |
| Postgres | Managed Postgres via `pg_dump` |
| MongoDB Atlas | Managed MongoDB via `mongodump | mongorestore` |
| Redis Cloud / Elasticache | Managed Redis via snapshot+restore or `MIGRATE` |
| S3 | Spaces via `aws s3 sync` with endpoint override |

Close with cost realism (`references/14-cost-and-budgets.md`), DNS cutover (lower TTL → switch → verify → decommission), rollback path.

## Scaling readiness

```
bash snitch-digitalocean.sh state droplets digest
bash snitch-digitalocean.sh state databases digest
bash snitch-digitalocean.sh state apps digest
bash snitch-digitalocean.sh state cost digest
bash snitch-digitalocean.sh detect
```

| Plateau | Stack |
|---|---|
| <1k req/min | Single Droplet + Managed Basic DB + Spaces |
| 1k-10k | App Platform `instance_count: 2-3` OR LB + 2 Droplets + Production DB |
| 10k-100k | DOKS or LB + autoscaled Droplets + Managed DB Production w/ read replicas + Cloudflare |
| 100k+ | DOKS HA + multi-region (DO has no multi-region replication; plan around it) |

## Diagnose

| Symptom | Tools | Likely cause |
|---|---|---|
| slow / latency | `state droplets digest`, `state apps digest` | Saturation; size mismatch |
| region X failing | `state droplets list` + `state vpcs digest` | Region outage; status.digitalocean.com |
| DB connection refused | `state databases digest` + `state firewalls digest` | trusted_sources empty; VPC mismatch |
| bill spike | `state cost digest` | New resource; snapshot accumulation |
| TLS error | `score <host>` | Cert expiry; chain; modern TLS |

## Token leaked / under attack

```
bash snitch-digitalocean.sh panic rotate-token
bash snitch-digitalocean.sh panic firewall-block <ip>
bash snitch-digitalocean.sh panic spaces-lockdown <bucket>
bash snitch-digitalocean.sh panic restore
```

Postmortem: `references/13-incident-response.md`.

## Report format

Every audit / migrate / roadmap report MUST:

- Open with a one-line verdict.
- Use markdown tables. No prose paragraphs between sections except a single transitional sentence.
- Close with "Next steps" — at most three imperative bullets.
- Status badges: 🔴 FAIL / 🟡 WARN / ⚪️ N/A / 🟢 OK. Sort 🔴 → 🟡 → ⚪️ → 🟢.

### Findings

```markdown
| Status | Area | Finding | Remediation |
|---|---|---|---|
| 🔴 FAIL | firewalls | SSH (22) world-open on `web-tier` | Restrict to office CIDR or bastion tag |
| 🟡 WARN | droplets | `app-prod-1` has no automated backups | Enable backups (~20% of price) |
| ⚪️ N/A | account | SSO enforcement is team-only | Upgrade to a team account if needed |
| 🟢 OK | databases | All clusters in private VPC with TLS-only |  |
```

### Architecture inventory

```markdown
| Component | Detail | Source |
|---|---|---|
| App Platform | `marketing-site`, `api-prod` | NYC region |
| Managed Postgres | `pg-prod-cluster` | NYC, VPC `prod-net` |
| Spaces | `assets-prod` | NYC3, served via CDN |
```

### Cost / scaling

```markdown
| Driver | Current | Watch for |
|---|---|---|
| Reserved IPs | 2 attached, 1 unattached | $5/mo per unattached |
| Snapshots | 14 retained | Accumulate forever; $0.06/GB/mo |
```

### Migration verdict

```markdown
| Stack detected | Verdict | Recommended path |
|---|---|---|
| laravel | 🟢 strong | App Platform PHP + Managed Postgres |
| nextjs | 🟢 strong | App Platform Node buildpack |
| static-spa | 🟢 strong | Spaces + CDN |
```

## Common mistakes

- DNSSEC on DO managed DNS — unsupported. Recommend Cloudflare DNS in front.
- L7 WAF on DigitalOcean — none. Cloudflare or origin-side rules.
- Don't run mutations under a read flow; `fix` and `panic` require user confirmation.
- Don't write inside the user's project. `apply_*` libs emit contents+diff; the agent applies via `Edit` / `Write`.
- Don't pre-load all of `references/`.
