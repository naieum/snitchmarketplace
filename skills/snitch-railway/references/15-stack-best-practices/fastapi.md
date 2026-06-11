# FastAPI on Railway

Nixpacks detects FastAPI via `requirements.txt`. Use `uvicorn` for production.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "uvicorn main:app --host 0.0.0.0 --port $PORT --workers 2",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening

```python
from fastapi import FastAPI
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

app = FastAPI()
app.add_middleware(TrustedHostMiddleware, allowed_hosts=["yourdomain.com", "*.up.railway.app"])

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        return response

app.add_middleware(SecurityHeadersMiddleware)

@app.get("/health")
async def health():
    return {"ok": True}
```

## Patterns

- Background tasks: separate Railway service running Celery, RQ, or Arq — Redis as a service.
- WebSockets: native FastAPI, served via public HTTPS (wss://).

## Docs

- https://fastapi.tiangolo.com/tutorial/security/
- https://docs.railway.com/guides/fastapi
