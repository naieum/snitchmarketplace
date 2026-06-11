# Origin hardening checklist

This skill cannot run on your origin host — you do this part. It takes 15-30 minutes per host.

---

## 1. Allowlist Cloudflare IPs at the origin firewall

Authoritative IP list: `https://www.cloudflare.com/ips/` (refreshed periodically — automate the pull).

After this, traffic NOT from Cloudflare is dropped, so attackers who discover the origin IP can't reach you directly.

### iptables (Linux, raw)

```bash
# Pull current Cloudflare IPv4 ranges and allow on 80/443.
curl -fsSL https://www.cloudflare.com/ips-v4 | while read cidr; do
  iptables -A INPUT -p tcp -m multiport --dports 80,443 -s "$cidr" -j ACCEPT
done
curl -fsSL https://www.cloudflare.com/ips-v6 | while read cidr; do
  ip6tables -A INPUT -p tcp -m multiport --dports 80,443 -s "$cidr" -j ACCEPT
done
# Default-drop everything else on 80/443.
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j DROP
ip6tables -A INPUT -p tcp -m multiport --dports 80,443 -j DROP
# Persist (Debian/Ubuntu)
apt-get install -y iptables-persistent
netfilter-persistent save
```

### ufw (Ubuntu)

```bash
# Reset defaults: deny incoming on 80/443, then allowlist Cloudflare.
ufw default deny incoming
for cidr in $(curl -fsSL https://www.cloudflare.com/ips-v4) $(curl -fsSL https://www.cloudflare.com/ips-v6); do
  ufw allow from "$cidr" to any port 80,443 proto tcp
done
ufw enable
```

### nginx (allow at the application layer)

```nginx
# Place inside your server { } block, before any location { } that serves traffic.
include /etc/nginx/cloudflare-ips.conf;
deny all;

# Cron-refresh the include file:
#   curl -fsSL https://www.cloudflare.com/ips-v4 | sed 's|^|allow |;s|$|;|' >  /etc/nginx/cloudflare-ips.conf
#   curl -fsSL https://www.cloudflare.com/ips-v6 | sed 's|^|allow |;s|$|;|' >> /etc/nginx/cloudflare-ips.conf
#   nginx -t && systemctl reload nginx
```

### Apache

```apache
<RequireAll>
  Require ip 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 \
             141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 \
             197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 \
             104.24.0.0/14 172.64.0.0/13 131.0.72.0/22
  # Add the IPv6 ranges from https://www.cloudflare.com/ips-v6 to this list.
</RequireAll>
```

### Cloud provider security groups

- **AWS:** SG inbound rules limited to Cloudflare CIDRs on 80/443. Use a managed prefix list refreshed by a Lambda for hands-off updates.
- **GCP:** firewall rules with source ranges = Cloudflare CIDRs on tcp:80,443.
- **Azure:** NSG inbound security rules with source = Cloudflare CIDRs.

Best of all: use Cloudflare Tunnel — origin doesn't need a public IP at all.

---

## 2. Authenticated Origin Pulls (AOP)

AOP makes Cloudflare present a client cert to your origin. Origin trusts only requests bearing that cert. Even if someone gets the IP and IPs aren't allowlisted, they can't impersonate Cloudflare.

Two flavors:
- **Per-zone certificate** (preferred) — unique cert per zone, generated in dash → SSL/TLS → Origin Server → Authenticated Origin Pulls.
- **Cloudflare global certificate** — shared across customers; install the public root: `https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem`.

### nginx

```nginx
server {
  listen 443 ssl http2;
  server_name example.com;

  # Origin's own cert (Let's Encrypt or CF Origin CA).
  ssl_certificate         /etc/ssl/origin.crt;
  ssl_certificate_key     /etc/ssl/origin.key;

  # AOP: require Cloudflare's client cert.
  ssl_client_certificate  /etc/ssl/cloudflare-aop.pem;
  ssl_verify_client       on;

  # Optional: if a non-CF request slips through, return 403 instead of TLS error.
  if ($ssl_client_verify != SUCCESS) { return 403; }

  # ... rest of config
}
```

### Apache (mod_ssl)

```apache
<VirtualHost *:443>
  ServerName example.com
  SSLEngine on
  SSLCertificateFile      /etc/ssl/origin.crt
  SSLCertificateKeyFile   /etc/ssl/origin.key

  # AOP
  SSLVerifyClient require
  SSLVerifyDepth 1
  SSLCACertificateFile    /etc/ssl/cloudflare-aop.pem
</VirtualHost>
```

### Caddy

```caddy
example.com {
  tls /etc/ssl/origin.crt /etc/ssl/origin.key {
    client_auth {
      mode require_and_verify
      trust_pool file /etc/ssl/cloudflare-aop.pem
    }
  }
  # ... handlers
}
```

After installing, enable Authenticated Origin Pulls in the Cloudflare dash → SSL/TLS → Origin Server.

---

## 3. Close non-Cloudflare-needed ports

The only ports Cloudflare proxies need open to the origin are **80** and **443** (and only from the Cloudflare IP set above). Close everything else to the public:

- **22 (SSH)** — restrict to your bastion/VPN/management CIDR. Better: SSH over Cloudflare Tunnel + Access for Infrastructure.
- **3306 (MySQL), 5432 (Postgres), 6379 (Redis), 27017 (MongoDB), 9200 (Elasticsearch)** — must NEVER be public. If you see one in `ss -tlnp` bound to `0.0.0.0`, fix it now.
- **8080, 8443, 9000, 9090** — common app/admin ports; close or move behind Cloudflare Tunnel + Access.
- **25, 587 (SMTP)** — only if this host is actually an SMTP server.
- **3389 (RDP), 5900 (VNC)** — never public.

```bash
# What's listening publicly? Anything bound to 0.0.0.0 or ::.
ss -tlnp | grep -E '0\.0\.0\.0|\[::\]'
```

If you want zero public surface, use Cloudflare Tunnel: install `cloudflared`, run `cloudflared tunnel create`, point the Tunnel ingress at `localhost:443`, set the origin's nginx to listen only on `127.0.0.1`.

---

## 4. X-Forwarded-For trust (otherwise your real-IP logging is wrong)

By default, every request from Cloudflare arrives with the source IP set to a Cloudflare edge IP. The real user IP is in the `CF-Connecting-IP` header (canonical) or `X-Forwarded-For` (chain).

If you don't tell your framework to trust these, every log line says "the user is Cloudflare" and your rate limiting / abuse blocking / audit trails are broken.

### Express (Node.js)

```js
// Trust ONLY Cloudflare's known proxies. Numerical = "trust N hops".
// Better: pass a function that returns true for Cloudflare's CIDRs and false otherwise.
app.set('trust proxy', (ip) => isCloudflareIp(ip));
// Then req.ip is the original user IP.
// Prefer req.headers['cf-connecting-ip'] when you specifically want CF's value.
```

Don't blindly do `app.set('trust proxy', true)` — that trusts ANY proxy, which lets attackers spoof XFF.

### Fastify (Node.js)

```js
const fastify = require('fastify')({ trustProxy: (ip) => isCloudflareIp(ip) });
```

### Rails (Ruby)

```ruby
# config/environments/production.rb
# As of Rails 7+, configure trusted proxies explicitly.
config.action_dispatch.trusted_proxies = cloudflare_cidrs.map { |c| IPAddr.new(c) }
# Then request.remote_ip returns the real user IP.
# To pull CF's canonical header directly:
#   request.headers['CF-Connecting-IP']
```

### Django (Python)

```python
# settings.py
USE_X_FORWARDED_HOST = True
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# Use a middleware that reads CF-Connecting-IP and sets request.META['REMOTE_ADDR']
# AFTER verifying the request came from a Cloudflare IP. Don't trust the header
# blindly — that's a spoofing vector.
```

### Laravel (PHP)

```php
// app/Http/Middleware/TrustProxies.php
protected $proxies = '*';                                  // dev only
protected $proxies = ['173.245.48.0/20', '103.21.244.0/22', /* ... CF list ... */];
protected $headers = Request::HEADER_X_FORWARDED_FOR | Request::HEADER_X_FORWARDED_PROTO;
```

### nginx (real-IP module)

```nginx
# Map CF-Connecting-IP to $remote_addr so logs and downstream apps see real IPs.
real_ip_header   CF-Connecting-IP;
real_ip_recursive on;
# Trust ONLY Cloudflare. Generate this list from https://www.cloudflare.com/ips/.
include /etc/nginx/cloudflare-set-real-ip.conf;
# That file contains lines like: set_real_ip_from 173.245.48.0/20;
```

---

## 5. Use CF-Connecting-IP for canonical real-IP logging

Even with framework trust configured, log `CF-Connecting-IP` directly when in doubt — it's the IP Cloudflare saw connect. `X-Forwarded-For` is the chain, which can include hops you don't control.

For rate limiting, fraud scoring, and abuse handling, key on `CF-Connecting-IP`.

For audit trails, store both `CF-Connecting-IP` and `X-Forwarded-For` so you can debug later.

---

## 6. Verify everything

Once the steps above are in place:

```bash
# From a non-Cloudflare host, hit the origin IP directly. You expect:
# - Connection refused (firewall blocked you), OR
# - 403 (AOP rejected your missing client cert), OR
# - the app's "no Host header / unknown host" response if you hit by IP.
curl -vI https://<origin-ip>/

# From your laptop, hit the public hostname. Expect: 200 / your normal site.
curl -vI https://example.com/

# Confirm the origin sees a real client IP (not a CF edge IP) in your logs.
# In nginx: tail -f /var/log/nginx/access.log; visit the site from your phone on cell.
```

If the direct-IP test returns the actual site, your firewall isn't blocking and an attacker who finds the IP can bypass Cloudflare. Fix this before declaring the origin hardened.
