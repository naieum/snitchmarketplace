# Flask on Cloudflare

Verdict + caveats: `fit-matrix flask`. Framework docs: `stack-docs flask`.

Path: Flask on Gunicorn / uWSGI / Waitress, CF in front.

## Cloudflare-specific

- `ProxyFix` — without it, `request.scheme` wrong, `request.remote_addr` is proxy IP, `url_for(_external=True)` emits `http://`. FAIL if CF in front:

  ```python
  from werkzeug.middleware.proxy_fix import ProxyFix
  app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)
  ```

  https://flask.palletsprojects.com/en/latest/deploying/proxy_fix/
- `SECRET_KEY` from env — never literal. FAIL otherwise.
- `DEBUG=False` in prod. FAIL otherwise — `DEBUG=True` exposes Werkzeug debugger (RCE).
- Origin reachable only from CF. FAIL if 443/80 public.
- Use `request.headers.get("CF-Connecting-IP")`.
- Rate-limit `/login` via Rate Limiting Rule OR Flask-Limiter.

## Cookies

```python
app.config["SESSION_COOKIE_SECURE"] = True
app.config["SESSION_COOKIE_HTTPONLY"] = True
app.config["SESSION_COOKIE_SAMESITE"] = "Lax"
app.config["MAX_CONTENT_LENGTH"] = 10 * 1024 * 1024
```

## Headers / CSRF

`flask-talisman` is the canonical layer (CSP, HSTS, force_https, frame-options) — enable `force_https` only if `ProxyFix` is set. Alternative: CF Transform Rules.

`flask-wtf` / `CSRFProtect(app)` for forms + AJAX. FAIL if forms exist without CSRF.

## RCE classes

- `render_template_string(user_input)` → template injection. FAIL.
- `pickle.loads(user)` / `yaml.load(user)` → RCE. FAIL.
- f-string SQL → SQL injection. FAIL. Use SQLAlchemy with parameter binding.

## Skill targets

- `DEBUG=False` in prod: FAIL otherwise.
- `SECRET_KEY` from env: FAIL if literal.
- `ProxyFix` configured when CF in front: FAIL otherwise.
- Session cookies `secure` + `httponly`: FAIL otherwise.
- `flask-talisman` or equivalent CSP: WARN if missing.
- CSRF on forms: FAIL otherwise.
- Rate limit on `/login`: WARN.
- No `render_template_string(user)` / `pickle.loads(user)`: FAIL if found.
- Origin reachable only from CF: FAIL otherwise.
