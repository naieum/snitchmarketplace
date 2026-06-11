# Django on AWS

## Path

- **ECS Fargate behind ALB** + RDS Postgres + ElastiCache + S3 for media.
- Zappa (Lambda) works for small apps but the 6 MB request/response limit and cold starts are real.

## Hardening

- `DEBUG=False` in production.
- `ALLOWED_HOSTS` set tightly.
- Secrets via Secrets Manager (django-environ + boto3 fetch at startup).
- WAFv2 on ALB; rate-limit `/admin/login` and password-reset endpoints.
- Channels (WebSockets) → API Gateway WebSocket API or ECS with sticky sessions.
- `django-storages` + S3 for media; don't proxy uploads through your container.
- `bandit` for code; `safety` for dep CVEs.

## Docs

- Deployment: https://docs.djangoproject.com/en/stable/howto/deployment/
- Security: https://docs.djangoproject.com/en/stable/topics/security/
