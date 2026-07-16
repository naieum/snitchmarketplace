# Stack hardening: Python / Django

Loaded when stack detection identifies Django (`django` in requirements/`pyproject`, `settings.py`,
`urls.py`, `manage.py`). Django is "secure by default" on several axes — ORM parameterization,
template auto-escape, CSRF middleware — so the sinks are largely the **escape hatches** plus
settings/deployment posture.

## Where the sinks are (trace these — Rule 7)

| Pattern | Risk | Cat |
|---|---|---|
| `.raw()` / `.extra()` / `cursor.execute(f"... {x}")` with input | SQL injection | 01 |
| `mark_safe(...)`, `format_html` misuse, `|safe` in templates | XSS | 02 |
| `subprocess(..., shell=True)` / `os.system` with input | command injection | 10 |
| `pickle.loads` / `yaml.load` (unsafe) on untrusted data | insecure deserialization | 65 |
| `redirect(request.GET['next'])` without allow-list | open redirect | 05 |
| `requests.get(user_url)` server-side | SSRF / cloud-metadata | 05 / 64 |
| `lxml`/`etree` parsing untrusted XML without hardening | XXE | 49 |
| `DEBUG = True` in production; exposed `/admin` or debug toolbar | info disclosure / debug endpoint | 51 / 12 |

## Framework auto-protections (do NOT flag these)

- The **ORM parameterizes** queries — `Model.objects.filter(...)` is not SQLi; only `.raw()`/
  `.extra()`/raw `cursor.execute` with string-building are (01).
- **Templates auto-escape** — `{{ value }}` is safe; `mark_safe`/`|safe` are the escape hatches (02).
- **CSRF middleware is on by default** — only flag CSRF when it's disabled (`@csrf_exempt`, removed
  middleware, or a DRF view without auth) (47).
- `SecurityMiddleware` + `SECURE_*` settings cover many headers (32); the auth/permission system
  covers authN/authZ when used.

## Hardening checklist

- `DEBUG = False` in prod; `ALLOWED_HOSTS` set; `SECRET_KEY` from env, never in source (03, 51).
- Prefer the ORM; if `.raw()` is unavoidable, use parameter placeholders, never f-strings (01).
- Don't disable CSRF; if a view is `@csrf_exempt`, confirm it's a token-auth API, not cookie-auth (47).
- Enforce object-level permissions / `PermissionRequiredMixin` — don't rely on hiding URLs (28).
- Validate + constrain uploads (type/size/location) (29); set `SECURE_HSTS_*`, `SECURE_SSL_REDIRECT`,
  secure cookies (32).
- `yaml.safe_load`, never bare `pickle` on untrusted input (65).

## Forbidden claims

- Flagging an ORM query as SQLi (only raw/extra/string-built are — 01).
- Flagging `{{ value }}` as XSS — templates auto-escape; the sink is `mark_safe`/`|safe` (02).
- Calling CSRF "missing" without showing it's disabled (default is on — 47, Rule 1).

---

*Per-stack reference informed by codex-security's curated best-practices model; reimplemented
evidence-first/defensive, cross-referenced to snitch's category numbers. Internal reference.*
