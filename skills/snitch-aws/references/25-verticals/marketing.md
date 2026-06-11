# Vertical — Marketing site on AWS

## Architecture

- Static-first: S3 + CloudFront with OAC.
- CMS: any headless (Contentful, Sanity, Strapi-on-EC2). Build → deploy as static.
- Forms: API Gateway → Lambda → SES (email) or SQS → email integration.
- Analytics: CloudFront access logs + Athena, or send to GA / Plausible from client.

## Hardening

- PAB ON; CloudFront Function for security headers.
- WAFv2 with bot-management for high-traffic campaign pages.
- Rate-limit form-submission Lambda; verify hCaptcha / Turnstile in the Lambda.
- Domain via Route 53 with DNSSEC.

## Cost

Marketing sites are mostly egress; CloudFront + S3 is fine. Single-page-app with infrequent deploys → Amplify Hosting saves you build wiring.
