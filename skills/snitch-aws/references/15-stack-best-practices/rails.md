# Rails on AWS

## Path

- **ECS Fargate behind ALB** + Aurora Postgres + ElastiCache + S3 (ActiveStorage).
- Elastic Beanstalk Ruby works but is older and harder to customize.
- Lambda is rarely the right call (boot time, ActiveRecord connection model).

## Hardening

- ALB sticky sessions for ActionCable, OR API Gateway WebSocket API.
- ActiveJob → SQS adapter (good_job + Aurora; or shoryuken + SQS).
- Rotate `secret_key_base` carefully.
- Brakeman + bundler-audit in CI.
- WAFv2 on ALB with rate-limit on `/login` and `/sign_up`.
- `config.force_ssl = true`.

## Database

- pgBouncer in transaction-pooling mode if on Lambda; Fargate is the better fit.
- Aurora Postgres Serverless v2 for bursty traffic.

## Docs

- Rails security: https://guides.rubyonrails.org/security.html
