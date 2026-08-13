# Next.js — ads-tracking best practices

## Pixel install

**App Router (Next 13+)**: `app/layout.tsx` `<head>`. Use `next/script` with `strategy="afterInteractive"` for non-critical, `"beforeInteractive"` only for consent default + CMP.

```tsx
import Script from "next/script";

export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        <Script id="consent-default" strategy="beforeInteractive">{`
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});
        `}</Script>
        <Script src="https://www.googletagmanager.com/gtag/js?id=G-XXX" strategy="afterInteractive" />
        <Script id="ga4" strategy="afterInteractive">{`
          window.gtag = window.gtag || function(){dataLayer.push(arguments)};
          gtag('js', new Date());
          gtag('config', 'G-XXX');
        `}</Script>
      </head>
      <body>{children}</body>
    </html>
  );
}
```

**Pages Router**: `pages/_document.tsx`. Plain `<script>` inside `<Head>`, OR `_app.tsx` `useEffect` for runtime injection.

## `@next/third-parties` for major platforms

```tsx
import { GoogleTagManager, GoogleAnalytics } from "@next/third-parties/google";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>{children}</body>
      <GoogleAnalytics gaId="G-XXX" />
      <GoogleTagManager gtmId="GTM-XXX" />
    </html>
  );
}
```

Ships optimal loading strategies. Covers Google + YouTube embeds + Maps + Meta Pixel.

## Server-side CAPI

Route Handler (`app/api/capi/<platform>/route.ts`) for App Router or `pages/api/capi/<platform>.ts` for Pages Router.

```ts
// app/api/capi/meta/route.ts
import { NextRequest, NextResponse } from "next/server";
import { sendMetaCapiEvent } from "@/lib/meta-capi";

export async function POST(req: NextRequest) {
  const body = await req.json();
  await sendMetaCapiEvent({ ... });
  return NextResponse.json({ ok: true });
}
```

**Edge runtime caveat**: edge can't use `node:crypto`. Use `crypto.subtle.digest("SHA-256", ...)` and HMAC via `crypto.subtle.sign`. Or `export const runtime = 'nodejs'`.

## CWV

- `next/image` with explicit `width` + `height` to prevent CLS.
- Mark above-the-fold images `priority`.
- Don't use `useEffect` to load pixels — `next/script` is canonical.
- Set `fetchpriority="high"` on the LCP image for ad-heavy pages.

## CSP / security headers

`headers()` in `next.config.js`. For nonce-based CSP, generate in `middleware.ts` and pass via `cspNonce` header. Vercel + Cloudflare Pages support edge middleware natively.

## Verification

`bash ads-ready.sh state site <url> pixels`, `state crux <url> mobile`, `score <url>`.
