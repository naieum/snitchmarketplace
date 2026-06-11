# Migration to / from Vercel

## To Vercel — fit-matrix verdicts

See `templates/migration-fit-matrix.json`:

| Verdict | Stacks |
|---|---|
| strong | Next.js, Astro, SvelteKit, Remix, Nuxt, SolidStart, Vite SPA, Vue, Hono, static HTML |
| partial | Express, Fastify, NestJS (with adapters); Flask, FastAPI (small APIs); heavy-database apps (with pooler) |
| not-recommended | WordPress (PHP), Laravel (PHP), Rails (Ruby), Django (Python full app), Spring Boot (JVM), .NET, WebSocket-heavy, long-running compute, media-processing-heavy |

For not-recommended, the only Vercel-shaped option: keep the API on its native host and put a Next.js front-end on Vercel that calls it. Don't shoehorn the wrong runtime in.

## Standard migration steps

1. `vercel link` — creates `.vercel/project.json`.
2. `vercel env pull .env.local` — only after the first push.
3. Vercel auto-detects framework; override in dashboard or `vercel.json` if needed.
4. `vercel env add NAME <env> [--sensitive]` per secret. Mark credential-shaped values as Sensitive.
5. Apex + www domain attach: `vercel domains add example.com <project>`, add the verification record.
6. `vercel` → preview URL → smoke test.
7. DNS cutover: lower TTL on apex/www to 60s the day before. Switch to Vercel records. Confirm with `dig`. Re-raise TTL.
8. Keep previous host live for 24-48h. `vercel rollback <prev-url>` if a deploy goes bad.

## Off Vercel — common destinations

| Reason to leave | Best destination |
|---|---|
| Long-running compute | Fly Machines, AWS Lambda+SQS, Modal, Railway |
| WebSockets at scale | Fly, Railway, Pusher/Ably/Liveblocks |
| Multi-region active-active DB | AWS Aurora Global, CockroachDB, Cloudflare D1 (small only) |
| Egress cost | Cloudflare Workers + R2 (zero egress) |
| Compliance (HIPAA, FedRAMP) | AWS GovCloud, Azure Government |
| Need PHP / Ruby / Python full-app | DigitalOcean, Fly, Railway, Render |
| Bandwidth at scale | Self-hosted CDN, Cloudflare, AWS CloudFront |

For each: containerize or use the platform-native deploy → DNS cutover → keep Vercel as warm rollback target until confirmed.

## Portable

- **Code**: any framework that runs on Vercel also runs on Node + a host.
- **Env vars**: `vercel env pull` → `.env` → import wherever.
- **Domains**: NS-managed externally is portable; Vercel-managed NS requires re-delegation.
- **Storage**: KV → Upstash directly (their backend); Postgres → Neon directly; Blob → S3-compatible host (rclone migration).

## Vercel-locked

| Feature | Replacement on exit |
|---|---|
| Image Optimization URL syntax | Drop `next/image` or use `imgproxy` self-hosted |
| Edge middleware location + matcher | Port to target runtime |
| Vercel Cron | System cron, AWS EventBridge, framework scheduler |
| Speed Insights / Web Analytics | Plausible, Fathom, GA, Sentry |

## References

- https://vercel.com/docs/getting-started-with-vercel/import
- https://vercel.com/docs/migrations
