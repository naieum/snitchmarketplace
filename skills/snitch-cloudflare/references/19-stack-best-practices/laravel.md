# Laravel on Cloudflare

Verdict: `proxy-only` (PHP doesn't run on Workers; Containers beta is the eventual play). Path: Laravel on its host (Forge, Vapor, self-hosted), CF in front.

`fit-matrix laravel`. `stack-docs laravel`.

## Cloudflare-specific

- `App\Http\Middleware\TrustProxies` set (`$proxies = '*'` or CF CIDRs) — without it, `request->scheme()` is `http` and `URL::forceScheme('https')` causes redirect loops. FAIL if missing. https://laravel.com/docs/master/requests#configuring-trusted-proxies
- `APP_KEY` lives as Worker secret (Containers) or env var (origin) — never committed. FAIL if empty.
- `APP_DEBUG=false` in production. FAIL otherwise.
- `.env` in `.gitignore`. FAIL otherwise.
- Origin reachable only from CF. FAIL if 443/80 public.
- Rate-limit `/login`, `/register`, `/password/email` via Rate Limiting Rule.
- Admin path behind Cloudflare Access.

## Session config

`config/session.php` requires `'secure' => true`, `'http_only' => true`, `'same_site' => 'lax'` in production. FAIL if `secure` not set.

## Cache rules with CSRF

Laravel uses `?_token=...` for CSRF; don't cache responses with `_token` query string. Bypass cache on `/login`, `/register`, any auth POST.

## CSP

`spatie/laravel-csp` package OR custom middleware OR CF Transform Rules at edge. WARN if no CSP source.

## Mass-assignment / SQL

- Every model has `$fillable` set. WARN otherwise.
- No raw SQL with concat (`whereRaw($sql)` without binding). WARN if detected.
- `barryvdh/laravel-debugbar` only in dev.

## Skill targets

- `APP_DEBUG=false` in prod: FAIL otherwise.
- `APP_KEY` set: FAIL if empty.
- `.env` in `.gitignore`: FAIL otherwise.
- Session cookie `secure: true`: FAIL otherwise.
- `TrustProxies::$proxies` set: FAIL otherwise.
- CSP header sent: WARN if missing.
- All models have `$fillable`: WARN otherwise.
- No raw SQL with concat: WARN if detected.
- Origin reachable only from CF: FAIL otherwise.
