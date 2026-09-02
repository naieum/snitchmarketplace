# Webflow — ads-tracking best practices

## Pixel install

Project Settings → Custom Code → Head Code:

```html
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});
</script>

<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXX"></script>
<script>
  window.gtag = window.gtag || function(){dataLayer.push(arguments)};
  gtag('js', new Date());
  gtag('config', 'G-XXX');
</script>
```

Per-page tracking via Page Settings → Inside `<head>` tag.

## Limitations

| Limitation | Impact | Workaround |
|---|---|---|
| No native server-side / CAPI | Can't run a backend without leaving Webflow | Bridge via Make.com, Zapier, n8n, or a separate Cloudflare Worker triggered on form submission webhook |
| No native consent management | GDPR/CCPA risk | Webflow Cookie Consent (basic) OR external CMP (Cookiebot, CookieYes) |
| Schema.org JSON-LD must be hand-coded | Tedious for many pages | Page-level Custom Code; or Webflow CMS bindings for templated pages |
| Limited control over response headers | CSP / HSTS hard to set | Place site behind Cloudflare; Transform Rules at proxy |
| No GTM Server-side support | Client-side only | Bridge via Worker pattern above |

## CMS bindings for Product / Offer markup

Webflow CMS can interpolate field values into Custom Code — the way to keep feed markup bound to
the product record instead of typed by hand (field slugs vary by collection):

```html
<script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Product",
    "name": "{{ wf {&quot;path&quot;:&quot;name&quot;,&quot;type&quot;:&quot;PlainText&quot;} }}",
    "sku": "{{ wf {&quot;path&quot;:&quot;sku&quot;,&quot;type&quot;:&quot;PlainText&quot;} }}",
    "image": "{{ wf {&quot;path&quot;:&quot;main-image&quot;,&quot;type&quot;:&quot;Image&quot;} }}",
    "offers": {
      "@type": "Offer",
      "price": "{{ wf {&quot;path&quot;:&quot;price&quot;,&quot;type&quot;:&quot;Number&quot;} }}",
      "priceCurrency": "{{CURRENCY_ISO}}",
      "availability": "https://schema.org/InStock"
    }
  }
</script>
```

Tedious but functional. Bind price to the same field checkout charges from — a literal drifts from
the feed and gets the item disapproved. Article, Person, Organization, and the rest of the schema
surface are evidenced against search, not against an ad platform: **call the Skill tool with
"snitch-marketing"** for those.

## CWV

Webflow sites score 70-90 typically. Improve by:

1. Compress hero images via Webflow's image optimization.
2. `loading="lazy"` on below-the-fold images (Webflow does this by default).
3. Self-host fonts (avoid Adobe Fonts CDN bottleneck).
4. Disable unused interactions / animations on landing pages.

## Verification

`bash ads-ready.sh state site <url>`. Webflow pixel diagnostics: use platform helpers (Tag Assistant, Pixel Helper).
