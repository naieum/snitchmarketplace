# 11 — API Cheatsheet

Every call: `Authorization: Bearer ${CLOUDFLARE_API_TOKEN}`. Writes: `Content-Type: application/json`. Base: `https://api.cloudflare.com/client/v4`. Docs: https://developers.cloudflare.com/api/

## Token / user

```sh
GET  /user/tokens/verify
GET  /user/tokens
POST /user/tokens                # name, policies, condition.request_ip.in, expires_on, not_before
PUT  /user/tokens/{id}           # status: active|disabled
GET  /user
```

## Account

```sh
GET  /accounts
PUT  /accounts/{id}              # settings.enforce_twofactor: true
GET  /accounts/{id}/audit_logs?since=...&action.type=...
GET  /accounts/{id}/members
POST /accounts/{id}/members
```

## Zone

```sh
GET   /zones                     # ?account.id=...&name=example.com
GET   /zones/{id}
PATCH /zones/{id}                # paused, plan, type
DELETE /zones/{id}
```

## Zone settings

```sh
GET/PATCH /zones/{id}/settings/{key}
```

Keys: `ssl` (`off|flexible|full|strict`), `min_tls_version` (`1.0..1.3`), `tls_1_3`, `always_use_https`, `automatic_https_rewrites`, `opportunistic_encryption`, `security_header` (HSTS — see 02), `security_level` (`off|essentially_off|low|medium|high|under_attack`), `tls_client_auth` (Global AOP), `0rtt`, `ipv6`, `email_obfuscation`, `server_side_exclude`, `hotlink_protection`, `browser_check`, `challenge_ttl`, `privacy_pass`.

## DNSSEC

```sh
GET   /zones/{id}/dnssec
PATCH /zones/{id}/dnssec         # status: active|disabled
```

Active response: `key_tag`, `algorithm`, `digest_type`, `digest`, `digest_algorithm`, `ds`.

## DNS records

```sh
GET    /zones/{id}/dns_records
POST   /zones/{id}/dns_records
PUT    /zones/{id}/dns_records/{id}    # full replace
PATCH  /zones/{id}/dns_records/{id}    # partial
DELETE /zones/{id}/dns_records/{id}
```

A: `{type, name, content, ttl, proxied, comment}`.
CAA: `{type:"CAA", name:"@", data:{flags:0, tag:"issue", value:"letsencrypt.org"}, ttl:1}`.
DMARC: `{type:"TXT", name:"_dmarc", content:"v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"}`.

## Rulesets

```sh
GET /zones/{id}/rulesets
GET /zones/{id}/rulesets/phases/{phase}/entrypoint
PUT /zones/{id}/rulesets/phases/{phase}/entrypoint    # full replace of rules[]
```

Phases: `http_request_firewall_managed`, `http_request_firewall_custom`, `http_ratelimit`, `http_request_transform`, `http_response_headers_transform`, `http_request_redirect`, `http_config_settings`, `http_request_cache_settings`, `http_request_origin`.

Rule: `{expression, action, action_parameters, description}`.

Source: https://developers.cloudflare.com/api/operations/listAccountRulesets

## Firewall / IP Access Rules (legacy; used by `panic`)

```sh
GET    /zones/{id}/firewall/access_rules/rules
POST   /zones/{id}/firewall/access_rules/rules
DELETE /zones/{id}/firewall/access_rules/rules/{id}
```

Body: `{mode, configuration:{target, value}, notes}`. `target`: `ip|ip6|ip_range|country|asn`. `mode`: `block|challenge|whitelist|js_challenge|managed_challenge`.

## Access apps + policies

```sh
GET/POST /accounts/{id}/access/apps
PUT/DELETE /accounts/{id}/access/apps/{app_id}
GET/POST /accounts/{id}/access/apps/{app_id}/policies
PUT  /accounts/{id}/access/apps/{app_id}/policies/{policy_id}
GET  /accounts/{id}/access/identity_providers
GET/POST /accounts/{id}/access/service_tokens     # POST: name, duration
```

App: `{name, domain, type:"self_hosted", session_duration, auto_redirect_to_identity}`.

## Tunnels

```sh
GET/POST /accounts/{id}/cfd_tunnel
GET/PUT  /accounts/{id}/cfd_tunnel/{id}/configurations
GET      /accounts/{id}/cfd_tunnel/{id}/connections
DELETE   /accounts/{id}/cfd_tunnel/{id}
```

Config: `{config:{ingress:[{hostname, service:"http://localhost:3000"}, {service:"http_status:404"}]}}`.

## SSL certs

```sh
GET  /zones/{id}/ssl/certificate_packs
POST /zones/{id}/ssl/certificate_packs/order        # ACM
GET  /zones/{id}/ssl/universal/settings
PATCH /zones/{id}/ssl/universal/settings
POST /certificates                                  # Origin Cert
```

## Notifications

```sh
GET/POST /accounts/{id}/alerting/v3/policies
PUT  /accounts/{id}/alerting/v3/policies/{id}
GET  /accounts/{id}/alerting/v3/destinations/eligible
POST /accounts/{id}/alerting/v3/destinations/webhooks
```

## Workers / KV / D1 / R2 / Hyperdrive

```sh
GET  /accounts/{id}/workers/scripts
GET  /accounts/{id}/workers/scripts/{name}
GET/POST /accounts/{id}/workers/scripts/{name}/subdomain
GET/POST /accounts/{id}/storage/kv/namespaces
GET/POST /accounts/{id}/d1/database
POST /accounts/{id}/d1/database/{db_id}/query      # sql, params
GET/POST /accounts/{id}/r2/buckets
GET/PUT  /accounts/{id}/r2/buckets/{bucket}/cors
GET/POST /accounts/{id}/hyperdrive/configs
```

## Logpush (Enterprise) — `audit logpush`

```sh
GET /accounts/{id}/logpush/jobs
GET /accounts/{id}/logpush/datasets/{dataset}/fields
GET /zones/{id}/logpush/jobs                 # zone datasets: http_requests, firewall_events
```

Job: `{id, dataset, enabled, frequency, filter, destination_conf, last_complete, last_error}`.
A 403/404 on `/accounts/{id}/logpush/jobs` ⇒ not entitled (Enterprise) → `{locked:"enterprise"}`.
Redact `destination_conf` (strip creds) before surfacing.

## DNS settings — `audit dns`

```sh
GET /zones/{id}/dns_settings                 # foundation_dns, multi_provider, secondary_overrides, zone_mode, nameservers, ns_ttl
GET /accounts/{id}/dns_settings              # account-level defaults
```

## AI Gateway — `audit ai-gateway`

```sh
GET /accounts/{id}/ai-gateway/gateways                      # list (empty ⇒ {locked:"not-configured"})
GET /accounts/{id}/ai-gateway/gateways/{gw}/logs           # NEVER surface bodies (PII) — counts/flags only
```

Gateway flags: `collect_logs, log_management, rate_limiting_limit, rate_limiting_technique, authentication, cache_ttl, logpush`.

## GraphQL analytics (POST /graphql)

```graphql
# audit secevents — aggregated firewall/security events
firewallEventsAdaptiveGroups(limit, filter:{datetime_geq,datetime_lt}, orderBy:[count_DESC]) {
  count dimensions { action source ruleId clientCountryName clientRequestHTTPHost }
}
# audit dns — query mix / RCODE distribution
dnsAnalyticsAdaptiveGroups(limit, filter:{datetime_geq,datetime_lt}, orderBy:[count_DESC]) {
  count dimensions { responseCode queryType queryName }
}
# observability fallback — Worker error/subrequest counts (no log bodies)
workersInvocationsAdaptive(limit, filter:{datetime_geq,datetime_lt}) {
  sum { errors subrequests } dimensions { scriptName }
}
```

GraphQL errors arrive **inside a 200 body** → check `.errors | length`. POST path
is `/graphql` (off the same `/client/v4` base via `cf_post`).

## Errors and pagination

Error body: `{success:false, errors:[{code, message}]}`. Codes: `1000` invalid body, `7003` not-found / token can't see, `9106` missing scope, `9999` API rate limit.

List: `?page=N&per_page=50` (max 50–100). Paginate until `result_info.total_pages`.
