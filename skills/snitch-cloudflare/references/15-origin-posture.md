# 15 — Origin Posture

The skill cannot run on the user's origin host. Printed checklist when an origin is detected.

CF in front of a server doesn't help if origin is reachable directly. Attackers learn origin IPs (DNS history, leaks, CT logs, error pages) and bypass.

## 1. Allowlist Cloudflare IPs (or use Aegis)

Block inbound 443 except from CF edge: https://www.cloudflare.com/ips-v4 , https://www.cloudflare.com/ips-v6 , https://api.cloudflare.com/client/v4/ips. Refresh quarterly.

iptables:

```sh
for ip in $(curl -s https://www.cloudflare.com/ips-v4); do
  iptables -A INPUT -p tcp --dport 443 -s "$ip" -j ACCEPT
done
iptables -A INPUT -p tcp --dport 443 -j DROP
```

nftables / firewalld / AWS SG / GCP firewall / Azure NSG — same pattern.

Aegis (Enterprise) shrinks to a small fixed set of dedicated egress IPs.

Sources: https://developers.cloudflare.com/fundamentals/concepts/cloudflare-ip-addresses/ , https://developers.cloudflare.com/aegis/

## 2. Cloudflare Tunnel (preferred over IP allowlist)

Outbound from origin → Cloudflare. Origin firewall denies all inbound 443/80. Free. See `08-zero-trust-tunnel-access.md`.

```sh
ufw deny 443/tcp
ufw deny 80/tcp
```

Allowlist + Tunnel can coexist if you're not ready to drop public ports.

## 3. AOP cert at origin (when no Tunnel)

CA cert: https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem

```nginx
ssl_client_certificate /etc/ssl/cloudflare-aop-ca.pem;
ssl_verify_client on;
```

```apache
SSLCACertificateFile /etc/ssl/cloudflare-aop-ca.pem
SSLVerifyClient require
SSLVerifyDepth 1
```

Caddy / HAProxy — same pattern.

Source: https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/set-up/

## 4. Close direct DB / app ports

Never publicly expose: 3306 (MySQL), 5432 (Postgres), 6379 (Redis), 27017 (MongoDB), 11211 (Memcached), 9200/9300 (ES), 5984 (CouchDB), 8080/8443 (random app servers).

Bind to `127.0.0.1` or private network. Workers reach DBs via Hyperdrive.

```
listen_addresses = 'localhost'   # postgresql.conf
bind-address = 127.0.0.1         # my.cnf
```

`nmap -Pn <origin-public-ip>` from outside should show nothing extra.

## 5. Trust `CF-Connecting-IP`, not raw `X-Forwarded-For`

CF adds `CF-Connecting-IP` (real client) and `X-Forwarded-For`. If origin firewall doesn't deny non-CF traffic, attackers spoof XFF directly.

Defenses:
1. Origin firewall blocks non-Cloudflare (step 1).
2. App reads `CF-Connecting-IP` as canonical client IP.
3. App strips `CF-Connecting-IP` if request didn't come from Cloudflare.

Stack-specific:
- Express: `app.set("trust proxy", true)` → `req.headers["cf-connecting-ip"]`.
- Rails: `config.action_dispatch.trusted_proxies = [*cloudflare_cidrs]`.
- Django: `USE_X_FORWARDED_HOST = True` + `SECURE_PROXY_SSL_HEADER`.
- nginx: `real_ip_header CF-Connecting-IP; set_real_ip_from <each CF CIDR>;`.

Source: https://developers.cloudflare.com/fundamentals/reference/http-headers/

## 6. Fingerprint reduction

```nginx
autoindex off; server_tokens off;
```

```apache
ServerSignature Off; ServerTokens Prod; Options -Indexes
```

## 7. SSH

- `PasswordAuthentication no`.
- `PermitRootLogin no` (or `prohibit-password`).
- Allowlist SSH to admin IPs only, OR SSH behind Tunnel: `cloudflared access ssh --hostname=ssh.example.com --url=ssh://localhost:22`.

Source: https://developers.cloudflare.com/cloudflare-one/applications/non-http/ssh/

## 8. Log correlation

- Echo `CF-Ray` in origin logs — joins edge to origin during incidents.
- NTP keeps clock skew < few seconds.

```nginx
log_format with_ray '$remote_addr [$time_local] "$request" '
                   '$status $http_cf_ray $http_cf_connecting_ip';
```

With Logpush (Ent) → SIEM, `CF-Ray` is the join key.

Source: https://developers.cloudflare.com/fundamentals/reference/http-headers/#cf-ray

## 9. Periodic audit (90d)

- Refresh CF IP allowlist against `ips-v4`.
- `nmap -p 1-65535 <origin-public-ip>` from outside.
- Update Tunnel connector if > 90d old.
- Spot-check origin logs for non-`CF-Connecting-IP`-tagged requests.

## What the skill can't verify remotely

- `curl -k -H 'Host: example.com' https://<origin-ip>/` from non-CF network — response = open firewall.
- `nmap -Pn -p 22,80,443,3306,5432,6379,27017 <origin-ip>` — confirm only expected ports.
