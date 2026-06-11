# Express on AWS

## Paths

| Path | Use when |
|---|---|
| ECS Fargate behind ALB | stateful or long-lived APIs |
| App Runner | easiest container path; autoscaling built in |
| Lambda + API Gateway via `@vendia/serverless-express` | stateless, request/response < 6 MB |

## Hardening

- Helmet for headers (or set them at ALB / CloudFront).
- Express-rate-limit in-app; WAFv2 rate-limit at edge.
- Sessions: NEVER in-memory on multi-instance — ElastiCache or DynamoDB.
- File uploads: presigned URLs to S3; don't proxy through your container.
- Long-running work → SQS + worker.

## Docs

- Express security: https://expressjs.com/en/advanced/best-practice-security.html
- ECS Fargate: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
- App Runner: https://docs.aws.amazon.com/apprunner/latest/dg/what-is-apprunner.html
