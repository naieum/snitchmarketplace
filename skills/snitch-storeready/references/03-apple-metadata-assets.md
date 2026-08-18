# Apple metadata, assets, and age rating

When to read this: auditing App Store Connect listing fields, screenshots, icons, previews, the age-rating questionnaire, or preparing Review Notes.

Specs source: https://developer.apple.com/help/app-store-connect/reference/app-information/ and https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/ (sizes change with new device classes — verify before pixel-perfect work).

## Field limits

| Field | Limit | Notes |
|---|---|---|
| App name | 30 chars (min 2) | No prices, terms, platform names, or emoji abuse (2.3.7) |
| Subtitle | 30 chars | Same content rules as name |
| Keywords | 100 chars | Comma-separated; see rules below |
| Promotional text | 170 chars | The only field editable without a new version |
| Description | 4,000 chars | No prices; no other-platform references (2.3.10) |
| What's New | 4,000 chars | Must accurately describe the update (2.3.12) |

Keyword-field rules: do not repeat words already in the name or subtitle (wasted characters), do not use competitor or trademarked names, do not include category terms Apple already indexes, separate with commas and no spaces to maximize budget.

URLs: support URL is required and must work; privacy policy URL is required and must work; marketing URL is optional. A broken or placeholder URL is a 2.1 rejection. Static check: HTTP-fetch each URL and require a 200 with real content — see references/09-static-checks.md.

## Screenshots

- 1–10 per device class; JPG or PNG, no alpha.
- iPhone: the 6.9" size is required (1290×2796, 1320×2868, or 1260×2736, plus landscape variants) unless you provide 6.5" (1284×2778 or 1242×2688). Smaller sizes are optional and auto-scaled down.
- iPad: the 13" size is required (2064×2752 or 2048×2732).
- Other classes when the app supports them: Apple Watch 416×496-class, Mac 16:10 (1280×800 up to 2880×1800), Apple TV 1920×1080 or 3840×2160, Apple Vision Pro 3840×2160.
- Content rules: screenshots must show the actual app in use (2.3.3) — not splash screens, login walls, or pure marketing frames; suitable for a 4+ audience regardless of the app's rating (2.3.8); no other-platform UI (an Android status bar in a screenshot is a real rejection); no undisclosed IAP content presented as free (2.3.2).

## App previews

15–30 seconds, up to 3 per localization, H.264 or ProRes 422 HQ, ≤500 MB, ≤30 fps, device-resolution specific (886×1920 for modern iPhones). Screen captures of real app usage only (2.3.4) — no hands-on-device lifestyle footage.

## App icon

1024×1024 px PNG, sRGB, no alpha/transparency, delivered through the asset catalog (single-size since Xcode 14). iOS 18 dark/tinted variants and iOS 26 layered Liquid Glass icons (Icon Composer `.icon`) are optional — skipping them does not reject, but the auto-flattened fallback can look bad. Placeholder or template icons are a 2.1 rejection. Static check: AppIcon asset present, 1024 marketing slot filled, no alpha channel — see references/09-static-checks.md.

## Age rating — the new system

The tiers are now 4+, 9+, 13+, 16+, 18+ (the old 12+/17+ tiers are retired). The questionnaire expanded: in-app controls, capabilities, medical/wellness content, violent themes. Apps that had not answered the updated questions were blocked from submitting updates after January 31, 2026 (current as of 2026-08 — verify at https://developer.apple.com/news/). Answer honestly: understating triggers a 2.3.6 metadata rejection, and 18+ apps must hook regional age-verification where local law mandates it. The rating must also account for ads shown in the app.

Accessibility Nutrition Labels launched in 2025 and remain voluntary; Apple has signaled an eventual mandate with no confirmed deadline (verify at https://developer.apple.com/help/app-store-connect/manage-app-accessibility/manage-accessibility-nutrition-labels).

## Review Notes and demo account

Required for any login-gated functionality (2.1(a)): a working demo account with credentials in App Review Information, valid against the production backend for the whole review window. Also put in Notes:

- Special configuration steps, region-locked content, and how the reviewer can reach it.
- Hardware-paired features: a demo video showing the app working with the device.
- Non-obvious IAPs: where they surface and why.
- Regulated categories: licenses for gambling, VPN, banking, crypto; regulatory clearance for medical hardware; ad-SDK policies for kids apps.
- Use fictional account data in metadata and screenshots (2.3.9).

## Common metadata rejections, condensed

1. Screenshots showing splash/login/marketing instead of the app (2.3.3).
2. Other-platform mentions or UI anywhere in metadata (2.3.10).
3. "Beta", "demo", "test" in name or description (2.2).
4. Keyword stuffing in the name, prices in the name ("free" is a standing risk under 2.3.7).
5. Wrong category for what the app does (2.3.5).
6. Dishonest age-rating answers (2.3.6).
7. Metadata describing features the build does not contain (2.3.1).
