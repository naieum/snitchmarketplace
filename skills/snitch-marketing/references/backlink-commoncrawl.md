# Free backlink + authority signals via Common Crawl (no key)

Cat 69 (backlink profile) historically resolves to **Skip** unless the user brings an
Ahrefs / Semrush / Moz key, because a real referring-domain list needs a paid link index.
This reference adds a *free, no-key* partial signal so Cat 69 has something honest to report
on every run, while being explicit about what it is and is not.

Common Crawl publishes a public web crawl and a public web graph. Neither requires an API
key. Two signals are useful here, at very different weights and costs.

> The backlink-from-Common-Crawl approach appears in several open-source SEO rule sets. This is a
> fresh implementation against the public Common Crawl APIs; no code was copied from any of them.

## Signal 1 — crawl coverage (lightweight, the default; what the script does)

The Common Crawl **index (CDX) API** is a free HTTP endpoint that answers "which URLs on this
domain has Common Crawl captured, and how many times." It is a *coverage* signal: a domain
that Common Crawl has crawled broadly is, loosely, more reachable and more linked-to than one
it has barely touched. It is **not** a backlink list — it says nothing about *who* links in.

The bundled helper does exactly this and nothing more:

```sh
python3 {skill_dir}/scripts/commoncrawl_backlinks.py example.com --competitor rival.com
```

It returns JSON: capture magnitude, a sampled count of distinct subdomains and paths, the
crawl index it used, and (with `--competitor`) a side-by-side. No key, one small HTTP request
per domain. On any failure (network down, domain not in the crawl, endpoint unreachable) it
prints `{"status": "no_data", ...}` and exits non-zero — Cat 69 reads that as a clean
Skip-with-reason, never a finding.

How to read it honestly in a finding:
- More coverage than a comparable competitor is a *weak positive* authority/size proxy.
- Far less coverage than competitors is a *weak signal* the domain is under-crawled (often
  young, thin, or poorly linked) — worth noting, not worth a strong claim.
- Always label it: "Common Crawl coverage proxy (not a referring-domain list)."

## Signal 2 — domain authority via the web graph (heavier, manual, optional)

Common Crawl also publishes a **host- and domain-level web graph** with ranking metrics —
harmonic centrality and PageRank — computed over the whole crawl's link structure. A domain's
harmonic-centrality percentile is a genuine authority proxy, closer to what paid tools sell.

The cost is bandwidth: the rank/vertex files are large (hundreds of MB to multiple GB,
gzipped, per release). The skill does **not** ship a code path that downloads them — a
multi-GB fetch is the wrong thing to do silently inside an audit. Treat it as a manual,
opt-in procedure when a user explicitly wants the stronger signal:

1. Find the latest web-graph release at the Common Crawl web-graph index
   (`https://commoncrawl.org/web-graphs`).
2. Download the domain-level **ranks** file for that release.
3. Look up the target (and competitors) by domain to read harmonic-centrality rank +
   percentile.

Report the percentile, cite the release, and note the date — web-graph releases lag the live
web by weeks to months.

## What this does NOT replace

Be straight with the user about the ceiling of the free path:

- **No referring-domain list.** Neither signal tells you *which* sites link to you, their
  anchor text, or whether a link is toxic. The "who links in + anchor distribution + toxic
  links + lost links" parts of Cat 69 still require a paid link index (Ahrefs / Semrush / Moz)
  or the user's own export.
- **Coverage is not authority.** Signal 1 correlates only loosely with authority; don't
  inflate it into a domain-authority claim. Signal 2 is the authority proxy, and it costs the
  download.
- **Lag.** Common Crawl is a periodic snapshot, not real-time. A link earned last week won't
  appear yet.

So Cat 69's honest posture becomes: *run Signal 1 for free on every applicable audit as a
coverage proxy; offer Signal 2 when the user wants a stronger authority read and accepts the
download; recommend a paid index (or a GSC "Links" export, which is free but only shows links
Google attributes to you) when the user needs the actual referring-domain list, anchor
distribution, or toxic-link analysis.*

## Graceful degradation

1. No `python3` / no network → Cat 69 keeps its existing free signals (branded-mention search,
   GSC Links export if the user has it) and notes Common Crawl was unavailable.
2. Script returns `no_data` → Skip-with-reason ("domain not present in the Common Crawl index,
   or the index API was unreachable"), not a finding.
3. Script returns coverage → fold it into Cat 69 as a labeled coverage proxy, with the
   competitor comparison if one was provided.

Cross-refs: Cat 69 (backlink profile), Cat 82 (AI-search citation — inbound links as a
citation signal), `references/brand-authority-platforms.md` (the off-site authority sweep
that complements link data).
