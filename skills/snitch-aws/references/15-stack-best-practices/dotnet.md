# .NET on AWS

## Paths

| Path | Use when |
|---|---|
| ECS Fargate / App Runner with AWS .NET base image | most apps |
| Elastic Beanstalk .NET | works |
| Lambda via Lambda Annotations Framework | supported and stable |

## Hardening

- ASP.NET Core data-protection keys: store in S3 + KMS, not local disk (multi-instance breaks otherwise).
- Configuration via `appsettings.json` env-overlays + Secrets Manager.
- WAFv2 on ALB / CloudFront.
- ECR scan-on-push.

## Docs

- ASP.NET Core security: https://learn.microsoft.com/en-us/aspnet/core/security/
- Lambda .NET: https://docs.aws.amazon.com/lambda/latest/dg/lambda-csharp.html
