# Worked example: a pricing-page structure pass

Fictional product: Ledgerly, a bookkeeping application. This example supplies these facts:
bank feeds sync every 15 minutes; plans cost $19/$49/$99 per month. Audience research,
time savings, automatic reconciliation, trial terms, and customer proof are not supplied.
The filenames below illustrate citations, not files inspected in a real product.

## Existing page and diagnosis

| Section | Stage | Observation |
|---|---|---|
| Hero (`src/pages/pricing.tsx:8`) | C / S | “Real-time bookkeeping powered by our reconciliation engine.” Real-time contradicts the supplied 15-minute interval. |
| How it works (`:14`) | S | Bank feed → matching engine → ledger. Retain the mechanism without adding an unsupported automation promise. |
| Pricing (`:33`) | E | $19/$49/$99 monthly. Keep the actual terms easy to find before commitment. |
| CTA (`:50`) | R | “Start your free trial.” Trial availability is unverified; do not reuse this offer without terms. |

## Proposed outline

1. **C/S:** “Bookkeeping with bank feeds that sync every 15 minutes.” Uses only supplied facts.
2. **E:** Keep pricing early on this pricing page; identify missing plan distinctions as Open.
3. **S:** Retain the current mechanism explanation. Do not promise books that close themselves
   or a week reduced to an afternoon without implementation and outcome evidence.
4. **R:** Use a verified next action. Until its destination and trial terms are available,
   leave the CTA as an editorial Open item, not publishable placeholder copy.
5. **L/O:** No separate audience or pain sections yet: the brief does not substantiate them.

The corrected sync claim is supported by the example's supplied facts. The CTA verification
is Skip; unknown terms are not proof that the old offer is false. An audit returns this
outline only. Apply and render-check changes only when implementation is requested.
