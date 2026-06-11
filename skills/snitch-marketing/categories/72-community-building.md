## CATEGORY 72: Community building (Discord, Slack, subreddit, forum)

Owned communities (vs rented social platforms). Discord servers, Slack workspaces, subreddits, dedicated forums, GitHub Discussions. Moat-building over time; harder to start but more durable than social presence.

### Pre-flight: community presence check

Confirm STEP 0.6 classified community presence as `minimal` or `established`. If `none` (no `discord.gg` / `slack.com` / `/community` / `github.com/<org>/discussions` linked from site), **Skip** with reason `no community detected; whether to build one is a strategic decision tied to audience type, see STEP 5 recommendations`. Don't run Evidence Required.

### Evidence required (do not skip, only when community exists)

**Crawl mode, required tool calls:**

1. Search the site for community links: footer, nav, dedicated `/community` page, blog post mentions.
2. For each community: confirm the invite/link resolves (HTTP status), capture member count if public, check last-message recency.
   - **Tooling caveat:** Discord/Slack invite pages, custom forums, and Discourse are largely JS-rendered or region-gated — a plain `Fetch` may return a shell or a gated page with no member count or message timestamps. Use a browser/Playwright or `WebSearch` tool IF one is present, else ask the user to paste the count/recency, else **Skip-with-reason**; do not assert member counts or activity you can't see (Rule 1). `github.com/<org>/discussions` and public subreddits are server-rendered exceptions where Fetch often DOES expose recent activity — capture it when present.
3. Identify community type: Discord, Slack, GitHub Discussions, subreddit, custom forum, Discourse.

### Forbidden claims

- "The brand probably doesn't have a community." Search; quote what's there or explicitly absent.

### Detection

Community link inventory + activity check.

### What to Search For

URL patterns:
- `discord.gg/`, `discord.com/invite/`
- `slack.com/`, `*.slack.com/join/`
- `reddit.com/r/<community>`
- `github.com/<org>/discussions`
- Custom Discourse / Forum URLs

### Actually Hurts the Marketing Surface

- **Brand promotes "join our Discord" with a dead invite link**.
  Evidence required: footer/nav link + fetch returning expired invite.
- **Community exists but no recent activity** (>30 days silent).
  Evidence required: server/channel last-post date.
- **Multiple disconnected communities** (Discord + Slack + Discourse with overlapping audiences).
  Evidence required: community inventory.
- **No community at all** for a niche where peer community is the value driver (developer tools, hobby products).
  Evidence required: business type assessment + missing community.
- **Community managed by no one** (no moderation, spam visible).
  Evidence required: visible spam in public channels.

### NOT a Problem

- No community for a brand where it doesn't fit (B2B-only, single-customer enterprise sales).
- Lightly active small community (early stage). Activity matters more than size.

### Context Check

1. Does the audience benefit from peer interaction?
2. Is there a team member responsible for community moderation?
3. Are the platform choices right for the audience (Discord for gamers / devs; Slack for B2B)?
4. Does the community drive product feedback / churn reduction?

### Reference

CMX on community building: https://cmxhub.com/

**Severity tagging:**
- Promoted community with dead invite → Critical.
- Community abandoned by mods (visible spam) → High.
- Multiple fragmented communities → Medium.
- No community where audience expects one → Medium.

**Fix voice:** `sahil-lavingia` (primary) | `mike-monteiro` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> Pick one community platform. Discord for synchronous chat, GitHub Discussions for async + dev-audience, Discourse for long-form. Don't run two; the community fragments and neither hits critical mass.
>
> One paid mod (or founder time, ~5 hr/week early on). Welcome every new member by name in the first 24 hours. Reply to questions within 24 hours. Pin the FAQ. Run weekly office-hours / AMAs.
>
> A community that the founder shows up in compounds. A community that the founder ignores fills with spam and dies.
