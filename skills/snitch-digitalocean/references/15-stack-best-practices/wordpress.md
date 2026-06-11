# WordPress on DigitalOcean

Verdict: `fit-matrix wordpress`. Docs: `stack-docs wordpress`.

## Landing

| Option | Detail |
|---|---|
| 1-Click WordPress Droplet + Managed MySQL | LAMP pre-configured |
| App Platform with WordPress preset | Managed runtime |
| DOKS + WordPress chart | Overkill for most |

## Hardening

- `wp-admin`, `xmlrpc.php`, `wp-cron.php` IP-allowlisted via Cloud Firewall (or HTTP basic-auth via nginx).
- `define('DISALLOW_FILE_EDIT', true);` in `wp-config.php`.
- `define('FORCE_SSL_ADMIN', true);`.
- Unique salts in `wp-config.php` (regen at https://api.wordpress.org/secret-key/1.1/salt/).
- DB user limited to the WP DB (no `GRANT ALL`).
- Plugin / theme audit: only wordpress.org or trusted vendors. Auto-update enabled.
- Spaces for uploads via WP Offload Media → Spaces CDN.
- Backups at two levels: Droplet snapshots + DB dump to Spaces.
- WAF: Cloudflare in front (DO has no L7 WAF; WordPress is the most-attacked CMS).

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | `xmlrpc.php` reachable from internet |
| 🔴 FAIL | File editing not disabled |
| 🔴 FAIL | DB user has GRANT ALL |
| 🟡 WARN | Admin user named `admin` |
| 🟡 WARN | No 2FA plugin |
| INFO | Default `wp_` table prefix |
