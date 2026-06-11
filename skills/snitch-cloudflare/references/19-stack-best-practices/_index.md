# 19 — Stack Best Practices Index

Registry mapping detected stacks to canonical doc URLs. `lib/stacks.sh` emits stack names; `refresh-docs` keeps URLs current.

| Stack | File | CF integration | Framework docs |
|---|---|---|---|
| nextjs | `nextjs.md` | https://developers.cloudflare.com/pages/framework-guides/nextjs/ | https://nextjs.org/docs |
| astro | `astro.md` | https://developers.cloudflare.com/pages/framework-guides/deploy-an-astro-site/ | https://docs.astro.build |
| sveltekit | `sveltekit.md` | https://developers.cloudflare.com/pages/framework-guides/deploy-a-svelte-kit-site/ | https://kit.svelte.dev/docs |
| remix | `remix.md` | https://developers.cloudflare.com/pages/framework-guides/deploy-a-remix-site/ | https://remix.run/docs |
| nuxt | `nuxt.md` | https://developers.cloudflare.com/pages/framework-guides/deploy-a-nuxt-site/ | https://nuxt.com/docs |
| vite-spa | `vite-spa.md` | https://developers.cloudflare.com/pages/framework-guides/deploy-a-react-site/ | https://vite.dev |
| workers-native | `workers-native.md` | https://developers.cloudflare.com/workers/ | n/a |
| pages-static | `pages-static.md` | https://developers.cloudflare.com/pages/configuration/build-configuration/ | n/a |
| hono | `hono.md` | https://developers.cloudflare.com/workers/frameworks/framework-guides/hono/ | https://hono.dev |
| express | `express.md` | https://developers.cloudflare.com/workers/runtime-apis/nodejs/ | https://expressjs.com |
| fastify | `fastify.md` | https://developers.cloudflare.com/workers/runtime-apis/nodejs/ | https://fastify.dev/docs |
| nestjs | `nestjs.md` | (no first-class CF support) | https://docs.nestjs.com |
| wordpress | `wordpress.md` | https://developers.cloudflare.com/learning-paths/get-started-free/ | https://developer.wordpress.org |
| laravel | `laravel.md` | (proxy-only via Tunnel) | https://laravel.com/docs |
| rails | `rails.md` | (proxy-only via Tunnel) | https://guides.rubyonrails.org |
| django | `django.md` | (proxy-only via Tunnel) | https://docs.djangoproject.com |
| flask | `flask.md` | (proxy-only via Tunnel) | https://flask.palletsprojects.com |
| spring-boot | `spring-boot.md` | (proxy-only via Tunnel) | https://spring.io/projects/spring-boot |
| dotnet | `dotnet.md` | (proxy-only via Tunnel) | https://learn.microsoft.com/en-us/aspnet/core/ |

Verdicts:

| Stack | Verdict |
|---|---|
| nextjs, astro, sveltekit, remix, nuxt, vite-spa, hono, workers-native, pages-static | strong |
| express, fastify, nestjs | partial (native modules + long-lived connections) |
| wordpress, laravel, rails, django, flask, spring-boot, dotnet | proxy-only |

Overlay sources: `templates/csp-stack-overlays.json` (CSP per stack), `templates/waf-stack-profiles.json` (WAF foreign-tech), `templates/stack-docs-registry.json` (doc URLs).

Files in this directory are CF-specific overlay only — framework basics live in framework docs (fetched via `stack-docs` URLs).
