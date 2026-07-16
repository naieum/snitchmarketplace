# Stack hardening: Python / Flask

Loaded when stack detection identifies Flask (`flask` in requirements/`pyproject`, `Flask(__name__)`,
`@app.route`). Flask is minimal — Jinja auto-escapes templates, but **CSRF, auth, headers, and rate
limiting are not included**, and the standout sink is server-side template injection.

## Where the sinks are (trace these — Rule 7)

| Pattern | Risk | Cat |
|---|---|---|
| `render_template_string(... user input ...)` | SSTI → RCE (Jinja) | 10 |
| `cursor.execute(f"... {x}")` / string-built SQL | SQL injection | 01 |
| `subprocess(..., shell=True)` / `os.system` with input | command injection | 10 |
| `pickle.loads` / `yaml.load` on untrusted data | insecure deserialization | 65 |
| `send_file`/`send_from_directory` with user path | path traversal | 29 |
| `redirect(request.args.get('next'))` | open redirect | 05 |
| `Markup(...)` / `|safe` on user input | XSS | 02 |
| `app.run(debug=True)` in prod (Werkzeug console) | RCE / info disclosure | 51 |

## Framework auto-protections (do NOT flag these)

- **Jinja auto-escapes** in `.html` templates — `{{ value }}` is safe; the sinks are
  `render_template_string` with input (SSTI), `Markup`, and `|safe` (02, 10).
- Flask has **no CSRF by default** — its absence on cookie-authenticated forms is a real finding;
  Flask-WTF / `CSRFProtect` is the fix (47).
- No built-in auth, rate limiting, or security headers — absence is a finding, not a feature
  (use Flask-Talisman for headers (32), Flask-Limiter for rate limits (07)).

## Hardening checklist

- **Never** pass user input to `render_template_string` (SSTI); render fixed templates with context
  variables only (10).
- Parameterize SQL (placeholders / SQLAlchemy bound params), never f-strings (01).
- `CSRFProtect` for cookie-authenticated state changes (47); `debug=False` in prod (51).
- `SECRET_KEY` from env, strong + rotated (03, 52); authZ decorators on protected routes (28).
- Validate input (30); constrain `send_file` paths to a safe base dir (29); Flask-Talisman for CSP +
  headers (32).
- `yaml.safe_load`; no `pickle` on untrusted input (65).

## Forbidden claims

- Flagging `{{ value }}` as XSS — Jinja auto-escapes; the sinks are `render_template_string`/
  `Markup`/`|safe` (02, 10).
- Asserting SSTI without showing user input reaching `render_template_string` (Rule 7 trace).
- Calling CSRF "missing" without confirming cookie-auth + no `CSRFProtect` (47).

---

*Per-stack reference informed by codex-security's curated best-practices model; reimplemented
evidence-first/defensive, cross-referenced to snitch's category numbers. Internal reference.*
