# NestJS on AWS

## Paths

| Path | Use when |
|---|---|
| ECS Fargate behind ALB | canonical — cold-start cost on Lambda is real for NestJS's DI graph |
| App Runner | simplest container path |
| Lambda + API Gateway via `@vendia/serverless-express` | works; consider Provisioned Concurrency for cold starts |

## Hardening

- Don't use `@nestjs/microservices` TCP/Redis transports on AWS — replace with SQS/SNS/EventBridge.
- TypeORM / Sequelize: RDS Proxy on Lambda to avoid connection storms.
- Sessions: shared store (ElastiCache / DynamoDB) when multi-replica.
- Helmet + class-validator for headers and DTO validation.

## Docs

- NestJS serverless: https://docs.nestjs.com/faq/serverless
