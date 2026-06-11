# Vue on Vercel — best practices

Pure Vue 3 + Vite is treated like a SPA. For SSR, use Nuxt.

## SPA configuration

Same shape as `vite-spa.md` — Vercel auto-detects Vue, builds with Vite, serves `dist/`.

## SSR Vue without Nuxt

Don't. DIY Vue SSR is brittle on serverless and not worth the maintenance vs picking up Nuxt.

## Component-level concerns

- `v-html` is XSS-on-by-default. Sanitize with `DOMPurify` before binding untrusted HTML.
- `import.meta.env.VITE_*` ships to the browser — no credentials.

## Auth

Same as Vite SPA — no client secrets, OAuth + PKCE, sessions server-side.

## References

- https://vuejs.org/guide/best-practices/security
- https://vercel.com/docs/frameworks/vue
