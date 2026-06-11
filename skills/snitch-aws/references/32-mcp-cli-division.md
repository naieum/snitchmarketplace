# 32 — MCP / CLI division of labor

The skill is built around AWS CLI v2 as primary. Everything works without an MCP. If an AWS-flavored MCP is loaded, reach for it first for typed inventory reads.

## MCP detection

Set `AWSSEC_MCP_PRESENT=1` if the agent has loaded an AWS MCP server. `doctor` reports presence; otherwise the skill behaves identically.

## When to use the MCP

| Operation | MCP advantage |
|---|---|
| List S3 buckets | typed objects, no jq parsing |
| List Lambda functions | same |
| List DynamoDB tables | same |
| List RDS instances | same |
| Search AWS docs | curated chunks, faster than WebFetch |

## When to use this skill

- **Digest views** — combine many CLI calls and compute risk signals (`with_full_pab`, `imdsv2_required`, `customer_keys_without_rotation`). The MCP returns raw lists; the skill computes the rollup.
- **Mutating actions**: `fix <area>`, `panic <action>` — read-first, idempotent, recorded.
- **Offline tools**: `detect`, `fit-matrix`, `stack-docs`, `score`. No AWS calls; no MCP needed.

## When to use raw `aws` CLI

When you know the exact command and don't need a digest:

- `aws iam create-policy …` for a custom policy.
- `aws cloudtrail update-trail …` to flip a single flag.
- `aws ec2 describe-instances --filters Name=tag:Owner,Values=team-x` for precise filtering.

`aws_run` / `aws_run_json` are wrappers for libs, not direct use.

## What the skill never does

- Replace AWS CLI for advanced filtering (use `--filters`, `--query`, paginate flags).
- Hide errors. CLI failures emit error JSON to stderr; skill continues with partial data.
- Cache aggressively. Snapshot for verify, 1h for SSL Labs; fresh reads default.
