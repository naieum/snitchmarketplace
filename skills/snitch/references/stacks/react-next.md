# Stack hardening: React / Next.js

Loaded when stack detection identifies React or Next.js (`react`, `next` in `package.json`,
`app/`/`pages/` routers, `.tsx`). The defining trait: **React auto-escapes JSX**, so most rendered
output is safe — the sinks are the specific escape hatches plus the *server* surface (API routes,
route handlers, Server Actions) which is real backend code.

## Where the sinks are (trace these — Rule 7)

| Pattern | Risk | Cat |
|---|---|---|
| React's raw-HTML prop (the `dangerously` + `SetInnerHTML` prop) fed user input | XSS | 02 |
| `href`/`src = userInput` allowing `javascript:` / `data:` | XSS / open redirect | 02 / 05 |
| A real secret in any module reachable from a `"use client"` import graph — **prefix irrelevant** | secret crosses to the browser | 03 / 12, CWE-200 |
| `process.env.NEXT_PUBLIC_*` **read** holding a non-public credential | inlined into the bundle at build | 03 / 12, CWE-200 |
| **Server Actions** (`"use server"`) without authZ inside | broken access control (they are public endpoints) | 28 / 04 |
| Next API routes / route handlers: SQL, `fetch(userURL)`, `fs` path, `exec` | SQLi / SSRF / path / cmdi | 01 / 05 / 29 / 10 |
| Route-handler / API input used without validation | input validation | 30 / 44 |
| `redirect(userInput)` / `NextResponse.redirect` to user URL | open redirect | 05 |

## Framework auto-protections (do NOT flag these)

- **JSX text interpolation `{userValue}` is auto-escaped** — not XSS. Only React's raw-HTML prop,
  URL/attribute injection, and dangerous props are sinks (02). Don't flag normal `{value}` rendering.
- Server/client boundary: code in `"use client"` runs in the browser (so secrets there leak);
  server components / actions / route handlers are backend (real authZ + injection surface).
  **`"use client"` is transitive.** It marks a boundary, not a file: everything the annotated module
  imports, and everything *those* import, is pulled into the browser bundle. A secret two hops down
  a `lib/` chain is as exposed as one written in the component. This is why a secret module's own
  text can never decide the question — build the importer graph and look for the boundary.
- Next sets some headers; a full CSP + the rest still needs config (32).

## Hardening checklist

- **Treat every Server Action and route handler as a public, unauthenticated endpoint** until it
  checks authN + authZ server-side — the client cannot be trusted to gate them (28, 04).
- Never ship secrets to the client. Two separate checks, both required: no non-public credential in
  a `process.env.NEXT_PUBLIC_*` read, **and** no real secret in any module a `"use client"` graph
  imports, whatever it is named (03, 12 — see the exposure/inlining split under Forbidden claims).
- Sanitize anything passed to React's raw-HTML prop (e.g., DOMPurify) and validate URL schemes for
  user-controlled `href`/`src` (02).
- Validate all route-handler/action input with a schema (30); parameterize server-side queries (01);
  guard server-side `fetch` against SSRF (05).
- Set a CSP and security headers (32); scope CORS on route handlers (08).

## Forbidden claims

- Flagging ordinary `{userValue}` JSX as XSS — it's auto-escaped (02).
- Assuming a Server Action is "internal" — it's a callable endpoint whose id is discoverable in the
  client bundle; require server-side authZ evidence before passing it (28). Category 28 does not
  cover Server Actions, so this file is the only place that says so — carry it into the finding.
- Treating "rendered inside the client tree" as the boundary test. In App Router the `"use client"`
  directive is the boundary: a server component passed as `children` into a client component is
  *not* bundled. Trace the import graph, not the render tree.
- Conflating the **exposure** question with the **inlining mechanism**. They are two rules and
  collapsing them into one test gets two of three cases wrong:

  **Rule A — exposure (what decides the finding).** A real secret in a module reachable from a
  `"use client"` import graph has crossed the boundary. **The prefix is irrelevant here.** An
  unprefixed `process.env.RESEND_API_KEY` imported by a client component is a finding; report it.

  **Rule B — inlining (what decides the severity and the claim you may make).** Only
  `process.env.NEXT_PUBLIC_*` *reads* are substituted into the bundle at build time. So:
  - prefixed **and** client-reachable → the literal value ships. State that plainly.
  - unprefixed **and** client-reachable → resolves to `undefined` in the browser under stock config,
    so the boundary is broken but disclosure is not proven. Report the crossing at Medium with the
    live value present during SSR, one config edit (`next.config.js` `env:`, which inlines *any*
    variable regardless of prefix) or one Pages-Router consumer away from shipping. Do **not** claim
    "the key is in the client bundle" — a developer who greps the chunk, finds nothing, and stops
    trusting the report is a worse outcome than the finding.
  - a variable merely *named* `NEXT_PUBLIC_FOO`, or `const NEXT_PUBLIC_KEY = "..."`, is a plain
    identifier that ships nothing. Renaming it is not a fix, and "remove the prefix" as
    remediation leaves the reader believing a leak was closed that never existed.

  **Not every `NEXT_PUBLIC_*` read is a finding.** Publishable, anon and write-only keys are
  *designed* to be public — Stripe `pk_*`, Supabase anon, Clerk publishable, analytics write keys.
  Reporting those is a wasted fix cycle that costs you credibility on the one that matters. The
  heuristic when the vendor has no dedicated category: a `NEXT_PUBLIC_` variable whose name contains
  `ADMIN`, `SECRET`, `SERVICE`, `PRIVATE` or `TOKEN`, or that grants cross-user read or any write
  beyond its own telemetry, is High regardless of vendor. Grade by what the credential can do.

---

*Per-stack reference informed by codex-security's curated best-practices model; reimplemented
evidence-first/defensive, cross-referenced to snitch's category numbers. Internal reference.*
