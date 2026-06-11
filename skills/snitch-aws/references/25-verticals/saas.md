# Vertical — Multi-tenant SaaS on AWS

## Architecture

- Multi-tenant DB: shared schema with tenant_id, schema-per-tenant (Postgres), or separate-database-per-tenant — pick by isolation requirement.
- Auth: Cognito User Pools (with Identity Pools for AWS-resource access), or Auth0 / Clerk.
- Per-tenant data partitions in S3 with prefix-based access controls; separate buckets for high-isolation tiers.
- Background jobs: SQS + Lambda or Fargate workers.

## Hardening

- WAFv2 with rate-limit per tenant API key (custom rule).
- CloudTrail org trail across accounts (one account per environment minimum).
- Data isolation tests in CI: try to read tenant B's row as tenant A.
- Per-tenant audit logs to a per-tenant log group (tenant-tagged for cost allocation).
- KMS key per tenant for high-isolation customers (Enterprise tier feature).

## Compliance

| Standard | Building blocks |
|---|---|
| SOC 2 | GuardDuty + Security Hub + CloudTrail + Config + KMS + access reviews |
| HIPAA | BAA with AWS; restrict to HIPAA-eligible services |
| GDPR | data residency via region selection + DSR tooling |
