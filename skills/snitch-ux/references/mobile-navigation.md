# Mobile Bottom Navigation — Hard Rules

The bottom bar is the app's backbone and one of the most-tapped areas on the screen.
Every icon, label, color, and state is a deliberate decision. Read this before designing
or reviewing any bottom tab bar / mobile nav.

This file governs the **mobile component**. For **site-level** information architecture —
persistent nav, page names, "you are here," breadcrumbs, tabs, the parachute test, and the
home-page big picture — see `site-navigation.md`.

## What goes in it

- **Only the most essential, most-frequent destinations.** Good candidates: home / feed /
  dashboard, search / discover, add / create, messages / notifications, profile / account.
- **Keep low-frequency items out.** Help, log out, legal (privacy/terms), settings sub-pages
  → move to Profile or a menu. Nobody needs "log out" at their fingertips.
- **Don't mix in top-nav elements** (back/forward, logos). It breaks the familiar pattern
  (Jakob's Law) and confuses users.
- **A center CTA is a smart addition** for a primary create/post/order action — it stands
  out *and* sits in the most reachable spot.

## Counts & sizing

- **3–5 tabs (6 max).** More causes choice paralysis and shrinks each target.
- **Tap target ≥ 44×44px** (average thumb). 24×24 is too small → mistaps.
- **Icon ~24px** — recognizable without dominating.
- **Labels 10–12px**, concise, **single line** (never wrap to two).
- **Respect the safe area** — keep the bar above the home indicator with breathing room;
  never overlap or hide it, or users trigger the system swipe by accident.
- **Design for 2–3 device widths**; prefer a compact bar (a bulky one eats content space).

## Active vs inactive state

- **Apply at least TWO visual changes** to the active tab — changing only the text isn't
  distinct enough. Combine: color shift + bolder label, and/or a filled highlight.
- **Outline → filled icon** is a great active cue (the one allowed exception to a
  consistent icon style). If your icon set has no filled variants, use a **filled
  highlight pill / indicator bar** behind the active icon instead.
- Keep **inactive** states legible — prefer slightly reduced opacity over a drastically
  different color; meet **WCAG 3:1** minimum contrast for UI/graphical elements.

## Icons, color, labels

- **Simple, universally familiar icons** mapped to function (magnifying glass = search,
  not binoculars). Avoid clever/artistic interpretations.
- **Consistent icon style & complexity** across tabs (all outline or all filled), except
  the selected state.
- **Neutral nav colors** (white / gray / dark). Don't give each tab its own color — it's
  visual chaos and hurts brand recognition. Reserve bright/primary colors for key actions
  on the *content* area so they stand out.
- **No boxes / visual noise** around tabs.

## The most-overlooked mistake

- **Separate the bar from content.** Add a subtle 1px border / soft top shadow, or a
  slightly different background. Without separation the bar floats ambiguously into content.

## Badges

- Use **sparingly**, only for essential notifications (badge fatigue is real).
- Small-but-noticeable, **top-right of the icon**, readable, contrasting yet on-brand
  (optionally outlined to lift it off the icon).

## Polish (after fundamentals are solid)

- Tap feedback (color/scale/ripple), animated tab transitions (sliding underline, smooth
  icon movement), soft screen transitions (fade/slide).
- Creative layouts (shapes, a raised center action) can make an app memorable — but
  **never sacrifice usability for aesthetics**.
