## CATEGORY 75: Brand consistency across channels

Same name, same logo, same one-line description, same color palette, same voice, across every surface (site, social profiles, email signatures, app store listings, OG cards, favicons, ads). Inconsistency confuses users and weakens recognition.

### Pre-flight: surface inventory

Inventory all brand surfaces. Need ≥3 to make consistency meaningful. If only the site exists (no social, no apps, no listings), **Skip** with reason `single brand surface; consistency check requires multi-surface presence, revisit after channels are established`.

### Evidence required (do not skip, only when ≥3 surfaces)

**Crawl mode, required tool calls:**

1. From STEP 0.6 brand maturity check: list every surface where the brand appears (site, social profiles, app stores, review platforms, GitHub org, etc.).
2. For each: capture brand name spelling, primary color (hex if extractable), logo (svg/png URL), one-line description.
3. Compare across surfaces. Inconsistencies are findings.

**Source mode, required tool calls:**

1. `Grep` site for hardcoded brand strings ("Snitch", "Atlas", etc.). Identify variants ("Snitch Plugin" vs "Snitch" vs "snitch.live" vs "snitchplugin.com").
2. `Grep` for brand color hex codes. Identify variants.
3. `Read` `package.json` `name` field; compare to displayed brand name.

### Forbidden claims

- "Brand may be inconsistent." Show specific spellings / colors / descriptions across surfaces.

### Detection

Multi-surface comparison.

### What to Search For

Across surfaces:
- Brand name (exact spelling)
- Primary brand color
- Logo file
- One-line description / tagline
- Social handle (`@brand`)

Typography signal patterns:
- Numeric data rendered in monospace / tabular-numeral fonts (signals "data, not vibes")
- Editorial section markers (§, →, —, ·) used as visual organizers in section labels
- Section label conventions ("§ HIRES YOU'LL MAKE", "— PRICING", "→ NEXT STEP")
- Heading hierarchy uses font-weight contrast, not just size, for B2B-density layouts

### Voice-anchor DNA (load-bearing for multi-channel brands)

Beyond logo + color + name, the brand's *voice* should be consistent across surfaces. Voice anchors are short, locked copy lines — usually 3-7 of them — that recur identically across the homepage, GBP service descriptions, paid-ads creative, Nextdoor / community profiles, email signatures, and social bios. Anchors carry the brand's distinct cadence; their absence or inconsistency reads as multiple companies with the same name.

Examples (placeholders; re-implement in the brand's actual voice):

- "Family-owned since {year}."
- "We answer the phone. A person, in {city}."
- "Same crew, every visit."
- "If we install it, we stand behind it."
- "No subcontractors."

Audit steps:

1. Read the brand's strongest existing surface (usually the homepage hero + about page). Identify 3-7 short locked phrases that recur and carry brand voice.
2. Check adjacent surfaces — GBP service descriptions, GBP Posts, paid-ads creative (Meta Ad Library), Nextdoor profile, email signatures, social bios — for whether those anchors appear.
3. Findings:
   - **Anchors exist on the homepage but appear on zero other surfaces.** The brand has a voice and isn't propagating it. High.
   - **Anchors appear but in inconsistent paraphrasings across surfaces.** ("Family-owned since 2010" vs "A family business for over a decade" vs "We've been doing this 14 years.") The voice fragments across channels. Medium.
   - **No identifiable voice anchors on the homepage at all.** The brand hasn't done the work to define a voice. Medium (and a Cat 81 positioning concern; cross-reference).

The audit doesn't dictate WHICH anchors the brand should pick; it surfaces whether the brand has anchors and whether they propagate. Anchor selection is the brand's choice; consistency is the audit's concern.

Cross-references `references/local-services-playbook.md` for the local-services anchor patterns; cross-references Cat 81 (positioning) when the brand has no anchors because positioning is fuzzy upstream.

### Actually Hurts the Marketing Surface

- **Brand name spelled differently across surfaces** ("Snitch" vs "snitchplugin" vs "Snitch Security").
  Evidence required: list of surfaces + spelling per surface.
- **Different primary colors** on site vs app icon vs social banner.
  Evidence required: hex codes per surface.
- **Different one-line descriptions** across site / social bios / app store.
  Evidence required: descriptions quoted per surface.
- **Logo variants without a "primary" defined** (different proportions, colors, treatments across surfaces).
  Evidence required: logo URLs.
- **Social handle inconsistent** (`@snitchplugin` on X, `@snitch_plugin` on LinkedIn, `@snitch-security` on GitHub).
  Evidence required: handles per platform.
- **Numbers rendered in body proportional font on data-heavy marketing pages** (case study metrics, pricing tables, dashboards in screenshots). Proportional digits read as decorative; mono / tabular digits read as data.
  Evidence required: data section with proportional-font numerics.
  Severity: Low (aesthetic, not functional; but cumulatively credibility-eroding for B2B data brands).
- **No editorial markers / section conventions** on a content-heavy marketing page (every section label is plain text, no typographic system).
  Evidence required: page with 5+ sections, no marker convention.
  Severity: Low.

### NOT a Problem

- Platform-specific image dimensions (square avatar, banner, OG image). Same brand, different sizes.
- Light / dark mode logo variants. Intentional.
- Localized descriptions for different markets. Intentional.
- Proportional numerals on hero pages where numbers are decorative ("Founded 2019" in a footer). Not the same as case-study metric display.
- Sites that use only minimal typography (lots of whitespace, no markers) by deliberate design choice. Don't impose editorial conventions where they conflict with the brand voice.

### Context Check

1. Is there a brand-guidelines doc (in source / Notion / GitHub)? Reference it.
2. Are surfaces controlled by the same team or different teams (some brands have separate community managers per platform)?
3. Are old logos lingering on stale surfaces (a redesign that didn't propagate)?

### Reference

Frontify on brand consistency: https://www.frontify.com/en/guide/brand-consistency/

**Severity tagging:**
- Brand name inconsistency across surfaces → High.
- Logo variants without primary defined → Medium.
- Different descriptions across surfaces → Medium.
- Inconsistent social handles → Medium.

**Fix voice:** `tobias-van-schneider` (primary) | `paula-scher` (backup).

Read `souls/tobias-van-schneider.json` before writing the Fix.

Worked fix example:

> Pick one of everything. One brand name spelling. One primary color. One logo file (with a documented light/dark variant). One one-line description. One social handle convention.
>
> Document them in a single `BRAND.md` at the repo root. Every surface pulls from this file:
>
> ```md
> # Snitch, brand reference
>
> Name: Snitch
> Tagline: Security review for the code your AI wrote.
> Primary color: #DC2626
> Logo (primary): public/logo-primary.svg
> Logo (dark mode): public/logo-dark.svg
> Social handle: @snitchplugin (everywhere)
> ```
>
> Then propagate. Audit each surface; update to match the canonical. The brand stops looking like three different products by the same team.
