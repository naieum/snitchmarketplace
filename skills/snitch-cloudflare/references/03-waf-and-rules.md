# 03 — WAF and Rules Engine

## Plan-tier matrix

| Feature | Free | Pro | Business | Enterprise |
|---|---|---|---|---|
| Free Managed Ruleset | yes | replaced | replaced | replaced |
| Cloudflare Managed | no | yes | yes | yes |
| OWASP Core Ruleset | no | yes | yes | yes |
| Custom rules count | 5 | 20 | 100 | 1000 |
| Regex in custom rules | no | no | yes | yes |
| Payload logging | no | no | yes | yes |
| `log` action | no | yes | yes | yes |
| Account-level WAF | no | no | no | yes |
| Exposed-credentials check | no | yes | yes | yes |
| Sensitive-data DLP | no | no | yes | yes |
| API Shield | no | no | partial | yes |
| Bot Management (ML) | no | no | no | yes |

Source: https://www.cloudflare.com/plans/

## Managed rulesets

`PUT /zones/{id}/rulesets/phases/http_request_firewall_managed/entrypoint`.

| Ruleset | Plan | Notes |
|---|---|---|
| Free Managed | Free | skill ensures deployed |
| Cloudflare Managed | Pro+ | wider coverage; default `block`; override per-rule to `log` if FPs |
| OWASP Core | Pro+ | anomaly-scoring; default sensitivity `medium`, action `managed_challenge` for 7-day soak then `block` |

Sources: https://developers.cloudflare.com/waf/managed-rules/free-managed-ruleset/ , https://developers.cloudflare.com/waf/managed-rules/reference/cloudflare-managed-ruleset/ , https://developers.cloudflare.com/waf/managed-rules/reference/owasp-core-ruleset/

## Custom Rules budget on Free (5 rules)

1. `block-foreign-tech-paths` — combined OR of foreign path prefixes + extensions per stack.
2. `block-secret-and-scm-leaks` — universal: `.env`, `.git`, `.aws`, etc.
3. RL slot (handed to Rate Limiting Rules where possible).
4. `block-admin-from-foreign-geo` (opt-in).
5. One slot left free for the user.

Pro+ splits into more granular rules + adds OWASP CRS.

Source: https://developers.cloudflare.com/waf/custom-rules/

## Phase order

`http_config_settings` → `http_request_redirect` → `http_request_transform` → `http_request_firewall_custom` → `http_request_firewall_managed` → `http_ratelimit` → `http_request_cache_settings` → `http_request_origin` → `http_response_headers_transform` → `http_response_firewall_managed` (DLP, Biz+).

See `24-decision-trees.md`.

Source: https://developers.cloudflare.com/ruleset-engine/about/phases/

## Foreign-tech blocking expression

Built from `templates/waf-stack-profiles.json`. Action `block`, description `cloudflare-secure:block-foreign-tech-paths`. Free-tier compatible (`matches` regex requires Business+):

```
(starts_with(http.request.uri.path, "/wp-admin")) or
(starts_with(http.request.uri.path, "/wp-login.php")) or
(starts_with(http.request.uri.path, "/wp-content/")) or
(starts_with(http.request.uri.path, "/wp-includes/")) or
(http.request.uri.path eq "/xmlrpc.php") or
(starts_with(http.request.uri.path, "/phpmyadmin")) or
(ends_with(http.request.uri.path, ".php")) or
(ends_with(http.request.uri.path, ".asp")) or
(ends_with(http.request.uri.path, ".aspx")) or
(ends_with(http.request.uri.path, ".jsp"))
```

Universal SCM + secret-leak guard:

```
(starts_with(http.request.uri.path, "/.git/")) or
(starts_with(http.request.uri.path, "/.svn/")) or
(http.request.uri.path eq "/.env") or
(starts_with(http.request.uri.path, "/.env.")) or
(starts_with(http.request.uri.path, "/.aws/")) or
(http.request.uri.path eq "/Dockerfile") or
(ends_with(http.request.uri.path, ".bak")) or
(ends_with(http.request.uri.path, ".sql"))
```

Country block on admin (opt-in):

```
(starts_with(http.request.uri.path, "/admin/")) and
(ip.geoip.country in {"CN" "RU" "KP" "IR"})
```

Sources: https://developers.cloudflare.com/ruleset-engine/rules-language/ , https://developers.cloudflare.com/ruleset-engine/rules-language/fields/

## Rule actions

| Action | Plan | Behavior |
|---|---|---|
| `block` | All | 403 (configurable) |
| `managed_challenge` | All | CF picks (usually invisible) — preferred over `challenge` |
| `js_challenge` | All | JS interstitial |
| `log` | Pro+ | logs match (soak testing) |
| `skip` | All | skip downstream phases (allowlists) |
| `redirect` | Redirect phase | 301/302/307/308 |

Source: https://developers.cloudflare.com/waf/custom-rules/create-dashboard/

## Idempotency

`fix waf` reads existing rules, hashes the proposed expression set; updates only if hash differs. Tag `description` (`cloudflare-secure:<rule-name>`) so re-runs find + update the same rule.

API: `GET/PUT /zones/{id}/rulesets/phases/http_request_firewall_custom/entrypoint`. Body: `{"rules":[{action, expression, description}]}`.
