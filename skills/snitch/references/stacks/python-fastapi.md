# Stack hardening: Python / FastAPI

Loaded when stack detection identifies FastAPI (`fastapi` in requirements/`pyproject`,
`@app.get/post`, `APIRouter`, Pydantic models). FastAPI validates *shape* well (Pydantic) but
ships **no built-in authZ, CSRF, or security headers** — those are the gaps to check.

## Where the sinks are (trace these — Rule 7)

| Pattern | Risk | Cat |
|---|---|---|
| Raw SQL via f-string / `text(f"...")` instead of bound params | SQL injection | 01 |
| `subprocess(..., shell=True)` / `os.system` with input | command injection | 10 |
| `pickle.loads` / `yaml.load` on request data | insecure deserialization | 65 |
| Server-side `requests`/`httpx` to a constructed URL | SSRF / cloud-metadata | 05 / 64 |
| File path from input into `open`/`FileResponse` | path traversal | 29 |
| Route without an auth dependency performing a state change | broken access control | 28 / 04 |
| Permissive `CORSMiddleware` (`allow_origins=["*"]` + credentials) | CORS misconfig | 08 |

## Framework auto-protections (do NOT flag these)

- **Pydantic request models validate input shape/types** — strong input validation (30). But
  validation ≠ authorization; a well-typed body still needs an authZ check.
- **SQLAlchemy bound parameters** parameterize — only f-string/`text()`-with-interpolation is
  SQLi (01).
- No automatic authZ, CSRF, rate limiting, or security headers — their **absence is a real
  finding**, not a framework feature.

## Hardening checklist

- An auth dependency (`Depends(get_current_user)` + a permission check) on **every**
  state-changing route — FastAPI won't add one for you (28, 04).
- Pydantic models for all request bodies/params (30); bound params for all SQL (01).
- `CORSMiddleware` with an explicit origin allow-list, not `*` with credentials (08).
- Guard server-side `httpx`/`requests` against SSRF (block internal ranges / metadata IP) (05, 64).
- Rate-limit auth + expensive endpoints (07); secrets from env (03); restrict `/docs`/`/openapi.json`
  in prod if the API is sensitive (51).

## Forbidden claims

- Treating Pydantic validation as authorization — it isn't (flag missing authZ separately, 28).
- Flagging bound SQLAlchemy params as SQLi (01).
- Asserting CORS is safe because a `CORSMiddleware` exists — check `allow_origins`/credentials (08).

---

*Per-stack reference informed by codex-security's curated best-practices model; reimplemented
evidence-first/defensive, cross-referenced to snitch's category numbers. Internal reference.*
