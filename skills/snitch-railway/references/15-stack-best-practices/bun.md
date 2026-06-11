# Bun on Railway

Nixpacks supports Bun. `bun run start` is the canonical entry.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "bun run start",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening (Bun-native HTTP server)

```ts
const securityHeaders = {
  "strict-transport-security": "max-age=31536000; includeSubDomains; preload",
  "x-content-type-options": "nosniff",
  "x-frame-options": "DENY",
  "referrer-policy": "strict-origin-when-cross-origin"
};

Bun.serve({
  port: Number(process.env.PORT ?? 3000),
  hostname: "0.0.0.0",
  fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/health") {
      return new Response("ok", { headers: securityHeaders });
    }
    return new Response("hello", { headers: securityHeaders });
  }
});
```

## Notes

- Express/Fastify on Bun: same hardening — Bun ships Node-compatible APIs.
- Pin Bun version (`engines.bun` in package.json or `bun.toml`).

## Docs

- https://bun.sh/docs
