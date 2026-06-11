# WordPress on Azure

Verdict + caveats: `fit-matrix wordpress`. Docs: `stack-docs wordpress`.

## Landing

- **App Service Managed WordPress on Linux** — Microsoft's official offering. PHP 8.x + MySQL Flexible Server. Single-click via portal or `az webapp create --runtime "PHP|8.2"`.
- **VM + Bitnami AMI** — full control.
- **Container Apps** — Docker WordPress for advanced setups.

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- `wp-admin`, `xmlrpc.php`, `wp-cron.php` IP-allowlisted via App Service IP restrictions OR Front Door custom rule.
- Real cron: disable `wp-cron.php` (`define('DISABLE_WP_CRON', true);`); use App Service WebJob or Container App job.
- `wp-config.php` salts → Key Vault references in App Settings.
- Uploads dir: block PHP execution via `web.config` rewrite or App Service container config.
- Auto-updates: enable plugin + core auto-updates with rollback via slot swap.
- WAF: Front Door Premium custom rules for OWASP Top 10 + WordPress (admin login rate-limit, common exploit paths).

## Anti-patterns

- Don't store secrets in `wp-config.php` plaintext.
- Don't expose MySQL Flexible Server publicly; use VNet integration.
- Don't skip per-plugin update review on prod — plugins are #1 attack surface.

## Skill targets

Same App Service hardening + DB hardening (`fix mysql`).
