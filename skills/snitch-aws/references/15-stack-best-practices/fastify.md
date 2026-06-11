# Fastify on AWS

## Paths

Same shape as Express: ECS Fargate / App Runner for non-trivial; Lambda + API Gateway via `@fastify/aws-lambda` for stateless. Fastify's plugin architecture often makes the Lambda port more mechanical.

## Hardening

- `@fastify/helmet` for headers, `@fastify/rate-limit` in-app.
- Streaming uploads: `@fastify/multipart` directly to S3 multipart upload via SDK.
- Schema-validate every request body.

## Docs

- Fastify serverless: https://fastify.dev/docs/latest/Guides/Serverless/
