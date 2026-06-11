# Hono on AWS

## Path

**Lambda + API Gateway** (or Lambda Function URL) via Hono's AWS Lambda adapter. Excellent fit — small bundle, fast cold start.

## Hardening

- Function URL `AuthType=AWS_IAM` unless intentionally public; if public, verify HMAC headers in code.
- WAFv2 ACL on API Gateway when public-internet-facing.
- Tree-shake aggressively; bundle size matters.

## Docs

- Hono AWS Lambda: https://hono.dev/getting-started/aws-lambda
