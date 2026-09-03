#!/usr/bin/env python3
"""Message-catalog completeness and placeholder-parity diff.

Usage:
    catalog-diff.py --source <source-catalog> <target-catalog> [<target-catalog> ...]
    catalog-diff.py --json --source locales/en.json locales/*.json
    catalog-diff.py --format json --source locales/en.json locales/fr.arb
    catalog-diff.py --selftest

Compares every target catalog against the source catalog and reports, per target:

    missing            keys present in the source and absent from the target
    extra              keys present in the target and absent from the source
    untranslated       values byte-identical to the source (likely never translated);
                       numbers, URLs and values under 3 characters are not reported
    placeholders       placeholder names present on one side and not the other
    empty              keys whose value is empty or whitespace only
    invalid            the file could not be parsed
    unsupported        the file's extension is not one this script parses

Supported formats, chosen by extension only. There is no content sniffing: a file whose
extension is not on this list is refused rather than guessed at, because a JSON-shaped
catalog in another convention (an `.arb`, a `.strings` export) diffs into a page of
fabricated missing keys.

    .json                       nested objects and arrays flattened to dotted keys
    .po / .pot                  gettext msgid / msgstr pairs, best effort
    .yml / .yaml                flat or indented "key: value" text, best effort

    --format json|po|yaml       force one parser for every file, including the source,
                                overriding the extension check

Placeholder syntaxes recognised: {name}, {{name}}, ${name}, %s / %d / %f,
%(name)s, and ICU MessageFormat arguments such as {count, plural, one {...} other {...}}
(the argument name "count" is what is compared).

Exit codes: 0 when no problems were found, 1 when problems were found, 2 on a usage error.
Stdlib only. Read-only: this script never writes a file outside --selftest's temp directory.
"""

import json
import os
import re
import sys
from collections import Counter

# ------------------------------------------------------------------------------------------------
# Parsing


class ParseError(ValueError):
    """Raised when a catalog file cannot be parsed."""


class UnsupportedFormat(ParseError):
    """Raised when a catalog file's extension is not one this script parses."""


SUPPORTED = "json, po, pot, yml, yaml"
FORCED_PARSERS = {"json": "parse_json", "po": "parse_po", "yaml": "parse_flat"}


def flatten(obj, prefix=""):
    """Flatten nested dicts and lists into a dict of dotted key -> string value."""
    out = {}
    if isinstance(obj, dict):
        for key, value in obj.items():
            out.update(flatten(value, "%s.%s" % (prefix, key) if prefix else str(key)))
    elif isinstance(obj, list):
        for index, value in enumerate(obj):
            out.update(flatten(value, "%s.%d" % (prefix, index) if prefix else str(index)))
    else:
        out[prefix] = "" if obj is None else str(obj)
    return out


def parse_json(text):
    try:
        data = json.loads(text)
    except ValueError as exc:
        raise ParseError("invalid JSON: %s" % exc)
    if not isinstance(data, (dict, list)):
        raise ParseError("top-level JSON value is not an object or array")
    return flatten(data)


PO_STR = re.compile(r'^\s*(msgctxt|msgid_plural|msgid|msgstr(?:\[\d+\])?)?\s*"(.*)"\s*$')


def _po_unescape(text):
    out = []
    i = 0
    while i < len(text):
        ch = text[i]
        if ch == "\\" and i + 1 < len(text):
            nxt = text[i + 1]
            out.append({"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\"}.get(nxt, nxt))
            i += 2
        else:
            out.append(ch)
            i += 1
    return "".join(out)


def parse_po(text):
    """Best-effort gettext parser. Key is msgid, or 'ctxt|msgid' when msgctxt is present."""
    entries = {}
    ctxt = msgid = None
    current = None
    buffers = {}
    saw_any = False

    def flush():
        if msgid is None:
            return
        if msgid == "":
            return  # the header entry
        key = "%s|%s" % (ctxt, msgid) if ctxt else msgid
        value = buffers.get("msgstr", "")
        if not value:
            value = buffers.get("msgstr[0]", "")
        entries[key] = value

    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        match = PO_STR.match(line)
        if not match:
            continue
        saw_any = True
        field, chunk = match.group(1), _po_unescape(match.group(2))
        if field == "msgctxt":
            flush()
            ctxt, msgid, buffers = chunk, None, {}
            current = "msgctxt"
        elif field == "msgid":
            if current in ("msgstr", "msgid_plural") or (current == "msgid" and msgid is not None):
                flush()
                ctxt = None
                buffers = {}
            msgid = chunk
            current = "msgid"
        elif field == "msgid_plural":
            current = "msgid_plural"
        elif field is not None and field.startswith("msgstr"):
            current = field
            buffers[field] = buffers.get(field, "") + chunk
        else:
            # A bare continuation string belongs to whatever field is open.
            if current == "msgid":
                msgid = (msgid or "") + chunk
            elif current == "msgctxt":
                ctxt = (ctxt or "") + chunk
            elif current:
                buffers[current] = buffers.get(current, "") + chunk
    flush()
    if not saw_any:
        raise ParseError("no gettext entries found")
    return entries


YAML_LINE = re.compile(r"^(\s*)([A-Za-z0-9_.\-\"']+)\s*:\s*(.*)$")


def _strip_quotes(value):
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def parse_flat(text):
    """Best-effort indented 'key: value' parser for YAML-shaped locale trees."""
    entries = {}
    stack = []  # (indent, key)
    saw_any = False
    for raw in text.splitlines():
        if not raw.strip() or raw.lstrip().startswith("#") or raw.lstrip().startswith("- "):
            continue
        match = YAML_LINE.match(raw.rstrip())
        if not match:
            continue
        indent, key, value = len(match.group(1)), _strip_quotes(match.group(2)), match.group(3)
        while stack and stack[-1][0] >= indent:
            stack.pop()
        path = [k for _, k in stack] + [key]
        if value.strip() == "" or value.strip() in ("|", ">", "|-", ">-"):
            stack.append((indent, key))
            continue
        saw_any = True
        entries[".".join(path)] = _strip_quotes(value)
    if not saw_any:
        raise ParseError("no 'key: value' pairs found")
    return entries


def load_catalog(path, forced=None):
    """Parse one catalog. The parser is chosen by extension, or forced by `forced`.

    An extension this script does not parse raises UnsupportedFormat. Nothing is decided
    by looking at the file's contents.
    """
    if forced is not None and forced not in FORCED_PARSERS:
        raise ParseError("unknown forced format: %s (supported: %s)" % (forced, SUPPORTED))

    try:
        with open(path, "r", encoding="utf-8") as handle:
            text = handle.read()
    except OSError as exc:
        raise ParseError("cannot read file: %s" % exc)
    except UnicodeDecodeError as exc:
        raise ParseError("not valid UTF-8: %s" % exc)

    if forced is not None:
        return {"parse_json": parse_json, "parse_po": parse_po,
                "parse_flat": parse_flat}[FORCED_PARSERS[forced]](text)

    ext = os.path.splitext(path)[1].lower()
    if ext == ".json":
        return parse_json(text)
    if ext in (".po", ".pot"):
        return parse_po(text)
    if ext in (".yml", ".yaml"):
        return parse_flat(text)
    raise UnsupportedFormat("unsupported format: %s (supported: %s)" % (path, SUPPORTED))


# ------------------------------------------------------------------------------------------------
# Placeholders

PY_NAMED = re.compile(r"%\(([A-Za-z0-9_]+)\)[sdifgeExXor%]")
PY_POS = re.compile(r"%[sdifgeExXor]")
DOLLAR_BRACE = re.compile(r"\$\{([A-Za-z0-9_.\[\]]+)\}")
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_.\-]*")


def _brace_names(text):
    """Collect argument names from {name}, {{name}} and ICU {count, plural, ...} forms."""
    names = []
    i = 0
    length = len(text)
    while i < length:
        if text[i] != "{":
            i += 1
            continue
        j = i + 1
        while j < length and text[j] in " \t":
            j += 1
        match = IDENT.match(text, j)
        if not match:
            i += 1
            continue
        k = match.end()
        while k < length and text[k] in " \t":
            k += 1
        if k < length and text[k] in "},":
            names.append(match.group(0))
            i = match.end()
        else:
            i += 1
    return names


def extract_placeholders(text):
    """Return a Counter of placeholder names found in text."""
    counts = Counter()
    if not text:
        return counts
    work = text.replace("%%", "")

    for match in PY_NAMED.finditer(work):
        counts["%%(%s)" % match.group(1)] += 1
    work = PY_NAMED.sub(" ", work)

    for match in PY_POS.finditer(work):
        counts[match.group(0)] += 1
    work = PY_POS.sub(" ", work)

    for match in DOLLAR_BRACE.finditer(work):
        counts["${%s}" % match.group(1)] += 1
    work = DOLLAR_BRACE.sub(" ", work)

    for name in _brace_names(work):
        counts[name] += 1
    return counts


# ------------------------------------------------------------------------------------------------
# Comparison

URLISH = re.compile(r"^(https?://|//|mailto:|tel:)|://")
NUMERIC = re.compile(r"^[+-]?[\d\s.,:%$€£¥/()-]+$")


def looks_untranslatable(value):
    """True when a value identical to the source is not evidence of a missing translation."""
    stripped = value.strip()
    if len(stripped) < 3:
        return True
    if URLISH.search(stripped):
        return True
    if NUMERIC.match(stripped):
        return True
    return False


def compare(source, target):
    """Compare one target catalog against the source. Returns a problems dict."""
    src_keys = set(source)
    tgt_keys = set(target)

    missing = sorted(src_keys - tgt_keys)
    extra = sorted(tgt_keys - src_keys)
    shared = sorted(src_keys & tgt_keys)

    empty = [k for k in shared if not target[k].strip()]
    untranslated = [
        k for k in shared
        if target[k].strip()
        and target[k] == source[k]
        and not looks_untranslatable(source[k])
    ]

    placeholders = []
    for key in shared:
        if not target[key].strip():
            continue
        src_ph = extract_placeholders(source[key])
        tgt_ph = extract_placeholders(target[key])
        if src_ph == tgt_ph:
            continue
        lost = sorted((src_ph - tgt_ph).elements())
        gained = sorted((tgt_ph - src_ph).elements())
        placeholders.append({"key": key, "missing": lost, "unexpected": gained})

    return {
        "missing": missing,
        "extra": extra,
        "untranslated": untranslated,
        "empty": empty,
        "placeholders": placeholders,
    }


def problem_count(report):
    if report.get("unsupported") or report.get("invalid"):
        return 1
    return (
        len(report.get("missing", []))
        + len(report.get("extra", []))
        + len(report.get("untranslated", []))
        + len(report.get("empty", []))
        + len(report.get("placeholders", []))
    )


# ------------------------------------------------------------------------------------------------
# Output

MAX_LISTED = 25


def _listing(label, items):
    lines = ["  %s (%d):" % (label, len(items))]
    for item in items[:MAX_LISTED]:
        lines.append("    %s" % item)
    if len(items) > MAX_LISTED:
        lines.append("    ... and %d more" % (len(items) - MAX_LISTED))
    return lines


def render_text(source_path, source_keys, reports):
    lines = ["source: %s (%d keys)" % (source_path, source_keys), ""]
    for report in reports:
        count = problem_count(report)
        lines.append("%s -- %s" % (report["path"], "%d problem(s)" % count if count else "clean"))
        if report.get("unsupported"):
            lines.append("  %s" % report["unsupported"])
            lines.append("")
            continue
        if report.get("invalid"):
            lines.append("  invalid: %s" % report["invalid"])
            lines.append("")
            continue
        if report["missing"]:
            lines.extend(_listing("missing keys", report["missing"]))
        if report["extra"]:
            lines.extend(_listing("extra keys", report["extra"]))
        if report["empty"]:
            lines.extend(_listing("empty values", report["empty"]))
        if report["untranslated"]:
            lines.extend(_listing("identical to source (likely untranslated)",
                                  report["untranslated"]))
        if report["placeholders"]:
            lines.append("  placeholder mismatches (%d):" % len(report["placeholders"]))
            for item in report["placeholders"][:MAX_LISTED]:
                lines.append(
                    "    %s: missing %s, unexpected %s"
                    % (item["key"], item["missing"] or "-", item["unexpected"] or "-")
                )
            if len(report["placeholders"]) > MAX_LISTED:
                lines.append("    ... and %d more" % (len(report["placeholders"]) - MAX_LISTED))
        lines.append("")
    return "\n".join(lines).rstrip()


USAGE = (
    "usage: catalog-diff.py [--json] [--format json|po|yaml] --source <source-catalog>"
    " <target-catalog> ...\n"
    "       catalog-diff.py --selftest\n"
    "formats, by extension only: .json (nested, flattened to dotted keys), .po/.pot,"
    " .yml/.yaml.\n"
    "any other extension is reported as unsupported; pass --format to force a parser."
)


# ------------------------------------------------------------------------------------------------
# Self-test


def selftest():
    import tempfile

    checks = []
    with tempfile.TemporaryDirectory() as tmp:
        src_path = os.path.join(tmp, "en.json")
        tgt_path = os.path.join(tmp, "fr.json")
        bad_path = os.path.join(tmp, "broken.json")

        source = {
            "nav": {"home": "Home", "about": "About us"},
            "cart": {
                "count": "You have {count, plural, one {# item} other {# items}}",
                "greeting": "Hello, {name}",
                "total": "Total: %s",
            },
            "legal": {"url": "https://example.com/terms", "ok": "OK"},
            "footer": {"copyright": "All rights reserved"},
        }
        target = {
            "nav": {"home": "Accueil"},
            "cart": {
                "count": "Vous avez {total, plural, one {# article} other {# articles}}",
                "greeting": "Bonjour, {name}",
                "total": "",
            },
            "legal": {"url": "https://example.com/terms", "ok": "OK"},
            "footer": {"copyright": "All rights reserved"},
            "extra": {"unused": "Inutilise"},
        }
        with open(src_path, "w", encoding="utf-8") as handle:
            json.dump(source, handle)
        with open(tgt_path, "w", encoding="utf-8") as handle:
            json.dump(target, handle)
        with open(bad_path, "w", encoding="utf-8") as handle:
            handle.write("{ this is not json")

        src = load_catalog(src_path)
        tgt = load_catalog(tgt_path)
        report = compare(src, tgt)

        checks.append((
            "missing keys detected (nav.about)",
            "nav.about" in report["missing"],
            report["missing"],
        ))
        checks.append((
            "extra keys detected (extra.unused)",
            "extra.unused" in report["extra"],
            report["extra"],
        ))
        checks.append((
            "untranslated value detected (footer.copyright)",
            "footer.copyright" in report["untranslated"],
            report["untranslated"],
        ))
        checks.append((
            "placeholder mismatch detected (cart.count)",
            any(item["key"] == "cart.count" for item in report["placeholders"]),
            [item["key"] for item in report["placeholders"]],
        ))
        checks.append((
            "empty value detected (cart.total)",
            "cart.total" in report["empty"],
            report["empty"],
        ))
        checks.append((
            "identical URL not reported as untranslated",
            "legal.url" not in report["untranslated"],
            report["untranslated"],
        ))
        checks.append((
            "identical 2-char value not reported",
            "legal.ok" not in report["untranslated"],
            report["untranslated"],
        ))
        checks.append((
            "matching placeholder not reported (cart.greeting)",
            all(item["key"] != "cart.greeting" for item in report["placeholders"]),
            [item["key"] for item in report["placeholders"]],
        ))

        invalid = None
        try:
            load_catalog(bad_path)
        except ParseError as exc:
            invalid = str(exc)
        checks.append(("invalid file raises ParseError", invalid is not None, invalid))

        # An ARB file is JSON-shaped with a different key convention. Sniffing it would
        # parse it happily and report every source key as missing.
        arb_path = os.path.join(tmp, "fr.arb")
        with open(arb_path, "w", encoding="utf-8") as handle:
            json.dump({"@@locale": "fr", "cartTitle": "Panier"}, handle)

        unsupported = None
        try:
            load_catalog(arb_path)
        except UnsupportedFormat as exc:
            unsupported = str(exc)
        checks.append((
            "unsupported extension refused, not sniffed",
            unsupported == "unsupported format: %s (supported: %s)" % (arb_path, SUPPORTED),
            unsupported,
        ))

        arb_report = {"path": arb_path, "unsupported": unsupported}
        checks.append((
            "unsupported file counts as one problem",
            problem_count(arb_report) == 1,
            problem_count(arb_report),
        ))
        checks.append((
            "unsupported line rendered verbatim",
            ("  unsupported format: %s (supported: %s)" % (arb_path, SUPPORTED))
            in render_text(src_path, len(src), [arb_report]),
            render_text(src_path, len(src), [arb_report]),
        ))
        checks.append((
            "--format forces a parser past the extension check",
            load_catalog(arb_path, "json").get("cartTitle") == "Panier",
            sorted(load_catalog(arb_path, "json")),
        ))

        po_text = (
            'msgid ""\nmsgstr "Project-Id-Version: t\\n"\n\n'
            'msgid "Hello, %s"\nmsgstr "Bonjour, %s"\n\n'
            'msgid "Sign out"\nmsgstr ""\n'
        )
        po_path = os.path.join(tmp, "fr.po")
        with open(po_path, "w", encoding="utf-8") as handle:
            handle.write(po_text)
        po = load_catalog(po_path)
        checks.append((
            "gettext parsed, header skipped",
            set(po) == {"Hello, %s", "Sign out"} and po["Sign out"] == "",
            sorted(po),
        ))

        yaml_path = os.path.join(tmp, "de.yml")
        with open(yaml_path, "w", encoding="utf-8") as handle:
            handle.write("de:\n  nav:\n    home: Startseite\n    about: \"Uber uns\"\n")
        flat = load_catalog(yaml_path)
        checks.append((
            "indented key: value parsed to dotted keys",
            flat.get("de.nav.home") == "Startseite" and flat.get("de.nav.about") == "Uber uns",
            sorted(flat),
        ))

    checks.append((
        "placeholder extraction covers all syntaxes",
        extract_placeholders("{a} {{b}} ${c} %s %d %(e)s {f, plural, other {#}}")
        == Counter({"a": 1, "b": 1, "${c}": 1, "%s": 1, "%d": 1, "%(e)": 1, "f": 1}),
        dict(extract_placeholders("{a} {{b}} ${c} %s %d %(e)s {f, plural, other {#}}")),
    ))

    ok = True
    for label, passed, observed in checks:
        print("%-48s %s (%s)" % (label, "ok" if passed else "FAILED", observed))
        ok = ok and passed
    print("selftest: %s (%d checks)" % ("PASS" if ok else "FAIL", len(checks)))
    return 0 if ok else 1


# ------------------------------------------------------------------------------------------------


def main(argv):
    args = list(argv[1:])
    if "--selftest" in args:
        return selftest()

    as_json = False
    if "--json" in args:
        as_json = True
        args.remove("--json")

    forced = None
    if "--format" in args:
        fidx = args.index("--format")
        if fidx + 1 >= len(args):
            print("error: --format needs one of %s" % SUPPORTED, file=sys.stderr)
            print(USAGE, file=sys.stderr)
            return 2
        forced = args[fidx + 1].lower()
        if forced not in FORCED_PARSERS:
            print("error: --format must be json, po or yaml", file=sys.stderr)
            print(USAGE, file=sys.stderr)
            return 2
        del args[fidx:fidx + 2]

    if "--source" not in args:
        print(USAGE, file=sys.stderr)
        return 2
    idx = args.index("--source")
    if idx + 1 >= len(args):
        print("error: --source needs a file path", file=sys.stderr)
        print(USAGE, file=sys.stderr)
        return 2
    source_path = args[idx + 1]
    targets = args[:idx] + args[idx + 2:]
    targets = [t for t in targets if os.path.abspath(t) != os.path.abspath(source_path)]
    if not targets:
        print("error: no target catalogs given", file=sys.stderr)
        print(USAGE, file=sys.stderr)
        return 2

    try:
        source = load_catalog(source_path, forced)
    except UnsupportedFormat as exc:
        print("error: source %s" % exc, file=sys.stderr)
        return 2
    except ParseError as exc:
        print("error: source %s: %s" % (source_path, exc), file=sys.stderr)
        return 2

    reports = []
    for path in targets:
        try:
            target = load_catalog(path, forced)
        except UnsupportedFormat as exc:
            reports.append({"path": path, "unsupported": str(exc)})
            continue
        except ParseError as exc:
            reports.append({"path": path, "invalid": str(exc)})
            continue
        report = compare(source, target)
        report["path"] = path
        reports.append(report)

    total = sum(problem_count(r) for r in reports)
    if as_json:
        print(json.dumps(
            {"source": source_path, "source_keys": len(source),
             "problems": total, "catalogs": reports},
            indent=2, sort_keys=True, ensure_ascii=False,
        ))
    else:
        print(render_text(source_path, len(source), reports))
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
