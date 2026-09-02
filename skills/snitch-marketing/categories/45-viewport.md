## CATEGORY 45: Viewport meta

`<meta name="viewport" content="width=device-width, initial-scale=1">` tells mobile browsers to render the page at the device's actual width instead of a 980px-wide desktop simulation that the user has to pinch-zoom. Missing it = unusable on mobile = mobile-first index demotes you.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `name="viewport"`, `name='viewport'`. Quote each match.
2. Check the `content` attribute. Standard: `width=device-width, initial-scale=1`.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Quote the `<meta name="viewport">` element from head.

### Forbidden claims

- "Viewport may be missing." Quote present-or-absent.
- "Viewport may be misconfigured." Quote the content value.

### Detection

`<meta name="viewport">` in head.

### What to Search For

- `name="viewport"`, `name='viewport'`
- Common content values: `width=device-width, initial-scale=1`, `width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no`

### Actually Hurts SEO

- **No viewport meta tag**.
  Evidence required: head quoted with no viewport tag.
- **Viewport with `user-scalable=no` or `maximum-scale=1`** (a11y violation; users can't zoom).
  Evidence required: viewport content attribute quoted.
- **Viewport with `width=1024` or other fixed pixel value**.
  Evidence required: content attribute.

### NOT a Problem

- `width=device-width, initial-scale=1`, standard correct value.
- Adding `viewport-fit=cover` for iPhone notch handling, fine.
- Adding `user-scalable=yes`, explicit; default is yes anyway.

### Context Check

1. Does the framework auto-emit viewport? Most modern frameworks do (Next.js root layout includes it by default).
2. Is the site mobile-friendly otherwise? Viewport is necessary but not sufficient.
3. Are there a11y testing patterns running? `user-scalable=no` would be flagged by them too.

### Reference

MDN on viewport meta: https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag

**Severity tagging:**
- No viewport meta → Critical (mobile broken).
- `user-scalable=no` → High (a11y violation).
- Fixed pixel width → High.

**Fix voice:** `intrinsic-web-engineer` (primary) | `usability-scientist` (backup).

Read `souls/intrinsic-web-engineer.json` before writing the Fix. The intrinsic-web position: pages should size themselves to the device, not force the device to scale.

Worked fix example:

> One line in the head, every page, every site, no exceptions.
>
> ```html
> <meta name="viewport" content="width=device-width, initial-scale=1">
> ```
>
> Don't disable user scaling. Don't fix the width. The intrinsic web sizes itself to whatever surface it's on, a phone, a tablet, a 4K monitor. Viewport meta gives it the permission to do that.
