# Next.js on AWS

Two solid AWS landing zones; pick by team comfort.

| Path | Use when | Build/runtime |
|---|---|---|
| Amplify Hosting | want `git push → live`, no CDK/CFN management | SSR, SSG, ISR, App Router, API routes, image opt; build minutes + bandwidth + SSR compute pricing |
| OpenNext on Lambda + CloudFront | want full control over CloudFront cache + WAF | `npx open-next` or SST's OpenNext; SSR + image opt Lambdas, S3 static, ISR via S3 + DynamoDB |

## Hardening

- Force HTTPS at CloudFront (`ViewerProtocolPolicy=redirect-to-https`).
- WAFv2 ACL: AWS managed core rule set + rate-limit.
- Security headers via CloudFront Function on `viewer-response` (template provided).
- Set `assetPrefix` and `cacheControl` for static assets.
- Sessions: `next/headers` `cookies()` with `httpOnly`, `secure`, `sameSite='lax'`.
- No secrets in `NEXT_PUBLIC_*`; use Secrets Manager at runtime.

## Docs

- Next.js deployment: https://nextjs.org/docs/app/building-your-application/deploying
- Amplify Next.js SSR: https://docs.aws.amazon.com/amplify/latest/userguide/server-side-rendering-amplify.html
- OpenNext: https://opennext.js.org/aws
