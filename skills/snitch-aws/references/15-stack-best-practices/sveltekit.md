# SvelteKit on AWS

## Paths

| Mode | Path |
|---|---|
| Static | S3 + CloudFront via `adapter-static` |
| SSR | Amplify Hosting or `adapter-aws-sst` (Lambda + CloudFront via SST) |

## Hardening

- Form actions are POST-heavy; cover them in WAFv2 rate-limit rules.
- CSRF: SvelteKit has built-in CSRF for form actions; verify it stays on.
- Cookies: `secure`, `httpOnly`, `sameSite='lax'`.

## Docs

- SvelteKit adapters: https://kit.svelte.dev/docs/adapters
