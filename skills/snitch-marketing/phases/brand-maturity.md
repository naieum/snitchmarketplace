# Phase: brand-maturity (off-site presence check)

> Single source of truth for the brand-maturity phase. Consumed by the CLI
> recon pass and streamed via `snitch marketing step --phase=brand-maturity`.
> Mirrors SKILL.md STEP 0.6 and `references/discovery-flow.md`. Required before
> any off-site / channel category (cats 66-81).

A brand with no online presence yet does not benefit from a paid-search, paid-social,
backlink, or community audit. Running those wastes tokens and fills the report with
"no presence detected, recommend establishing one" lines that don't help.

For each surface below, classify presence as `none`, `minimal`, or `established`, with
evidence per claim (the "## Brand maturity" output):

- **Domain age**: `whois <domain> | grep -iE "creat|registered"`. Brand <90 days old →
  likely `none` everywhere.
- **Search presence**: search the brand name. 0 third-party results besides the brand's
  own site → `none` organic; industry/press/forum mentions → at least `minimal`.
- **Paid ads**: Google Ads Transparency Center (Cat 66) + Meta Ad Library (Cat 67). No
  ads ever → `none`.
- **Social profiles**: from footer / `Organization.sameAs`. None → `none` (Cat 68);
  present but stale (>90d) → `minimal`; posted in last 30d → `established`.
- **Backlinks**: branded-name search returning zero third-party mentions → `none`
  (Cat 69). Partial without paid SEO data — mark approximations as such.
- **Community**: search for `discord.gg`, `slack.com`, `/community`, `/forum`,
  github discussions. None → `none` (Cat 72).
- **PR / press**: `"<brand>" site:techcrunch.com OR site:producthunt.com` patterns.
  None → `none` (Cat 77).
- **Local SEO / GBP**: only for local businesses with a physical address; skip
  detection otherwise.

**Skip rule:** for any cat 66-81 whose surface scored `none`, skip the detection pass
and mark the cat **Skip** with reason "no detected presence on this channel;
recommendation pending in Strategic Recommendations." STEP 4.5 turns those skips into
prioritized "start here" recommendations, not findings.

**If maturity is `none` across all 16 off-site surfaces:** recommend skipping the
off-site audit entirely (run on-site cats now; re-run off-site in 90+ days). Sixteen
redundant "no presence" skips for a 3-week-old launch is condescending; the valuable
output is the order to build them in, which lives in STEP 4.5.
