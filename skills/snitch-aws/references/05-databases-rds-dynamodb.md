# 05 — Databases (RDS, Aurora, DynamoDB, ElastiCache)

## RDS / Aurora targets

| Target | Value |
|---|---|
| `StorageEncrypted` | true (settable only at create-time; restore-from-snapshot to encrypt existing) |
| `PubliclyAccessible` | false |
| TLS to engine | Postgres `rds.force_ssl=1`; MySQL `require_secure_transport=ON` (param group + reboot) |
| Automated backups | retention >=7d; >=35d for production |
| Deletion protection | enabled |
| IAM authentication | for Postgres / MySQL / Aurora |
| Audit logs | `enable_cloudwatch_logs_exports` to CloudWatch |
| Performance Insights | production tier |
| Multi-AZ | production tier |

## DynamoDB targets

| Target | Value |
|---|---|
| PITR | ON for production tables |
| KMS encryption | customer-managed key when sensitive |
| Deletion protection | ON for production |

## ElastiCache (Redis) targets

| Target | Value |
|---|---|
| `TransitEncryptionEnabled` + `AtRestEncryptionEnabled` | true |
| AUTH | token set, or RBAC for Redis 6+ |
| Subnet group | private subnets only |

## Skill checks

- `state rds` digest: total instances, encrypted vs unencrypted, publicly-accessible, IAM-auth, deletion-protection, backup-retention=0, engine breakdown.
- `state dynamodb` digest: total, with-PITR, with-KMS, with-deletion-protection.
- `apply rds` enables deletion-protection where missing; warns on retention <7d; warns (cannot auto-fix) on unencrypted storage and public accessibility.

## Migration realities

- Self-hosted Postgres → RDS / Aurora Postgres: pg_dump or DMS for live cutover.
- Self-hosted MySQL → RDS / Aurora MySQL Serverless v2: mysqldump or DMS.
- DynamoDB → relational: rewrite. Data model isn't compatible.

## Docs

- RDS best practices: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
- DynamoDB security: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/security.html
- ElastiCache encryption: https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/encryption.html
