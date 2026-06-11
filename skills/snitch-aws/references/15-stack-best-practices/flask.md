# Flask on AWS

## Paths

| Path | Use when |
|---|---|
| Lambda + API Gateway via Mangum or AWS Lambda Web Adapter | small Flask APIs |
| ECS Fargate / App Runner | non-trivial apps |

## Hardening

- `app.config['DEBUG'] = False` in production.
- Flask-Talisman for security headers.
- WAFv2 rate-limit on auth endpoints.
- Secrets via Secrets Manager (boto3 at startup; cache in-process).

## Docs

- Flask deployment: https://flask.palletsprojects.com/en/stable/deploying/
