# Remix on AWS

## Paths

| Path | Use when |
|---|---|
| Lambda + CloudFront via Remix Architect template | typical Remix apps |
| Amplify Hosting | prefer a managed flow |
| App Runner | want full Node container without Lambda's 15-min / 6 MB limits |

## Hardening

- Loaders/actions: rate-limit POST endpoints in WAFv2.
- Long-running side-effects: SQS + worker Lambda or Step Functions; not the request path.
- Sessions: cookie-based with `httpOnly` + `secure` + `sameSite='lax'`. Server-side store in DynamoDB or ElastiCache.

## Docs

- Remix templates: https://remix.run/docs/en/main/start/quickstart
