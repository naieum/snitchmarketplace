// middleware.ts — snitch-vercel starter
// Runs on Vercel Edge for every matched request. Trim the matcher to scope cost.
//
// Combines:
//   1) Bot block (deny common crawlers/scrapers from sensitive routes)
//   2) Rate limiter (Upstash REST, edge-compatible)
//   3) Geo routing (block embargoed countries; surface country header to app)
//   4) Auth gate at edge (verify session cookie before invoking the function)

import { NextRequest, NextResponse } from "next/server";
// import { Ratelimit } from "@upstash/ratelimit";
// import { Redis } from "@upstash/redis";

export const config = {
  // Restrict the matcher — running middleware on every asset is costly.
  matcher: ["/((?!_next/static|_next/image|favicon.ico|robots.txt).*)"],
};

const BOT_USER_AGENT_REGEX = /(bot|crawl|spider|scrapy|curl|httrack|wget|slurp)/i;
const BLOCKED_COUNTRIES = new Set<string>([
  // Add ISO-3166 codes you must block per legal/business policy.
  // "RU", "IR", "KP", "CU", "SY"
]);

// const ratelimit = new Ratelimit({
//   redis: Redis.fromEnv(),
//   limiter: Ratelimit.slidingWindow(60, "60 s"),
// });

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  const country = req.geo?.country ?? "";
  const ua = req.headers.get("user-agent") ?? "";
  const ip = req.ip ?? req.headers.get("x-forwarded-for") ?? "0.0.0.0";

  // 1) Country block.
  if (country && BLOCKED_COUNTRIES.has(country)) {
    return new NextResponse("Service unavailable in your region.", { status: 451 });
  }

  // 2) Bot block on sensitive routes only.
  if (
    pathname.startsWith("/api/auth/") ||
    pathname.startsWith("/api/checkout/") ||
    pathname === "/login" ||
    pathname === "/signup"
  ) {
    if (BOT_USER_AGENT_REGEX.test(ua)) {
      return new NextResponse("Forbidden", { status: 403 });
    }
  }

  // 3) Rate limit POSTs to /api/auth/*.
  if (req.method === "POST" && pathname.startsWith("/api/auth/")) {
    // const { success } = await ratelimit.limit(`auth:${ip}`);
    // if (!success) {
    //   return new NextResponse("Too Many Requests", { status: 429 });
    // }
  }

  // 4) Auth at edge: check session cookie before letting the request through.
  if (pathname.startsWith("/dashboard")) {
    const session = req.cookies.get("session")?.value;
    if (!session) {
      const url = new URL("/login", req.url);
      url.searchParams.set("from", pathname);
      return NextResponse.redirect(url);
    }
  }

  // Forward country to the app via header for downstream geo logic.
  const res = NextResponse.next();
  if (country) res.headers.set("x-snitch-vercel-country", country);
  return res;
}
