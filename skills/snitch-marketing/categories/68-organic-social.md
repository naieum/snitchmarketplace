## CATEGORY 68: Organic social presence (X, LinkedIn, Instagram, YouTube, TikTok, Threads)

Does the brand have a presence, is it active, what's working, what's not. Organic social drives discovery, retention, community trust, separate from paid social's pay-to-reach mechanic. Audit identifies presence + activity level + content fit per platform.

### Pre-flight: brand maturity check

Confirm STEP 0.6 classified social-profile presence as `minimal` or `established`. If `none` (no profiles linked from site footer / `Organization.sameAs` / nav), **Skip** with reason `no social profiles detected; recommendation pending in STEP 4`. Don't run Evidence Required.

### Evidence required (do not skip, only when maturity is `minimal`+)

**Crawl mode, required tool calls:**

1. Find brand profiles via:
   - Site footer / nav links to social profiles
   - `<link rel="me">` (IndieWeb identity)
   - JSON-LD `Organization.sameAs` array (cross-reference Cat 32's Organization row)
2. Quote profile URLs.
3. **Tooling caveat (Critical — X / Instagram / TikTok / LinkedIn are login-gated and JS-rendered).** A plain `Fetch` of those profiles returns a login wall or an empty app shell, NOT the follower count, post dates, or feed — those render client-side behind auth. To capture follower count / last-post date / 30-day post frequency: use a browser/Playwright or `WebSearch` tool IF one is present this session, and quote what it returns. Otherwise, ask the user to paste the counts/dates. Otherwise, **Skip** the activity-metric capture with reason `follower/post-frequency data is login-gated and JS-rendered; plain Fetch returns a wall`. **Never assert a follower count or post cadence you didn't observe (Rule 1).** What you CAN always verify with Fetch: that the profile link resolves (HTTP status) and that the site links to it. **Exceptions:** `youtube.com/@…` channel pages and `github.com/…` profiles are server-rendered and a plain Fetch often DOES expose subscriber/repo counts and recent activity — capture those when present.
4. Identify which platform(s) the brand is active on vs absent from. When activity metrics are gated (step 3), reframe findings around the verifiable signal — does the profile link resolve, is it linked from the site, does the bio match positioning — rather than counts you can't see.

**Source mode, required tool calls:**

1. `Grep` for social URLs in components: `twitter.com/`, `x.com/`, `linkedin.com/in/`, `linkedin.com/company/`, `instagram.com/`, `youtube.com/@`, `tiktok.com/@`, `github.com/`, `threads.net/@`. Quote each.
2. `Grep` for social-share components / OG-share buttons. Audit whether the social hooks exist for users to share content from the site.

### Forbidden claims

- "The brand probably isn't active on LinkedIn." Quote the link's absence, OR capture the profile via a browser/WebSearch tool. If the feed is login-gated and you have no such tool, Skip the activity claim — don't assert inactivity you can't see.
- "Posting frequency is probably low." Quote dates of recent posts (captured via a browser/WebSearch tool or pasted by the user); otherwise Skip — never invent a cadence.

### Detection

Brand-controlled profile inventory + activity level per profile.

### What to Search For

Source patterns:
- `twitter.com/`, `x.com/`
- `linkedin.com/in/`, `linkedin.com/company/`, `linkedin.com/showcase/`
- `instagram.com/`, `instagram.com/p/`
- `youtube.com/@`, `youtube.com/channel/`, `youtu.be/`
- `tiktok.com/@`
- `threads.net/@`
- `github.com/` (often counts as social for dev-audience brands)
- `<link rel="me" href="https://...">`

### Actually Hurts the Marketing Surface

- **Brand has profiles but hasn't posted in >90 days**.
  Evidence required: profile URL + last-post date.
- **Brand has profile on the wrong platform for its audience** (B2B SaaS active on TikTok but not LinkedIn).
  Evidence required: business model + platform activity vs likely audience location.
- **Profile bio doesn't match the brand's current positioning** (says "AI app builder" when site now says "form backend").
  Evidence required: bio quoted + site value prop quoted.
- **Profile links to dead site URL** (utm-tagged from a previous campaign that 404s).
  Evidence required: profile bio link + fetched response status.
- **No profile on a platform the audience clearly uses** (developer-audience brand with no GitHub presence).
  Evidence required: audience signal + missing profile.

### NOT a Problem

- Brand absent from platforms that don't fit (consumer-product brand without a LinkedIn page is fine).
- Profile with low follower count if recent (early-stage brand). Activity matters more than count.
- Profile in maintenance mode (post-acquisition / sunsetting product). Document context.

### Context Check

1. Where does the audience actually spend time? Don't optimize for platforms the audience isn't on.
2. Does the brand have content cadence to support a platform? Empty / abandoned profiles look worse than no profile.
3. Are profile links wired both ways (site → profile + profile → site)?
4. Is the visual brand consistent across profiles (same avatar, same banner style)?
5. Is the team posting personally vs from the brand account? Personal often outperforms brand on platforms like X / LinkedIn for early-stage.

### Reference

Buffer's social media audit guide: https://buffer.com/library/social-media-audit/

Sprout Social state of social media: https://sproutsocial.com/insights/

**Severity tagging:**
- Active profiles on wrong platforms / inactive on right ones → High.
- Profile bio doesn't match current positioning → High.
- Profile links broken → High.
- No presence on critical-audience platform → Medium.
- Profile activity stale (>90d) → Medium.

**Fix voice:** `brand-surface-designer` (primary) | `indie-commerce-founder` (backup).

Read `souls/brand-surface-designer.json` before writing the Fix.

Worked fix example:

> Pick the two platforms where your audience actually lives. Set up profiles that look like the brand looks everywhere else, same avatar, same banner aesthetic, same one-line bio that says exactly what the site says. Link both directions.
>
> Then post. Cadence matters more than perfection, a weekly substantial post outperforms three sporadic ones a quarter. The bio that promises updates and then ghosts is worse than the absence.
>
> ```
> Bio template:
>   {one-line value prop, same as site H1, ~60 chars}
>   {primary use case, ~100 chars}
>   {site URL, with clean utm-source=<platform>}
> ```
>
> Post cadence target: 1-3x per week on the primary platform, 1x per week on the secondary. Anything less and the brand reads as abandoned; anything more burns content reserves.
