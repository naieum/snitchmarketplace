# 08 — Secrets and KMS

## Targets

| Target | Value |
|---|---|
| Credentials with rotation | Secrets Manager |
| Config-style secrets | SSM Parameter Store SecureString |
| Sensitive resource encryption | customer-managed KMS keys (CMK), not AWS-managed defaults |
| Annual key rotation | ON for every customer-managed symmetric key |
| Key policy | scope grants to specific roles; never `kms:*` to account root unless needed |
| Lambda env vars | no secrets — reference Secrets Manager at runtime |
| IaC source files | reference, never paste secrets |

## Skill checks

- `state secrets` digest: Secrets Manager total, with-rotation, with-KMS; SSM SecureString count.
- `state kms` digest: total keys, customer-managed, AWS-managed, with-rotation-enabled, customer-keys-without-rotation.
- `apply kms` enables annual rotation on every customer-managed symmetric key with rotation off (idempotent).
- `apply secrets` flags secrets without rotation and secrets using the default KMS key.

## Rotation strategies

| Secret type | Approach |
|---|---|
| RDS-style | AWS-provided rotation Lambda; rotate every 30 days |
| API tokens | small rotation Lambda or manual rotate + push |
| RDS master via Secrets Manager | tie via `aws rds modify-db-instance --master-user-secret-kms-key-id` |

## Cross-account access

- KMS: key policy + grants; never share via `*` principal.
- Secrets Manager: resource policy for cross-account read; rotate consumer's IAM role grant carefully.

## Docs

- Secrets Manager: https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html
- KMS best practices: https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html
- KMS rotation: https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html
