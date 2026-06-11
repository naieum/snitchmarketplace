# Blog / content site

Detection: WordPress / Ghost / Hugo / Jekyll / Eleventy / 11ty / Astro.

## DigitalOcean overlay

| Engine | Path |
|---|---|
| Hugo / Jekyll / Eleventy / Astro static | Spaces + CDN |
| WordPress | See `15-stack-best-practices/wordpress.md`. 1-Click Droplet + Managed MySQL + Spaces for `/uploads` + Cloudflare in front. |
| Ghost | App Platform Ghost preset OR Droplet + Docker + Managed MySQL |

## Hardening

- Spaces bucket holding `/uploads`: public-read on the `public/` prefix via bucket policy, not bucket-level ACL.
- WordPress: comment-spam protection (Akismet), rate-limit login, IP-allowlist `wp-admin`.
- Ghost: admin behind separate path, basic-auth or IP allowlist.
- Static generators: build in CI, push to Spaces, purge CDN. Never build on production server.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | WordPress on Ubuntu Droplet without auto-update |
| 🟡 WARN | WordPress with default `admin` user |
| 🟡 WARN | Spaces bucket with bucket-level public-read for `/uploads` |
| INFO | No CDN endpoint in front of Spaces |
