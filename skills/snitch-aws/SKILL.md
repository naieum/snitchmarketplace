---
name: snitch-aws
description: AWS security + readiness skill. Thin tools for the agent to compose. Detects the user's project, audits account/IAM/S3/EC2/VPC/RDS/Lambda/CloudFront/Route53/CloudTrail/GuardDuty/SecurityHub/Config/KMS posture across services, applies idempotent hardening, and produces honest migration / scaling guidance. Triggers on audit my AWS account, harden AWS, AWS security audit, secure my AWS infrastructure, AWS WAF setup, AWS IAM audit, AWS scaling readiness, AWS incident response, AWS best practices, AWS hardening, should I move to AWS, migrate to AWS, AWS DNSSEC, AWS S3 public bucket, AWS CloudTrail audit, AWS GuardDuty.
---

# snitch-aws

You orchestrate. `~/.claude/skills/snitch-aws/snitch-aws.sh` exposes thin tools — read-only data tools emit JSON; mutating tools (`fix`, `panic`) are explicit and idempotent. **You synthesize:** classify intent, prioritize findings, render prose. Run `bash ~/.claude/skills/snitch-aws/snitch-aws.sh help` for the surface.

## Setup

- AWS credentials. **Preferred:** SSO profiles (`aws configure sso`) or assumed roles. **Refused** when `AWS_ACCESS_KEY_ID` starts with `AKIA*` and an SSO profile exists in `~/.aws/config`. **Hard-refused:** no creds.
- `aws` CLI v2. `jq` required for parsing. `doctor` flags missing.
- Optional: AWS-flavored MCP — export `AWSSEC_MCP_PRESENT=1` to prefer it for inventory reads.

## Tool inventory

Read-only (JSON on stdout, errors as JSON on stderr):

| Subcommand | Returns |
|---|---|
| `doctor` | env health (aws cli, jq, profile, sts caller, MCP) |
| `detect` | cwd signals: stacks, databases, storage, IaC, AI providers, hostnames, project_kind |
| `state <area> [slice]` | per-area state JSON; `digest` is the default |
| `analytics` | account-level signals: untagged spend, top services 30d, region distribution |
| `events` | last 100 IAM-significant CloudTrail events |
| `fit-matrix [stack]` | migration verdict + caveats (AWS-native landing options) |
| `stack-docs [stack]` | canonical doc URLs to `WebFetch` |
| `score [host...]` | SSL Labs / Mozilla Observatory / securityheaders / hsts-preload grades |

**`state` subscopes** (digest by default):

`account, iam, s3, ec2, vpc, rds, dynamodb, lambda, cloudfront, route53, acm, cognito, secrets, cloudtrail, cloudwatch, wafv2, shield, config, inspector, macie, guardduty, securityhub, backup, kms, organizations, eks, ecs, eventbridge, sqs-sns, cost`.

Each digest emits a summary (counts + key risk signals). Slice values vary per subscope — see per-area headers for the `valid` set.

Mutating (idempotent):

| Subcommand | Behavior |
|---|---|
| `fix <area> [args]` | apply hardening for one area; safe to re-run. Areas: `iam s3 ec2 vpc rds lambda cloudfront cloudtrail kms secrets wafv2 guardduty securityhub backup account all` |
| `panic <action> [args]` | incident: `revoke-key <id>`, `quarantine-role <arn>`, `block-ip <ip>`, `restore`. Confirm with user before invoking. |

Utility: `export`, `terraform`, `verify`, `refresh-docs`, `help`.

Removed (print deprecation + exit 64): `check`, `migrate`, `roadmap`, `report`, `diagnose`, `stacks`. Compose primitives — see `references/30-recipes.md`.

## CLI vs MCP vs skill — division of labor

The AWS CLI is the **primary** tool. Drive it via the skill's `aws_run` wrapper.

| Operation | AWS service / API |
|---|---|
| Account / SCP / Org | `organizations`, `iam` |
| Identity inventory | `iam list-users / list-roles / list-policies / list-access-keys`, `accessanalyzer list-findings` |
| S3 reads | `s3api get-public-access-block / get-bucket-policy / get-bucket-encryption / get-bucket-versioning / get-bucket-logging` |
| EC2 + VPC | `ec2 describe-instances / describe-volumes / describe-security-groups / describe-vpcs / describe-flow-logs` |
| Data services | `rds`, `dynamodb`, `elasticache`, `dax` |
| Edge + DNS | `cloudfront list-distributions`, `route53 list-hosted-zones`, `acm list-certificates`, `wafv2 list-web-acls` |
| Detective | `cloudtrail describe-trails`, `config describe-configuration-recorders`, `guardduty list-detectors`, `securityhub get-enabled-standards`, `inspector2`, `macie2` |
| Secrets / keys | `secretsmanager list-secrets`, `kms list-keys / get-key-rotation-status` |
| Containers | `eks list-clusters`, `ecs list-clusters` |
| Lambda | `lambda list-functions / get-function-configuration / get-function-url-config` |
| Cost | `ce get-cost-and-usage`, `budgets describe-budgets`, `ce get-anomalies` |

**Use an AWS MCP** (if `AWSSEC_MCP_PRESENT=1`) for typed inventory reads (S3, DynamoDB, Lambda, RDS lists). Fall back to `aws_run` otherwise.

**Use this skill** for: digest views (counts + derived risk signals from many CLI calls), mutating actions (`fix`, `panic` — read-first, idempotent, recorded), offline tools (`detect`, `fit-matrix`, `stack-docs`, `score`).

If neither CLI nor MCP is available, the skill cannot operate. `doctor` is the pre-flight.

## Orchestration

For any AWS request:

1. **Classify intent** yourself (audit, migrate, scale-plan, diagnose, incident).
2. **Call the smallest set of tools** that gives you what you need. Start with `state account` + `state iam` + `state s3` digests in parallel; add `state cloudtrail`, `state guardduty`, `state securityhub`, `state config` for an audit. Run independent calls in parallel (single message, multiple Bash calls).
3. **Lazy-load references** that match findings. Read `references/30-recipes.md` for orchestration detail. Read `references/<NN>-<area>.md` when an area surfaces an issue. Read `references/15-stack-best-practices/<stack>.md` for stack-tailored guidance.
4. **Synthesize the report.** Group findings by area; mark `OK / WARN / FAIL`; surface paid-only items as `[locked: <tier>+]` with one-line value statements (from `references/10-plan-tier-matrix.md`).
5. **For project file changes** (`fix project`, `fix gha`), the tool emits proposed contents + unified diff to stdout:

   ```
   === FILE: <relative-path> ===
   === DIFF ===
   <unified diff>
   === CONTENT ===
   <full proposed file body>
   === END ===
   ```

   Apply with `Edit` or `Write` after user confirms. The skill never writes inside the user's project. For Lambda secret values, the tool emits `aws secretsmanager create-secret` invocations — never type secret values yourself.

## Recipes

Canonical recipes live in `references/30-recipes.md`. Read it for any specific recipe (audit, migrate, scaling, diagnose, attack response). Recipes assume the digest-by-default contract above.

## Guardrails

- **Refuses** when `AWS_ACCESS_KEY_ID` starts with `AKIA` and at least one SSO profile exists in `~/.aws/config`. Redirect: `AWS_PROFILE=<sso-profile> aws sso login`.
- **Hard-refuses** when no AWS credentials are visible (env, profile, instance role). `doctor` prints remediation.
- `fix` is idempotent — no-op when state matches target. Each `*_fix` reads first, compares, mutates only on drift.
- `panic` records each action to `.state/panic-<ts>.json`; `panic restore` rolls back.
- Honest verdicts: PHP/Rails/Django stacks usually get `partial` or `proxy-only` — surface that first.
- The skill **never** lowers posture on `*_fix` (never opens a Public Access Block, never decreases CloudTrail multi-region coverage).
