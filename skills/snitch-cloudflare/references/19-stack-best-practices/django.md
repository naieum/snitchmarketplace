# Django on Cloudflare

Verdict: `proxy-only` (Python doesn't run on Workers; Containers beta eventual). Pattern: Django on its host + CF in front + Tunnel; `/admin/*` behind Cloudflare Access.

`stack-docs django`.

## Cloudflare-specific

Trust the proxy. Without it, `is_secure()` returns False, `SECURE_SSL_REDIRECT` causes a redirect loop:

```python
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
USE_X_FORWARDED_HOST = True
ALLOWED_HOSTS = ["example.com", "www.example.com"]   # not ["*"]
```

`CF-Connecting-IP` middleware:

```python
class CloudflareMiddleware:
    def __init__(self, get_response): self.get_response = get_response
    def __call__(self, request):
        ip = request.META.get("HTTP_CF_CONNECTING_IP")
        if ip: request.META["REMOTE_ADDR"] = ip
        return self.get_response(request)
```

## Required `settings.py`

```python
DEBUG = False
SECRET_KEY = os.environ["SECRET_KEY"]
SESSION_COOKIE_SECURE = SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"
CSRF_COOKIE_SECURE = CSRF_COOKIE_HTTPONLY = True
CSRF_COOKIE_SAMESITE = "Lax"
CSRF_TRUSTED_ORIGINS = ["https://example.com", "https://www.example.com"]
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = "DENY"
SECURE_REFERRER_POLICY = "strict-origin-when-cross-origin"
```

HSTS: skip in-app (CF zone toggle wins). CI must run `python manage.py check --deploy`.

## Django admin

- Move from default `/admin/` (cheap obscurity).
- Cloudflare Access in front of admin URL — non-negotiable.
- 2FA via `django-otp`.
- Per-model permissions; rate-limit `/admin/login/` at CF edge.

## CSP / Storage

`django-csp` middleware OR CF Transform Rules at edge. `django-storages` to push to R2; validate content-type; signed URLs with limited TTL.

## Skill targets

- `DEBUG = False` in prod: FAIL otherwise.
- `ALLOWED_HOSTS` specific list, not `*`: FAIL otherwise.
- `SECRET_KEY` from env: FAIL if literal.
- `SECURE_PROXY_SSL_HEADER` set when CF in front: FAIL.
- Session/CSRF cookies `secure`+`httponly`: FAIL otherwise.
- `/admin/` behind Access: WARN.
- Rate limit on `/login`: WARN.
- No `pickle.loads` on user input: FAIL if found.
- No `.raw(`/`.extra(` with concat: FAIL if found.
- Origin reachable only from CF: FAIL otherwise.
