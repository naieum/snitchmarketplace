#!/usr/bin/env python3
"""Common Crawl coverage proxy for Cat 69 (backlink profile) — free, no API key.

This is an OPTIONAL leaf helper. It queries the public Common Crawl index (CDX) API to
report how broadly Common Crawl has captured a domain. That is a *crawl-coverage* signal —
a weak, free authority/size proxy — NOT a referring-domain (backlink) list. A real backlink
profile (who links in, anchor text, toxic links) still needs a paid index or a GSC export.
See references/backlink-commoncrawl.md for the full honest framing and the heavier web-graph
authority path.

Contract with the skill:
- No key, one small HTTP request per domain. stdlib only.
- Prints a JSON object to stdout.
- On success: {"status": "ok", ...} and exit 0.
- On any failure (no network, domain absent from the crawl, endpoint down):
  {"status": "no_data", "reason": "..."} and exit 2 → Cat 69 treats it as Skip-with-reason,
  never a finding.

Usage:
    python3 commoncrawl_backlinks.py example.com
    python3 commoncrawl_backlinks.py example.com --competitor rival.com
    python3 commoncrawl_backlinks.py example.com --limit 800 --timeout 25

The backlink-from-Common-Crawl approach appears in several open-source SEO rule sets. This is a
fresh implementation against the public Common Crawl APIs; no code was copied from any of them.
"""

import argparse
import json
import sys
import urllib.parse
import urllib.request
from urllib.error import HTTPError, URLError

COLLINFO_URL = "https://index.commoncrawl.org/collinfo.json"
USER_AGENT = "snitch-marketing/coverage-check (+https://snitchplugin.com/marketing)"


def _get(url, timeout, retries=2):
    """GET a URL, returning decoded text. Raises on final failure."""
    last_err = None
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return resp.read().decode("utf-8", "replace")
        except (HTTPError, URLError, TimeoutError, OSError) as err:
            last_err = err
    raise last_err


def normalize_domain(raw):
    """Strip scheme, path, port, and a leading www. so the CDX query is clean."""
    raw = raw.strip()
    if "://" not in raw:
        raw = "http://" + raw
    host = urllib.parse.urlparse(raw).hostname or ""
    host = host.lower()
    if host.startswith("www."):
        host = host[4:]
    return host


def latest_index(timeout):
    """Return the cdx-api endpoint of the most recent Common Crawl index."""
    data = json.loads(_get(COLLINFO_URL, timeout))
    if not isinstance(data, list) or not data:
        raise ValueError("collinfo.json returned no indexes")
    # collinfo is ordered newest-first.
    entry = data[0]
    return entry.get("cdx-api"), entry.get("id")


def coverage(domain, cdx_api, limit, timeout):
    """Query the CDX API for a domain's capture magnitude + a sampled distinct-host/path read."""
    base = (
        cdx_api
        + "?url="
        + urllib.parse.quote(domain, safe="")
        + "&matchType=domain&output=json"
    )

    # Magnitude: showNumPages returns a single JSON object with a page count.
    pages = None
    try:
        meta = json.loads(_get(base + "&showNumPages=true&pageSize=5", timeout))
        pages = meta.get("pages")
    except (ValueError, HTTPError, URLError, TimeoutError, OSError):
        pages = None  # fall through to the sample, which is the load-bearing signal

    # Sample: a capped page of captures to count distinct subdomains + paths.
    sample_url = base + "&limit=" + str(limit) + "&fl=url,status"
    try:
        text = _get(sample_url, timeout)
    except HTTPError as err:
        if err.code == 404:
            return None  # CDX 404 == domain has no captures in this crawl
        raise
    lines = [ln for ln in text.splitlines() if ln.strip()]
    if not lines:
        return None  # domain not present in this crawl

    hosts, paths, captures = set(), set(), 0
    for ln in lines:
        try:
            rec = json.loads(ln)
        except ValueError:
            continue
        url = rec.get("url", "")
        parsed = urllib.parse.urlparse(url)
        if parsed.hostname:
            hosts.add(parsed.hostname.lower())
        paths.add(parsed.path or "/")
        captures += 1

    if captures == 0:
        return None

    sampled_cap_hit = captures >= limit
    return {
        "captured_pages_estimate": pages,  # coarse magnitude; None if unavailable
        "sampled_captures": captures,
        "sampled_capture_cap_hit": sampled_cap_hit,
        "distinct_subdomains_sampled": len(hosts),
        "distinct_paths_sampled": len(paths),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("domain", help="target domain (e.g. example.com)")
    ap.add_argument("--competitor", help="optional competitor domain for a side-by-side")
    ap.add_argument("--limit", type=int, default=500, help="max captures to sample (default 500)")
    ap.add_argument("--timeout", type=int, default=25, help="per-request timeout seconds (default 25)")
    args = ap.parse_args()

    out = {
        "status": "ok",
        "signal": "common-crawl coverage proxy (NOT a referring-domain/backlink list)",
        "source": "Common Crawl index (CDX) API",
    }

    try:
        cdx_api, index_id = latest_index(args.timeout)
        out["crawl_index"] = index_id
    except Exception as err:  # noqa: BLE001 — any failure is a clean no_data for the skill
        print(json.dumps({"status": "no_data", "reason": f"could not reach Common Crawl index: {err}"}))
        return 2

    target_domain = normalize_domain(args.domain)
    try:
        target = coverage(target_domain, cdx_api, args.limit, args.timeout)
    except Exception as err:  # noqa: BLE001
        print(json.dumps({"status": "no_data", "reason": f"CDX query failed for {target_domain}: {err}"}))
        return 2

    if target is None:
        print(json.dumps({
            "status": "no_data",
            "reason": f"{target_domain} not present in Common Crawl index {out.get('crawl_index')}",
        }))
        return 2

    out["target"] = {"domain": target_domain, **target}

    if args.competitor:
        comp_domain = normalize_domain(args.competitor)
        try:
            comp = coverage(comp_domain, cdx_api, args.limit, args.timeout)
        except Exception:  # noqa: BLE001 — competitor is best-effort; don't fail the whole run
            comp = None
        out["competitor"] = (
            {"domain": comp_domain, **comp} if comp
            else {"domain": comp_domain, "status": "no_data"}
        )

    out["caveat"] = (
        "Coverage is a weak, free size/authority proxy. It does not reveal who links in, "
        "anchor text, or toxic links. Label it as a coverage proxy and recommend a paid "
        "index or a GSC Links export for a real referring-domain profile."
    )
    print(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
