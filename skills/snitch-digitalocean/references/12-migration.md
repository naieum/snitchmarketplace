# Migration to DigitalOcean

DigitalOcean is **strong** for traditional web stacks (PHP, Ruby, Python, JVM, Node) and **partial** for serverless / edge-first.

## Verdict patterns

| From | Verdict | Path |
|---|---|---|
| AWS EC2 + RDS | strong | Droplet + Managed DB. Lift-and-shift; tune size after a week. |
| AWS Elastic Beanstalk | strong | App Platform for HTTP-only; Droplet+Docker for full parity. |
| AWS Lambda + API Gateway | partial | Functions for thin wrappers; App Platform for stateful. |
| Heroku | strong | App Platform (closest 1:1 — buildpacks, dynos, add-ons). |
| Render / Railway | strong | App Platform. |
| Vercel / Netlify (static) | strong | Spaces + CDN. |
| Vercel (Next.js SSR) | strong | App Platform Node buildpack. |
| Fly.io | strong | DOKS or App Platform; Droplets for global placement. |
| GCP App Engine | strong | App Platform. |
| Self-hosted on metal | strong | Droplets. |

## DNS cutover

1. Lower TTL of existing zone to 60s. Wait at least the OLD TTL.
2. Create new resources at DO.
3. Verify endpoints via direct IP / Host header.
4. Switch nameservers at the registrar to DO's (`ns1.digitalocean.com`...) OR change A/AAAA/CNAME records.
5. Wait propagation. Verify with `dig +trace`.
6. Decommission old infrastructure after monitoring shows traffic shifted.

## Rollback

- Keep old infrastructure running ≥7d post-cutover.
- DNS rollback = revert records at registrar; effective within new (low) TTL.

## Database migration

| Source | Target | Tooling |
|---|---|---|
| AWS RDS Postgres | Managed Postgres | `pg_dump | pg_restore` or AWS DMS |
| AWS RDS MySQL | Managed MySQL | `mysqldump | mysql` or DMS |
| MongoDB Atlas | Managed MongoDB | `mongodump | mongorestore` or live replication |
| Redis Cloud / Elasticache | Managed Redis | `redis-cli --rdb` snapshot+restore or live `MIGRATE` |
| S3 | Spaces | `aws s3 sync` with endpoint override (zero-downtime: dual-write → switch reads → archive) |

## Cost realism

Generally cheaper than AWS for predictable workloads, more expensive than serverless platforms at low usage. Run numbers before migrating from AWS Spot, GCP preemptibles, or free-tier-friendly platforms.

## What DigitalOcean does NOT have

| Gap | Replacement |
|---|---|
| L7 WAF | Cloudflare in front |
| DNSSEC on managed DNS | Cloudflare DNS in front |
| Global CDN beyond Spaces CDN | Cloudflare or Fastly |
| L7 DDoS protection | Cloudflare |
| Identity / SSO product | Auth0, Clerk, WorkOS, Authelia, Keycloak |
| Secrets manager | Vault, Doppler, App Platform `SECRET` env |
| Service mesh | DOKS + Linkerd / Istio (self-installed) |
