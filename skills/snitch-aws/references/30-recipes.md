# Recipes — when the user asks X, do Y

The agent synthesizes; shell tools provide facts.

## Audit / harden an AWS account

Default to digest mode. Run in parallel (single message, multiple Bash calls):

```
bash snitch-aws.sh doctor
bash snitch-aws.sh detect
bash snitch-aws.sh state account digest
bash snitch-aws.sh state iam digest
bash snitch-aws.sh state s3 digest
bash snitch-aws.sh state cloudtrail digest
bash snitch-aws.sh state guardduty digest
bash snitch-aws.sh state securityhub digest
bash snitch-aws.sh state config digest
```

Add EC2 / VPC / RDS / Lambda / KMS digests if those services are in scope (use `detect`).

Then:

1. Compare observed `state.<area>.<summary>` to policy in `references/<area>.md`.
2. Render findings table (see "Report format" below). Mark items locked by Support tier with `[locked: <tier>+]` from `references/10-plan-tier-matrix.md`.
3. Fetch a slice only when the digest signals you should: `bash snitch-aws.sh state s3 buckets` if `with_full_pab` is below `total`; `bash snitch-aws.sh state iam users` if `users_summary.stale_passwords_90d > 0`.
4. Ask which areas to fix. For each: `bash snitch-aws.sh fix <area>`. After: `bash snitch-aws.sh verify` for the delta.

## "Should I migrate to AWS?"

Offline — no AWS creds required.

```
bash snitch-aws.sh detect
bash snitch-aws.sh fit-matrix <stack>
bash snitch-aws.sh stack-docs <stack>
```

`WebFetch` each URL from `stack-docs`. Render with the verdict at the top:

| Verdict | Action |
|---|---|
| `strong` | render the AWS-native landing zone (Lambda + API GW, S3 + CloudFront, ECS Fargate, App Runner) with DNS cutover plan |
| `partial` | render the plan, flag every `entry.dependencies_to_flag` and `entry.caveats` |
| `proxy-only` | rare for AWS — "use CloudFront in front of an existing origin" |
| `not-recommended` | suggest a better-fit provider |

Database honesty: MySQL → RDS / Aurora MySQL Serverless v2. Postgres → RDS / Aurora Postgres. Mongo → DocumentDB IF version-compatible, else Atlas peered to your VPC. Redis → ElastiCache / MemoryDB.

End with cost realism (cite `references/14-cost-and-budgets.md`), DNS cutover steps (lower TTL → switch → verify), rollback path.

## "What should I have at 10k users?" / scaling readiness

```
bash snitch-aws.sh state account
bash snitch-aws.sh detect
bash snitch-aws.sh analytics 30d
bash snitch-aws.sh state cost
```

Read `references/14-cost-and-budgets.md`. If Aurora Serverless v2 + Fargate + CloudFront comes out more expensive than the user's current host at their scale, say so.

## Diagnose

Classify the symptom yourself, then pick tools:

| Symptom | Tools | Reasoning |
|---|---|---|
| slow / latency | `state cloudfront` + CloudWatch metrics | cache hit rate, edge regions |
| 500s / errors | `state lambda` + `events 1h` | recent IAM changes, role permission deltas |
| bill spike | `analytics 7d` vs `analytics 30d` | identify the cliff |
| public S3 bucket | `state s3` digest | `account_public_access_block` + per-bucket `with_full_pab` |
| compromised key | `events 24h` | filter EventName=CreateAccessKey, AssumeRole |
| under attack | `events 1h` → `panic block-ip <ip>` | confirm before mutating |

## "We're under attack right now"

```
bash snitch-aws.sh events 1h
bash snitch-aws.sh panic block-ip <ip-or-cidr>   # creates IPSet; user must associate to ACL
bash snitch-aws.sh panic revoke-key <AKIA...>    # deactivate compromised key
bash snitch-aws.sh panic restore                 # rolls back every recorded panic action
```

Postmortem: read `references/13-incident-response.md`. Help write the timeline.

---

## Report format — MUST be followed for every audit / migrate / roadmap / scaling output

Every report:

1. Open with a one-line verdict.
2. Body sections use markdown tables only — no prose paragraphs between sections except a single transitional sentence.
3. Close with "Next steps" — at most 3 bullets, each imperative.

Status badges: `🔴 FAIL`, `🟡 WARN`, `⚪️ N/A` (locked), `🟢 OK`. Sort: 🔴 → 🟡 → ⚪️ → 🟢.

### Findings table — exact columns

```markdown
| Status | Area | Finding | Remediation |
|---|---|---|---|
| 🔴 FAIL | s3 | Bucket `my-data` has no Public Access Block | `aws s3api put-public-access-block …` (run `fix s3`) |
| 🟡 WARN | iam | Access key `AKIA…` is 187 days old | Rotate or delete |
| ⚪️ N/A | trusted-advisor | Full Trusted Advisor security checks gated behind Business+ | Upgrade Support plan |
| 🟢 OK | cloudtrail | Multi-region trail with KMS + log-file-validation | — |
```

### Architecture inventory table — exact columns

```markdown
| Component | Detail | Source |
|---|---|---|
| Compute | acme-api on Fargate (3 tasks) | us-east-1, vpc-abc, sg-xyz |
| DB | aurora-postgres-prod (Serverless v2, 0.5-4 ACU) | us-east-1a/b |
| Storage | acme-uploads (S3 + CloudFront OAC) | account-wide PAB ON |
```

### Cost / scaling table — exact columns

```markdown
| Driver | Current | Watch for |
|---|---|---|
| NAT egress | $124/mo | spike if VPC endpoints removed |
| CloudWatch ingest | $48/mo | unexpired log groups |
```

### Migration verdict table — exact columns

```markdown
| Stack detected | Verdict | Recommended path |
|---|---|---|
| nextjs | 🟢 strong | Amplify Hosting OR OpenNext + Lambda + CloudFront |
| rails | 🟡 partial | ECS Fargate + Aurora Postgres + ElastiCache |
```

### Why tables

Scannable for severity, copy-pasteable into a ticket, brevity-forcing, renders in terminal + markdown viewers.

## Common mistakes

- Don't run `bash snitch-aws.sh check / migrate / roadmap / report / diagnose / stacks` — deprecated, exit 64.
- Don't pre-load all of `references/`. Read only what's relevant.
- Don't suggest DocumentDB as a drop-in for the latest MongoDB. Verify the version cliff.
- Don't mutate AWS under a read flow. Mutations are explicit: `fix <area>` or `panic <action>`, both with user confirmation.
- Don't write inside the user's project directory. Project-side fixes emit proposed contents + diff to stdout; apply via `Edit` / `Write`.
