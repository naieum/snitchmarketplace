# Recommendations — Free business-listing profiles

The agent emits this catalog from `templates/recommendations.json` via `recommend listings`. This file is the human-readable companion.

Every option here is **free to claim**. Several have paid upsells (leads, ads, accreditation) — claiming the profile never requires paying, and the free profile is the point: these listings are where local search, AI assistants, and neighbors look before your website. They also feed this skill's paid-media core: a Facebook Page is a prerequisite for Meta ads, Google Business Profile powers location assets in Google Ads / Performance Max, and Bing Places ties into Microsoft Advertising location assets.

## Picking by goal

Ask the user what they're after, then shortlist — don't dump all 11:

| Goal | Claim these first |
|---|---|
| **More local customers** (map pack, navigation, "near me") | Google Business Profile, Apple Business Connect, Bing Places |
| **Get recommended by AI assistants** (ChatGPT, Copilot, Perplexity answering "best X near me") | Bing Places, Yelp, BBB |
| **Word-of-mouth referrals** (neighbors and other owners passing your name) | Nextdoor, Facebook Business Page, Alignable |
| **Contractor / home-services visibility** (homeowners searching by trade) | Angi, Houzz, Thumbtack |

Goals stack. A plumber who wants everything claims all four rows — that's still ~30 minutes of free work per profile, mostly verification wait time.

### Why the AI-recommendation row looks like that

AI assistants answering local-recommendation queries lean on two things: the **Bing index** (Microsoft Copilot and ChatGPT search both draw on it — see `references/platforms/openai.md`) and **high-trust review/directory corpora** (Yelp, BBB) they cite for "best" and "reputable" judgments. A business absent from Bing Places, Yelp, and BBB is invisible to that answer path no matter how good its own website is. This is the local-business counterpart of `references/17-llms-txt-and-ai-search.md`.

## Order of operations

1. **Google Business Profile first** — largest surface, and Bing Places can import from it.
2. **Bing Places via GBP import** — minutes of work, unlocks the AI-assistant surface.
3. **Apple Business Connect** — independent claim; verify early since review can lag.
4. Then the rows matching the user's remaining goals.
5. **NAP consistency**: name, address, phone must match exactly (same suite format, same phone) across every profile. Inconsistent NAP is the classic silent killer of local rankings; fix the canonical form before claiming widely.

## Honest framing

- **Don't buy citation-blast services** (submit-to-300-directories) before claiming these core profiles by hand. The long tail is mostly worthless; the ~dozen here carry nearly all the weight.
- **BBB accreditation ≠ BBB listing.** The listing is free; accreditation is a paid program the sales flow will steer toward. Claim free, decide on accreditation separately.
- **Angi / Thumbtack lead programs are a separate decision** from the free profile. Claim the profile for visibility and reviews; evaluate pay-per-lead with a budget cap and real close-rate math before opting in.
- **Claiming is not maintaining.** A stale profile with wrong hours does damage. If the user won't maintain 11 profiles, the right answer is the shortlist for their top goal, kept current.
- Not local? A fully-online SaaS with no service area gets little from map surfaces — Google Business Profile, Apple, Nextdoor are N/A. Point them at `references/17-llms-txt-and-ai-search.md` for the AI-visibility path that does apply.

## See also

- `references/17-llms-txt-and-ai-search.md` — site-side AI-search readiness (this file is the profile-side complement).
- `references/platforms/openai.md` — ChatGPT search / OAI-SearchBot and the Bing index relationship.
- `references/platforms/google.md`, `references/platforms/microsoft.md`, `references/platforms/meta.md` — the ad products these profiles unlock.
