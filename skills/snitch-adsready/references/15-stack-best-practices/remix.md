# Remix — ads-tracking best practices

## Pixel install

`app/root.tsx` — Remix's root component renders the `<html><head>` shell.

```tsx
import { Links, LiveReload, Meta, Outlet, Scripts, ScrollRestoration } from "@remix-run/react";

export default function App() {
  return (
    <html lang="en">
      <head>
        <Meta />
        <Links />
        <script dangerouslySetInnerHTML={{ __html: `
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});
        ` }} />
        <script async src={`https://www.googletagmanager.com/gtag/js?id=${process.env.PUBLIC_GA_ID}`} />
        <script dangerouslySetInnerHTML={{ __html: `
          window.gtag = window.gtag || function(){dataLayer.push(arguments)};
          gtag('js', new Date());
          gtag('config', '${process.env.PUBLIC_GA_ID}');
        ` }} />
      </head>
      <body>
        <Outlet />
        <ScrollRestoration />
        <Scripts />
        <LiveReload />
      </body>
    </html>
  );
}
```

For SPA-style page-view fires, use `useLocation` in a top-level layout and call `gtag('config', id, { page_path })` on change.

## Server-side CAPI

Loaders + actions run server-side, perfect for CAPI bridging. Add `app/routes/capi.$platform.tsx`:

```ts
import type { ActionFunctionArgs } from "@remix-run/node";
import { json } from "@remix-run/node";
import { sendMetaCapiEvent } from "~/lib/meta-capi";

export async function action({ request, params }: ActionFunctionArgs) {
  const body = await request.json();
  switch (params.platform) {
    case "meta":
      await sendMetaCapiEvent({ ... });
      break;
  }
  return json({ ok: true });
}
```

Cloudflare Pages adapter caveat: use Web Crypto, not `node:crypto`.

## CWV

- Use `<Form>` for POSTs; fewer client roundtrips.
- Loaders run on the server; ship minimal JSON.
- Defer slow loaders with `defer()` so shell paints first.
- For LCP element, set `<img fetchpriority="high">` — Remix doesn't auto-do this.

## Verification

`state site` + `state crux` + `score`.
