# Stack hardening: React / Next.js

Loaded when stack detection identifies React or Next.js (`react`, `next` in `package.json`,
`app/`/`pages/` routers, `.tsx`). The defining trait: **React auto-escapes JSX**, so most rendered
output is safe — the sinks are the specific escape hatches plus the *server* surface (API routes,
route handlers, Server Actions) which is real backend code.

## Where the sinks are (trace these — Rule 7)

| Pattern | Risk | Cat |
|---|---|---|
| `dangerouslySetInnerHTML={{__html: userInput}}` | XSS | 02 |
| `href`/`src = userInput` allowing `javascript:` / `data:` | XSS / open redirect | 02 / 05 |
| Secrets in `NEXT_PUBLIC_*` env, or in client components | secret exposure to browser | 03 / 12 |
| **Server Actions** (`"use server"`) without authZ inside | broken access control (they are public endpoints) | 28 / 04 |
| Next API routes / route handlers: SQL, `fetch(userURL)`, `fs` path, `exec` | SQLi / SSRF / path / cmdi | 01 / 05 / 29 / 10 |
| Route-handler / API input used without validation | input validation | 30 / 44 |
| `redirect(userInput)` / `NextResponse.redirect` to user URL | open redirect | 05 |

## Framework auto-protections (do NOT flag these)

- **JSX text interpolation `{userValue}` is auto-escaped** — not XSS. Only `dangerouslySetInnerHTML`,
  URL/attribute injection, and dangerous props are sinks (02). Don't flag normal `{value}` rendering.
- Server/client boundary: code in `"use client"` runs in the browser (so secrets there leak);
  server components / actions / route handlers are backend (real authZ + injection surface).
- Next sets some headers; a full CSP + the rest still needs config (32).

## Hardening checklist

- **Treat every Server Action and route handler as a public, unauthenticated endpoint** until it
  checks authN + authZ server-side — the client cannot be trusted to gate them (28, 04).
- Never ship secrets to the client: no real secret in `NEXT_PUBLIC_*` or imported into a client
  component (03, 12).
- Sanitize any `dangerouslySetInnerHTML` (e.g., DOMPurify) and validate URL schemes for
  user-controlled `href`/`src` (02).
- Validate all route-handler/action input with a schema (30); parameterize server-side queries (01);
  guard server-side `fetch` against SSRF (05).
- Set a CSP and security headers (32); scope CORS on route handlers (08).

## Forbidden claims

- Flagging ordinary `{userValue}` JSX as XSS — it's auto-escaped (02).
- Assuming a Server Action is "internal" — it's a callable endpoint; require server-side authZ
  evidence before passing it (28).
- Calling an env var a leaked secret without confirming it's `NEXT_PUBLIC_*` or reaches a client
  bundle (03/12, Rule 1).

---

*Per-stack reference informed by codex-security's curated best-practices model; reimplemented
evidence-first/defensive, cross-referenced to snitch's category numbers. Internal reference.*
