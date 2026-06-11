## CATEGORY 64: Email design + accessibility

Emails render across Gmail / Outlook / Apple Mail / Yahoo / Thunderbird / mobile clients with widely varying CSS support. Designs that look great in the team's send-test render broken in Outlook. Beyond technical rendering: dark-mode handling, mobile responsiveness, accessibility (alt text on hero images, semantic HTML, focusable CTAs).

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. From Cat 61 inventory: read every email template.
2. For React Email templates: confirm the use of `@react-email/components` primitives (`<Html>`, `<Body>`, `<Container>`, `<Section>`, `<Text>`, `<Button>`, `<Img>`). These compile to email-client-safe HTML.
3. For raw HTML templates: check for table-based layout (the email standard, not div-based), inline CSS (most clients strip `<style>` blocks), max-width 600px container, image alt text, accessible color contrast.
4. Check for dark-mode support: `prefers-color-scheme` media query, `<meta name="color-scheme" content="light dark">`, or explicit dark-mode-aware color choices.

**Crawl mode, required tool calls:**

1. Skip with reason `email design audit requires template source; subscribe and inspect rendered messages for empirical review`.

### Forbidden claims

- "Outlook may render this badly." Either you tested or you're guessing.
- "Dark mode probably broken." Read the template; show the styling.
- "Images may lack alt." Quote the `<img>` or `<Img>` element.

### Detection

#### Source mode

For each template:

- **Layout primitive**: React Email components, MJML, or hand-built HTML tables? Each has known cross-client rendering behavior.
- **CSS**: inline styles (safe) vs `<style>` block (often stripped) vs class names that depend on external CSS (broken in most clients).
- **Image alt**: every `<img>` / `<Img>` should have alt text (Outlook on Windows shows alt prominently when images are blocked).
- **Container width**: max-width 600px is the email standard.
- **Dark mode**: `<meta name="color-scheme">` declared, dark-mode-aware colors (avoid pure white / pure black backgrounds), test with Apple Mail dark mode.
- **Plain-text version**: emails should ship with a text/plain alternative (most clients display HTML, but spam filters score multipart/alternative higher).

#### Crawl mode

Skip with reason.

### What to Search For

In email templates:

- `<table` (table-based layout, correct for email) vs `<div` (often broken in Outlook)
- `<style>` blocks (often stripped; prefer inline `style=`)
- `<Img` (React Email's safe image) vs raw `<img` (often blocked / unstyled)
- `prefers-color-scheme: dark` media query (dark mode aware)
- `<meta name="color-scheme" content="light dark">` (declares support)
- `.preheader`, `<Preview>` (preview-text element controlling inbox preview)

### Actually Hurts the Marketing Surface

- **Email uses `<div>` flexbox/grid layout instead of tables**.
  Evidence required: the layout pattern + Outlook's known table-only rendering.
- **CSS only in `<style>` block, none inlined**.
  Evidence required: `<style>` block + `<a>` / `<td>` elements without inline `style=` attributes.
- **Image with no alt attribute**.
  Evidence required: the `<img>` element.
- **No preview text** (`<Preview>` from React Email or hidden `<div>` with the preview-text content).
  Evidence required: template missing a Preview element.
- **Plain-text version not generated**.
  Evidence required: send call passes only HTML, no `text:` field.
- **Container >700px wide** (clipped on mobile).
  Evidence required: container max-width.
- **Dark-mode rendering broken** (white-on-white text in dark mode because backgrounds were swapped but text wasn't).
  Evidence required: color CSS + dark-mode-aware override absent.
- **Button is an `<a>` styled as a button without `display: inline-block` or table-cell wrapping** (renders as text link in some clients).
  Evidence required: the button's HTML.

### NOT a Problem

- React Email components used throughout, they handle most of the above automatically.
- Outlook-specific MSO conditional comments (`<!--[if mso]>`), required workarounds, not bugs.
- Static dark-mode images that look fine in both modes (e.g., logos with transparency).

### Context Check

1. Is the template in React Email / MJML / Postmark / SendGrid Template Engine? Each has different defaults.
2. Has the team tested in Litmus / Email on Acid / mailtrap? Without testing, "designed for email" is theoretical.
3. Is the audience mostly mobile or desktop? Mobile-first is the modern default.
4. Are images hosted on a domain with permissive caching / no rate limiting? Slow image hosting = images don't load in inbox preview.
5. Is the email triggered immediately (synchronous) or queued (async)? Sync sends often have less time for thorough rendering checks.

### Reference

Litmus email design best practices: https://www.litmus.com/community/learning/

React Email component documentation: https://react.email/docs/introduction

Email on Acid testing: https://www.emailonacid.com/

**Severity tagging:**

- Div-based layout (Outlook breaks) → High.
- CSS only in `<style>` block (most clients strip) → High.
- Image with no alt (Outlook with images blocked = empty box) → Medium.
- No preview text (inbox preview is wasted) → Medium.
- No plain-text version (deliverability hit + accessibility miss) → Medium.
- Dark mode broken → Medium.
- Container >700px → Medium.

**Fix voice:** `aarron-walter` (primary) | `brad-frost` (backup).

Read `souls/aarron-walter.json` before writing the Fix. Aarron's "designing for emotion" applies to email more than most surfaces, every transactional touch shapes how the user feels about the product.

Worked fix example:

> Standardize on React Email. The components compile to table-based, inline-styled, cross-client-safe HTML automatically. The team writes JSX; the library handles the Outlook quirks.
>
> ```tsx
> import { Html, Body, Container, Section, Text, Button, Img, Preview } from '@react-email/components';
>
> export function WelcomeEmail({ userName, dashboardUrl }: Props) {
>   return (
>     <Html lang="en">
>       <Preview>Welcome to Snitch. Here's what to do first.</Preview>
>       <Body style={{ backgroundColor: '#0a0a0a', color: '#f5f5f5', margin: 0 }}>
>         <Container style={{ maxWidth: '600px', margin: '0 auto', padding: '24px' }}>
>           <Img
>             src="https://snitchplugin.com/email/header.png"
>             alt="Snitch"
>             width={200}
>             height={40}
>           />
>           <Section style={{ padding: '24px 0' }}>
>             <Text style={{ fontSize: '16px', lineHeight: '24px' }}>
>               Hi {userName}, your account is ready.
>             </Text>
>             <Button
>               href={dashboardUrl}
>               style={{
>                 backgroundColor: '#dc2626',
>                 color: '#ffffff',
>                 padding: '12px 24px',
>                 borderRadius: '6px',
>                 textDecoration: 'none',
>                 display: 'inline-block',
>               }}
>             >
>               Open dashboard
>             </Button>
>           </Section>
>         </Container>
>       </Body>
>     </Html>
>   );
> }
> ```
>
> Test once in Litmus or send to a Litmus / Email-on-Acid test inbox to confirm rendering across Gmail / Outlook / Apple Mail. Once the template stabilizes, every send produces consistent, accessible, dark-mode-aware output without the team thinking about it again.
