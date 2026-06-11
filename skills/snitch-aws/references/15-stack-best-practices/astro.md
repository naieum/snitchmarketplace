# Astro on AWS

## Paths

| Mode | Path |
|---|---|
| Static | S3 + CloudFront. Drop `dist/` |
| SSR / hybrid | Amplify Hosting (built-in Astro support) or `@astrojs/aws-lambda` adapter on Lambda + CloudFront |

## Hardening

- WAFv2 + security-headers CloudFront Function (template).
- Image optimization with `sharp` requires a Lambda layer or container image (bundled binary > 250 MB).

## Docs

- Astro AWS adapter: https://docs.astro.build/en/guides/integrations-guide/aws/
- Amplify Hosting: https://docs.aws.amazon.com/amplify/latest/userguide/welcome.html
