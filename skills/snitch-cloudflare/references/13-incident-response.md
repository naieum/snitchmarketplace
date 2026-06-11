# 13 — Incident Response

`snitch-cloudflare.sh panic` actions, when to use, recovery.

## When to invoke

- Active L7 attack (429/5xx spike, sudden colo cache miss spike, WAF block-rate spike).
- Single attacker IP / ASN / country.
- Account compromise suspected → see lockdown pattern; `panic` does NOT handle this.
- Site overwhelmed by legitimate traffic → `under-attack` is wrong; tune cache + rate limits.

## `panic under-attack`

`PATCH /zones/{id}/settings/security_level` `{"value":"under_attack"}` — every request gets a JS interstitial.

Trade-off: 5-second interstitial visible to every visitor; APIs break (no JS). Use for human-facing surfaces only; for APIs use `panic block`.

`panic restore` reads `.state/panic-<ts>.json` and reverses every change.

Source: https://developers.cloudflare.com/waf/tools/under-attack-mode/

## `panic block ip|asn|country`

Creates IP Access Rule (legacy but maintained). Default TTL 24h.

| Target | Body |
|---|---|
| IP | `{mode:"block", configuration:{target:"ip", value:"1.2.3.4"}}` |
| ASN | `{configuration:{target:"asn", value:"AS12345"}}` |
| Country | `{configuration:{target:"country", value:"CN"}}` |

Skill warns on countries with significant legit traffic (US, UK, DE, FR, JP, ...) and only proceeds with explicit confirmation. Default panic country list = empty.

Source: https://developers.cloudflare.com/waf/tools/ip-access-rules/

## `panic challenge-all`

Top-priority custom rule, `expression: true`, `action: managed_challenge` in `http_request_firewall_custom`. Less aggressive than under-attack. Tag `cloudflare-secure:panic-challenge-all`.

## `panic restore`

Reads most recent `.state/panic-<timestamp>.json`. Each entry records `{endpoint, before, after}` or `{rule_id, action:"created"}`. Reverses each. Idempotent.

## Lockdown (account compromise — runbook)

1. Disable all API tokens at https://dash.cloudflare.com/profile/api-tokens.
2. Sign out all sessions: dash.cloudflare.com/profile/preferences → Active Sessions.
3. Audit-log review for unfamiliar actions.
4. Reset password (strong + unique).
5. Re-enable 2FA with new WebAuthn keys.
6. Review members — kick unfamiliar.
7. Re-create scoped tokens per `01-auth-and-tokens.md`.
8. Check DNS for unauthorized records.

Source: https://developers.cloudflare.com/fundamentals/account/account-security/

## After-action

1. Capture suspect IPs/ASNs from WAF analytics (Security → Events → action=block).
2. Review WAF rule fire counts — were real users hit?
3. Postmortem (`.state/postmortem-<ts>.md`).
4. Follow-ups: Tunnel + AOP if origin was hit directly; account-level WAF (Ent) if pattern hits multiple zones; subscribe to `dos_attack_l7`, `bot_attack`, `traffic_anomalies_alert`.

## Postmortem template

Sections: Summary (1 sentence, impact, MTTM); Timeline (HH:MM UTC); Detection (signal? miss?); Mitigation (panic invocations, rules); Root cause; Action items; Cost (edge req during incident, Workers/D1/R2 spend); What went well (3); What didn't (3).

## Plan-tier impact

| Tier | Capability |
|---|---|
| Free | panic works (under-attack, IP/ASN/country blocks, challenge-all all free) |
| Pro | log action — soak before blocking |
| Business | regex + payload logging — forensics |
| Enterprise | Bot Management scores, account-level WAF, Logpush |

## Quarterly drills (100k+)

1. Low-traffic zone or staging.
2. `panic block country XX` (no-real-traffic country).
3. `verify` shows block.
4. `panic restore`.
5. Confirm clean state.

Source: https://developers.cloudflare.com/notifications/notification-available/
