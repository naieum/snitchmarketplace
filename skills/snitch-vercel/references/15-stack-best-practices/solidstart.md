# SolidStart on Vercel — best practices

SolidStart picks a Vercel preset automatically when deployed.

## Configuration

```ts
// app.config.ts
import { defineConfig } from "@solidjs/start/config";

export default defineConfig({
  server: {
    preset: "vercel",
    // preset: "vercel_edge"  // edge variant
  },
});
```

## Headers

H3 middleware (Solid Start uses Nitro under the hood — same as Nuxt):

```ts
// src/middleware.ts
import { createMiddleware } from "@solidjs/start/middleware";

export default createMiddleware({
  onRequest: (event) => {
    event.response.headers.set("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload");
    event.response.headers.set("X-Frame-Options", "DENY");
  },
});
```

## Server actions

`"use server"` directive and server functions (`createAsync`, `useAction`) compile to POST endpoints — validate input, rate-limit at edge, CSRF-check by origin.

## References

- https://vercel.com/docs/frameworks/solidstart
- https://docs.solidjs.com/solid-start/building-your-application/api-routes
