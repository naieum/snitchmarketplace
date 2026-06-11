# 12 — Migration

When asked "should I move to AWS?", produce a verdict from `templates/migration-fit-matrix.json` and ground it via `templates/stack-docs-registry.json`.

## Verdicts

| Verdict | Meaning |
|---|---|
| `strong` | first-class fit (static SPA → S3+CloudFront, Hono → Lambda, Go monolith → Lambda or App Runner) |
| `partial` | workable with caveats (Express on Lambda + serverless-express; Rails on Fargate but ActionCable needs care) |
| `proxy-only` | put AWS in front of an existing host — rare for AWS (CDN-only) |
| `not-recommended` | better fit elsewhere |

## DNS cutover playbook

1. Provision the AWS resource (S3 bucket, CloudFront, ALB, App Runner).
2. Validate via temporary CloudFront / ALB DNS name.
3. Add ACM cert (us-east-1 for CloudFront).
4. Lower DNS TTL on the existing record to 60s well in advance.
5. Cutover: change DNS record to point at the AWS resource.
6. Watch new endpoint metrics; rollback by reverting DNS.
7. Raise TTL back once stable.

## Database migration

| Source → Target | Approach |
|---|---|
| Postgres / MySQL → RDS / Aurora | pg_dump / mysqldump for small; DMS for live cutover |
| MongoDB → DocumentDB or Atlas (peered) | DocumentDB has version cliffs — verify against driver |
| Redis → ElastiCache or MemoryDB | rdb dump + restore, or replication-aware tool |
| DynamoDB → DynamoDB | backups + PITR; replicate via Global Tables |

## Cost realism

Cite `references/14-cost-and-budgets.md`. AWS is not cheaper than DigitalOcean / Hetzner at small scale; can be more expensive than Cloudflare for traffic-heavy CDN. Be honest.
