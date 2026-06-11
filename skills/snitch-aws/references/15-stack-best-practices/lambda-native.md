# Lambda-native services

Already on Lambda — focus is hardening, not migration.

## Hardening

- Execution role: least-privilege; no `*:*`. Use Access Analyzer for scoped policy suggestions.
- Env vars never hold secrets — Secrets Manager (cached in-process) or SSM SecureString.
- Function URL `AuthType=AWS_IAM` (or behind API Gateway with WAF + authorizer).
- Code signing for production (AWS Signer).
- DLQ on async invocations.
- VPC config only when you need RDS / ElastiCache (cold-start cost).
- `reservedConcurrentExecutions` to bound blast radius.
- Layers: pin specific versions; review the publisher.

## Observability

- CloudWatch alarms: per-function `Errors` + `Throttles`.
- X-Ray tracing for the request graph.
- Structured logs with correlation IDs.

## Docs

- Lambda security: https://docs.aws.amazon.com/lambda/latest/dg/lambda-security.html
