# Blog on Fly.io

Like marketing sites: blogs almost always belong on a CDN host (Pages, Netlify, Vercel), NOT Fly. Exception: blogs with logged-in features (paid subscribers, comments with auth, real-time discussion).

## When Fly fits

| Use case | Why |
|---|---|
| Subscriber-only content | Paywalled posts, edge auth. |
| Comment system | Long-lived process for moderation, real-time updates. |
| CMS backend | WordPress, Ghost, Strapi headless serving an API. |
| Server-rendered personalization | Different content for logged-in users. |

For pure RSS / static blog: don't.

## CMS pattern: headless on Fly + static frontend

```
[Static frontend on Pages]          [Fly app — Strapi/Ghost/Payload]
- Pre-rendered posts                - Admin UI
- Build-time fetched from CMS API   - REST/GraphQL API
                                    - Webhook on publish → trigger frontend rebuild
       │                                   │
       └─────── DNS ───────────────────────┘
```

The CMS itself (database-backed) belongs on Fly. The reader-facing site is static.

## Ghost on Fly

```toml
[env]
  NODE_ENV = "production"
  url = "https://blog.example.com"

[http_service]
  internal_port = 2368
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 1   # admin needs warm

  [[http_service.checks]]
    grace_period = "20s"
    interval = "60s"
    path = "/ghost/api/admin/site"

[mounts]
  source = "ghost_content"
  destination = "/var/lib/ghost/content"
  initial_size = "10gb"
  snapshot_retention = 14
```

DB: Ghost MySQL or external (PlanetScale).

## WordPress

Single-region. Volume for `wp-content/`. Or offload media to Tigris with `wp-stateless`.

## Critical hardening

- [ ] Login rate limit on `/wp-login.php` / `/ghost/admin` / `/admin`.
- [ ] 2FA on admin accounts.
- [ ] Disable XML-RPC (WordPress) — common attack vector.
- [ ] CSP: scripts only from CDN + analytics + CMS-bundled assets.
- [ ] Comment spam: Akismet / hCaptcha.
- [ ] Backup: daily volume snapshot; weekly DB export to Tigris.

## CDN

Always Cloudflare or similar in front. Blog content has high cache-hit rate. Cache on posts; bypass on `/admin`, `/preview`.

## Migration

| From | To |
|---|---|
| Medium / Substack | Headless CMS on Fly + static frontend on Pages. |
| WordPress on shared host | WordPress on Fly + Tigris for media (single-region). |
| Ghost(Pro) | Ghost on Fly (export from Ghost(Pro) admin). |
| Static (Hugo / Jekyll / 11ty) | Don't migrate — stay static on Pages. |

## Common mistakes

| Mistake | Cost |
|---|---|
| Static blog on Fly | Wasted money. |
| `wp-content/uploads` on volume + multi-machine | Single-mount volume; deploy fails. |
| No CDN in front | Every visitor hits Fly bandwidth. |
| WordPress xmlrpc.php enabled | Brute-force amplification. |
| Comments stored in app memory | Restart loses everything. |
