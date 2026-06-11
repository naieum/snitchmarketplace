# Express on Cloudflare

Verdict + caveats: `fit-matrix express`. Framework docs: `stack-docs express`.

Default path: keep Express on origin, CF in front (Tunnel + WAF + DDoS). Workers port mechanically possible but most projects fail the dependency audit.

## Cloudflare-specific

- `app.set("trust proxy", true)` — without it, `req.ip` is the local proxy IP. With CF in front this is FAIL. Tighten to CF CIDRs: `app.set("trust proxy", cloudflareCIDRs)`. https://expressjs.com/en/guide/behind-proxies.html
- Origin reachable only from CF (Tunnel preferred). FAIL if 443/80 public.
- Use `CF-Connecting-IP` for true client IP rather than walking `X-Forwarded-For`.
- Body size limit on parsers (`bodyParser.json({ limit: "100kb" })`) — unbounded body = memory DoS.
- CORS: never `cors()` with no options (defaults to `*`). Use `cors({ origin: "https://example.com", credentials: true })`.

## Worker port

Port to Hono (`hono.md`) rather than forcing Express through `nodejs_compat`:

| From | To |
|---|---|
| `bcrypt` | `bcryptjs` or Web Crypto |
| `multer` | R2 presigned URLs |
| `sharp` | Cloudflare Images |
| `nodemailer` | provider HTTP API |
| `passport` | `jose` JWT or Auth.js |
| Redis sessions | KV (eventual consistency) |

## Origin posture

- `helmet` (defense in depth on top of CF Transform Rules).
- Cookie flags: `secure: true`, `httpOnly: true`, `sameSite: "lax"`.
- Session store not in-memory — Redis or Mongo.
- Node 20 LTS minimum.

## Skill targets

- `trust proxy` set when CF in front: FAIL otherwise.
- Origin not publicly reachable: FAIL if 443/80 open.
- Body parser size limit: WARN if missing.
- Cookie flags `secure` + `httpOnly`: FAIL if missing.
- `cors()` with explicit `origin`: FAIL if `*` + credentials.
- `helmet` middleware: WARN if missing.
- Node version >= 20: WARN if older.
