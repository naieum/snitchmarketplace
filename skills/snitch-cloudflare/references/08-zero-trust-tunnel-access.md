# 08 — Zero Trust: Tunnel, Access, Service Tokens, WARP, Gateway

## Cloudflare Tunnel (cloudflared)

Free. Outbound-only encrypted tunnel from origin to Cloudflare. Origin needs no public IP; firewall denies all inbound except `127.0.0.1`. Eliminates leaked-origin-IP attacks.

```sh
cloudflared tunnel login
cloudflared tunnel create my-app
cloudflared tunnel route dns my-app api.example.com
cloudflared tunnel run my-app
```

API: `POST /accounts/{id}/cfd_tunnel` body `{name, tunnel_secret:"<base64-32-bytes>", config_src:"cloudflare"}`. `config_src: "cloudflare"` (recommended) keeps config in dashboard; `local` keeps it in `~/.cloudflared/config.yml`.

Ingress:

```json
{ "ingress": [
  {"hostname": "api.example.com", "service": "http://localhost:3000"},
  {"hostname": "*", "service": "http_status:404"}
]}
```

Last rule must be a catchall. `sudo cloudflared service install <tunnel-token>` for systemd.

Skill flags connectors > 90 days old (`GET /accounts/{id}/cfd_tunnel/{id}/connections`).

Source: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

## Cloudflare Access

Identity-aware reverse proxy. Free up to 50 seats, $7/seat past 50 (Standard).

App types:
- Self-hosted: protect domain/path. User → CF interstitial → IdP sign-in → JWT cookie; app receives JWT in `Cf-Access-Jwt-Assertion`.
- SaaS apps: SSO via Cloudflare as IdP.

Skill default: protect admin paths, staging, internal tools, Pages preview deployments.

App body: `{name, domain, type:"self_hosted", session_duration:"24h"}`.

Source: https://developers.cloudflare.com/cloudflare-one/applications/

## Policies

Precedence: `bypass` > `block` > `allow` > `deny`. Common include shapes:

- Email domain: `{"email_domain":{"domain":"example.com"}}`
- GitHub team: `{"github":{"name":"acme/eng","identity_provider_id":"<id>"}}`
- Country block: `{"geo":{"country_code":"CN"}}` with `decision: "block"`
- mTLS require: `require:[{"mtls":{"common_name":"client.example.com"}}]`
- Device posture (WARP): `require:[{"device_posture":{"integration_uid":"<id>","check":{"exists":true}}}]`

Source: https://developers.cloudflare.com/cloudflare-one/policies/access/

## Service Tokens

Client presents `CF-Access-Client-Id` + `CF-Access-Client-Secret`, bypasses interactive login.

`POST /accounts/{id}/access/service_tokens` body `{name, duration:"8760h"}`. Cleartext `client_secret` returned once — store as CI secret.

Policy include: `{"service_token":{"token_id":"<id>"}}`.

Source: https://developers.cloudflare.com/cloudflare-one/identity/service-tokens/

## WARP

End-user device agent. Routes traffic through Cloudflare for Gateway DNS filtering, always-on VPN to private apps via Tunnel, device posture (OS version, disk encryption, EDR). Free for personal; included in ZT seats.

Skill recommends WARP for orgs with internal apps at 1k+; hard requirement at 100k+.

Source: https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/

## Gateway DNS filtering

Free up to 50 users. Block-by-category at resolver layer.

Configure at `Zero Trust → Gateway → Firewall Policies → DNS`. Skill recommendations:

- Block: `Security`, `Phishing`, `Malware`, `Cryptomining`, `Newly Registered Domains`, `DGAs`.
- Optionally block: `Adult`, `Gambling`, `Social Media` (corp).
- Always allow: explicitly trusted domains.

Source: https://developers.cloudflare.com/cloudflare-one/policies/gateway/

## Plan-tier matrix (Zero Trust)

| Feature | Free | Standard ($7/user/mo) | Enterprise |
|---|---|---|---|
| Seats | 50 | unlimited | unlimited |
| Tunnel / Access self-hosted+SaaS / Service tokens / WARP / Gateway DNS | yes | yes | yes |
| Gateway HTTP filtering | no | yes | yes |
| Gateway Network firewall | no | yes | yes |
| Browser Isolation | no | partial | yes |
| CASB | no | partial | yes |
| Device posture (advanced) | basic | full | full |
| DLP | no | partial | yes |

Source: https://www.cloudflare.com/plans/zero-trust-services/

## Skill targets

- Tunnel at 100-user plateau if origin has public IP.
- Access on staging / preview from day 1 for projects with backend/database.
- Access on `/admin` or `/dashboard` for any production app.
- Service tokens for any CI/CD reaching Access-protected URL.
- WARP for admins at 10–50 users; expand at 1k+.
- Gateway DNS for any team with shared/company devices.
