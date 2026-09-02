# Worked example: a pricing page CLOSER pass

A fictional example (tool: "Ledgerly," a bookkeeping SaaS, page source at
`src/pages/pricing.tsx`) showing the full flow from `SKILL.md`: map the current page,
diagnose it against CLOSER, verify claims, then reorder.

## The page as it stood

Section order, top to bottom:

1. **Hero** (`src/pages/pricing.tsx:8-12`). "Ledgerly: real-time double-entry bookkeeping
   powered by our custom reconciliation engine." Price not mentioned.
2. **How it works** (`:14-22`). A three-step technical diagram: bank feed → matching engine
   → ledger.
3. **Feature grid** (`:24-31`). Twelve feature tiles (multi-currency, audit trail, API, etc).
4. **Pricing table** (`:33-40`). Three tiers, $19/$49/$99.
5. **FAQ** (`:42-48`). Three questions, none about price, cancellation, or data ownership.
6. **CTA band** (`:50-52`). "Start your free trial." No supporting copy.

## Stage map

| Section | Stage | Evidence | Notes |
|---|---|---|---|
| Hero | C (partial) | `src/pages/pricing.tsx:8-12` | States what it is, but leads with the mechanism ("reconciliation engine"), not the outcome. No price, no "why am I here" hook. |
| How it works | S, mechanism half only | `src/pages/pricing.tsx:14-22` | This is the "plane ride." Nothing on the page has sold the "vacation" yet, so it lands as noise. |
| Feature grid | S, mechanism half only | `src/pages/pricing.tsx:24-31` | Same problem — twelve features with no outcome framing above them. |
| Pricing table | — | `src/pages/pricing.tsx:33-40` | Not a CLOSER stage by itself; it's the offer, which Sell should have already justified. |
| FAQ | E, weak | `src/pages/pricing.tsx:42-48` | Present, but doesn't answer the objections a bookkeeping buyer actually has (data security, switching from Excel/QuickBooks, accountant access). |
| CTA band | — | `src/pages/pricing.tsx:50-52` | No Reinforce. Nothing tells the reader they're making a smart, low-risk choice at the exact moment they'd click. |

## Diagnosis

- **Missing:** Label (nothing tells the reader who Ledgerly is for — a solo freelancer? A
  10-person firm's bookkeeper? Both read the same page and neither feels specifically found).
  Reinforce (the CTA band is bare).
- **Out of order:** Sell's mechanism half (How it works, Feature grid) runs before Sell's
  outcome half ever appears. A reader hits "reconciliation engine" in the first screen with
  no established reason to care.
- **Imbalanced:** two full sections (How it works, Feature grid) do the mechanism half of
  Sell; nothing does Overview (the pain of the current alternative — spreadsheets, a
  bookkeeper's manual reconciliation, month-end scrambles) or the outcome half of Sell.
- **Unverified claim to check before reuse:** "real-time" in the hero. Before keeping it,
  confirm against the actual sync interval in the product (e.g., if bank feeds sync every 15
  minutes, "real-time" is a claim that won't survive a reader checking).

## Reordered result (stage-labeled outline)

1. **Hero — C.** Leads with the outcome and the true sync claim, checked against the product
   ("month-end books that close themselves, synced from your bank every 15 minutes" instead
   of the unverified "real-time").
2. **Is this you? — L.** Three lines: "Ledgerly is built for you if you're a solo founder or
   small firm doing your own books and losing hours to reconciliation" / "not the fit if you
   need a full-service bookkeeper (see a bookkeeping service instead)."
3. **Sound familiar? — O.** The specific pain: spreadsheet drift, a bank feed that doesn't
   match the ledger, the month-end scramble. Named plainly, not "we solve inefficiency."
4. **What a month with Ledgerly looks like — S (outcome half).** The transformation: books
   that stay reconciled automatically, month-end closed in an afternoon instead of a week.
5. **How it works — S (mechanism half, moved here).** The bank feed → matching engine →
   ledger diagram now lands as "here's how," for a reader who already wants the outcome.
6. **Feature grid — S (mechanism half, moved here, trimmed).** Kept, positioned right after
   the mechanism explanation it supports.
7. **Pricing table — unchanged position**, now justified by everything above it instead of
   appearing cold.
8. **Objections, answered — E (rewritten).** Real objections: "What happens to my data if I
   cancel?", "Can my accountant get read-only access?", "I'm switching from QuickBooks, how
   painful is that?" — the questions this buyer actually has, not softballs.
9. **CTA band — R (new copy).** Restates the deal plainly (free trial length, cancel-anytime
   if true), plus one line of real social proof if the source is checkable.

Nothing here required new claims beyond the hero's sync interval, which was corrected to a
verified number. The rest of the fix is entirely reordering sections that already existed.
