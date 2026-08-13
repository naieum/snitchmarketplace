# WordPress — ads-tracking best practices

## Pixel install

`wp_head` action is the canonical hook. Child-theme `functions.php`:

```php
add_action('wp_head', function () {
  ?>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});
  </script>
  <script async src="https://www.googletagmanager.com/gtag/js?id=<?php echo esc_js(GA4_ID); ?>"></script>
  <script>
    window.gtag = window.gtag || function(){dataLayer.push(arguments)};
    gtag('js', new Date());
    gtag('config', '<?php echo esc_js(GA4_ID); ?>');
  </script>
  <?php
}, 1);
```

Priority `1` ensures it runs before plugin-injected scripts so consent default beats other pixels.

## Plugins (realistic path)

| Plugin | Coverage | Notes |
|---|---|---|
| **Site Kit by Google** | GA, Google Ads, Search Console | Official Google plugin |
| **PixelYourSite** | Meta, Google, TikTok, Pinterest, Bing, LinkedIn | Multi-platform; Pro covers e-commerce |
| **Pixel Caffeine (free)** | Meta only | Simple |
| **MonsterInsights** | GA4 | E-commerce friendly; free + Pro |
| **GTM4WP** | Google Tag Manager | Best for GTM-committed teams |

Don't run more than ONE multi-platform pixel plugin — they inject duplicate snippets and double-count.

## CAPI on WordPress

Two paths:

1. **Plugin-managed.** PixelYourSite Pro and Conversios have Meta CAPI built-in. Easiest.
2. **Custom plugin.** Hook `woocommerce_thankyou` (or CRM webhook), POST to a tiny PHP endpoint that signs and forwards. Adapt patterns from `templates/capi-stubs/<platform>/python.template` to PHP.

## CWV (the hard part)

WP sites have the WORST CWV of any stack on average — page-builder bloat, plugin JS, theme jQuery. To get GREEN:

1. Lightweight theme: GeneratePress, Astra, Kadence, Blocksy. Avoid Avada, Divi, Elementor with default settings.
2. Cache: Cloudflare APO + a single object cache plugin (Redis Object Cache or W3 Total Cache). Don't stack four caching plugins.
3. Optimize images: ShortPixel or Smush + WebP/AVIF.
4. Reduce plugin count below 25.
5. Lazy-load below-the-fold images.
6. Critical CSS plugin (Autoptimize or WP Rocket) for above-the-fold.

## Security headers

Apache via `.htaccess`:

```apache
<IfModule mod_headers.c>
  Header set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
  Header set X-Content-Type-Options "nosniff"
  Header set Referrer-Policy "strict-origin-when-cross-origin"
</IfModule>
```

Nginx: `server { ... }` block. On Cloudflare: use Transform Rules — easier and survives WP migrations.

## ads.txt placement

Drop `ads.txt` at the WordPress root. Webserver serves before WordPress; no plugin needed.

## Verification

`bash ads-ready.sh state site <url>`, `state lighthouse <url>` — WP sites typically score 50-70 untuned, 80-90 well-tuned.
