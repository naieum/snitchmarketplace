# 34 — DNS analytics & DNS settings posture

Tool: `audit dns [zone] [window]` → `cfsec.audit-dns` = `{settings, analytics}`.
DNSSEC is **not** here — it stays in `state zone` (don't duplicate). This lens is
about query-mix anomalies and DNS resilience posture.

## DNS settings (REST `/zones/{id}/dns_settings`)

Fields surfaced (bare values — `false` is preserved, not collapsed to null):
- `foundation_dns` — advanced/anycast DNS (Enterprise). Available-but-off → **INFO**.
- `multi_provider` / `secondary_overrides` — multi-provider / secondary DNS resilience.
- `zone_mode`, `nameservers`, `ns_ttl`.

Grade:
- `multi_provider:false` and no secondary DNS on a high-availability property → **INFO** (single-provider resilience risk).
- Foundation DNS available but disabled on Enterprise → **INFO**.

## DNS analytics (GraphQL `dnsAnalyticsAdaptiveGroups`)

Emits `analytics`: `total_queries`, `by_response_code[]` (DNS RCODE), derived
`nxdomain_rate` / `servfail_rate`, `by_query_type[]`, `top_query_names[]`. If the
token lacks Analytics scope, `analytics:null` + `analytics_error:"graphql-unavailable"`
(settings still emitted).

RCODE reference: `0`=NOERROR, `2`=SERVFAIL, `3`=NXDOMAIN, `5`=REFUSED.

Grade:
- `nxdomain_rate` > ~15% → **WARN** — possible subdomain enumeration or dangling
  references; cross-check `27-takeover-cookie-probe.md` (takeover scan) and prune
  stale records.
- `servfail_rate` spikes → **WARN** (resolution failures / misconfig / DNSSEC chain issue).
- Unusual `by_query_type` (e.g. heavy `TXT`/`ANY`, or `NULL`) → **INFO** (possible
  tunneling/exfil reconnaissance — correlate with `audit secevents`).
- A `top_query_names` entry for a hostname with no live record → cross-link
  takeover scan.

Cross-refs: `02-dns-ssl-tls.md` (DNSSEC, records), `27-takeover-cookie-probe.md`
(dangling/takeover), `33-logging-observability.md` (`dns_logs` Logpush).
