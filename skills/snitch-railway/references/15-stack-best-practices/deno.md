# Deno on Railway

Nixpacks supports Deno. Use `deno task start` or `deno run` directly.

## railway.json

```json
{
  "build": { "builder": "NIXPACKS" },
  "deploy": {
    "startCommand": "deno run --allow-net --allow-env main.ts",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening

```ts
import { serve } from "https://deno.land/std/http/server.ts";

const headers: HeadersInit = {
  "strict-transport-security": "max-age=31536000; includeSubDomains; preload",
  "x-content-type-options": "nosniff",
  "x-frame-options": "DENY",
  "referrer-policy": "strict-origin-when-cross-origin"
};

await serve(async (req) => {
  const url = new URL(req.url);
  if (url.pathname === "/health") {
    return new Response("ok", { headers });
  }
  return new Response("hello", { headers });
}, { port: Number(Deno.env.get("PORT") ?? 8080), hostname: "0.0.0.0" });
```

## Notes

- Deno's permission flags are first-class security. Scope `--allow-net` to specific hostnames where possible.
- Pin Deno version in `nixpacks.toml` setup phase.

## Docs

- https://docs.deno.com/runtime/manual/
