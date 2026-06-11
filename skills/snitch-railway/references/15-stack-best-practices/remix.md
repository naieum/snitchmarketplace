# Remix on Railway

Remix's Node template is a clean fit. Vite-based stack is recommended for greenfield.

## Setup

```bash
npm create remix@latest -- --template remix-run/remix/templates/express
# or:
npm create remix@latest -- --template remix-run/remix/templates/remix-vite
```

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "npm run start",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening

- Headers in `entry.server.tsx` or via Express middleware (helmet) on the Express template.
- Loaders/actions run on long-lived Node — no edge-runtime constraints.
- Rate-limit `action` POSTs (login, signup, contact) at middleware.

## Docs

- https://remix.run/docs/en/main
- https://docs.railway.com/guides/remix
