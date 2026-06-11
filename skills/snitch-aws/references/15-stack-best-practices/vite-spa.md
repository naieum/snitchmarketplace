# Vite SPA on AWS

## Path

- **S3 + CloudFront**. Pure static.
- Use OAC (not OAI).
- Configure CloudFront to redirect `404` → `/index.html` for client-side routing.

## Hardening

- PAB ON; CloudFront accesses S3 via OAC.
- Security headers via CloudFront Function (template).
- WAFv2 with rate-limit if you have any auth flow that hits an API behind the SPA.

## Docs

- Vite static deploy: https://vitejs.dev/guide/static-deploy.html
