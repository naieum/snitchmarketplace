# Laravel on AWS

## Paths

| Path | Use when |
|---|---|
| Bref (Laravel on Lambda) | most apps; cold starts manageable |
| ECS Fargate | non-trivial workloads |
| Elastic Beanstalk PHP | older, but works |

## Stack

- RDS / Aurora MySQL/Postgres for DB.
- ElastiCache for sessions/cache when multi-replica.
- SQS for queues (Bref has a Laravel queue worker).
- S3 for `public` filesystem disk.

## Hardening

- `APP_DEBUG=false` in production.
- Rotate `APP_KEY` only when you know what you're doing.
- Env vars → Secrets Manager.
- WAFv2 rate-limit on `/login` and password-reset.

## Docs

- Bref Laravel: https://bref.sh/docs/frameworks/laravel.html
- Laravel deployment: https://laravel.com/docs/deployment
