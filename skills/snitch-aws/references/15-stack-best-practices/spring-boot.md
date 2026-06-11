# Spring Boot on AWS

## Paths

| Path | Use when |
|---|---|
| ECS Fargate behind ALB | non-trivial Spring apps (canonical) |
| Elastic Beanstalk Java / Tomcat | works, older |
| App Runner | simplest container path |
| Lambda + SnapStart | small APIs; SnapStart helps cold starts but isn't free |

## Hardening

- Spring Security with strict CSRF + CORS configs.
- Don't expose `/actuator/*` to internet without auth.
- Application properties → Secrets Manager / SSM SecureString.
- ECR scan-on-push.
- WAFv2 on the ALB.

## Docs

- Spring Boot deployment: https://docs.spring.io/spring-boot/docs/current/reference/html/deployment.html
- Lambda SnapStart: https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html
