# Edge middleware

Edge middleware runs on Vercel's Edge Network on every request matching its `matcher`. Executes before the function/static handler.

## Where it lives

| Path | Framework | Runtime |
|---|---|---|
| `middleware.ts` (project root) | Next.js / generic | Edge |
| `src/middleware.ts` | Next.js with src-layout | Edge |
| `app/middleware.ts` | (rare) | Edge |

Other frameworks ship their own middleware abstraction (SvelteKit hooks, Remix loaders, Astro middleware) — those run as functions, not at the edge by default.

## Scope your matcher

Biggest mistake: unbounded `matcher`. Every match runs — billed to the edge function meter. Tight matcher saves money:

```ts
export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|robots.txt).*)"],
};
```

Or only on dynamic routes:

```ts
export const config = {
  matcher: ["/api/:path*", "/dashboard/:path*"]
};
```

## Common patterns

### 1) Bot block

```ts
const BOT_RE = /(bot|crawl|spider|scrapy|curl|httrack|wget|slurp)/i;
if (BOT_RE.test(req.headers.get("user-agent") ?? "")) {
  if (req.nextUrl.pathname.startsWith("/api/auth/")) {
    return new NextResponse("Forbidden", { status: 403 });
  }
}
```

Don't block bots universally — search engine crawlers are bots too. Whitelist by reverse DNS or use Cloudflare bot management upstream.

### 2) Rate limit

Use Upstash Ratelimit (edge-compatible):

```ts
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";
const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(60, "60 s")
});

const { success } = await ratelimit.limit(`auth:${req.ip}`);
if (!success) return new Response("Too many", { status: 429 });
```

Vercel KV (powered by Upstash) works too. Do not use an in-memory Map — instances are per-region and don't share state.

### 3) Geo routing / country block

Vercel injects `req.geo.country` (ISO code). Use sparingly — geo blocks are easy to bypass via VPN.

```ts
const blocked = new Set(["CU", "IR", "KP", "RU", "SY"]);
if (req.geo?.country && blocked.has(req.geo.country)) {
  return new Response("451", { status: 451 });
}
```

### 4) Auth at edge

Verify a session cookie before the request hits the function. Cuts cost on 401 paths:

```ts
const session = req.cookies.get("session")?.value;
if (!session && req.nextUrl.pathname.startsWith("/dashboard")) {
  const url = new URL("/login", req.url);
  url.searchParams.set("from", req.nextUrl.pathname);
  return NextResponse.redirect(url);
}
```

JWT verification at the edge needs a verify-key in env. Don't decode without verifying — anyone can craft a fake JWT.

## Edge runtime can't

| Limit | Detail |
|---|---|
| TCP databases | No socket support — use HTTP clients (Neon serverless, Supabase HTTP, Upstash REST) |
| Node APIs | No `fs`, `child_process`, native modules; `Buffer` partial. V8 + Web APIs only |
| Response body | ~1MB streamed cap |
| Timeout | ~30s, varies by plan |

## Cost footnote

Edge middleware bills per invocation. `matcher: ["/(.*)"]` on high-traffic sites dwarfs function cost. `state middleware` introspects the matcher; `state cost` tracks the bill.

## References

- https://vercel.com/docs/edge-network/edge-functions
- https://nextjs.org/docs/app/building-your-application/routing/middleware
- https://github.com/upstash/ratelimit
