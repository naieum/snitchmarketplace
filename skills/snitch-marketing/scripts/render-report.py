#!/usr/bin/env python3
"""
render-report.py — render a Snitch: Marketing markdown audit report into a
single-file, offline, brand-palette-compliant HTML page.

Usage:
    python3 render-report.py <path-to-SEO_AUDIT_REPORT.md> [--confidential]

Output:
    Writes <same-dir>/SEO_AUDIT_REPORT.html alongside the input markdown.

Constraints:
    - No external CDN; all CSS / JS inlined.
    - Brand palette only: red / white / black + neutral grays.
    - Print-friendly via @media print.
    - Falls back to regex-based markdown parsing if markdown-it-py is unavailable.
"""

from __future__ import annotations

import argparse
import base64
import html
import os
import re
import sys
from pathlib import Path


CSS_TEMPLATE = """\
* { box-sizing: border-box; }
:root {
  --bg-base: #09090b;
  --bg-surface: #18181b;
  --bg-raised: #27272a;
  --bg-elevated: #1f1f22;
  --border: #2e2e33;
  --border-hover: #52525b;
  --text-primary: #fafafa;
  --text-secondary: #d4d4d8;
  --text-tertiary: #a1a1aa;
  --text-muted: #71717a;
  --accent: #e4e4e7;
  --accent-hover: #ffffff;
  --danger: #ef4444;
  --danger-hover: #dc2626;
  --code-bg: #2a1f1f;
  --code-fg: #fca5a5;
  --code-border: rgba(239, 68, 68, 0.35);
  --critical-bg: rgba(127, 29, 29, 0.32);
  --critical-fg: #fecaca;
  --critical-border: rgba(239, 68, 68, 0.55);
  --high-bg: rgba(239, 68, 68, 0.18);
  --high-fg: #fca5a5;
  --high-border: rgba(239, 68, 68, 0.45);
  --medium-bg: rgba(113, 113, 122, 0.18);
  --medium-fg: #d4d4d8;
  --medium-border: rgba(113, 113, 122, 0.55);
  --low-bg: transparent;
  --low-fg: #a1a1aa;
  --low-border: rgba(82, 82, 91, 0.55);
  --display: "Helvetica Neue", Helvetica, Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, Roboto, Arial, sans-serif;
  --mono: "SF Mono", "Sohne Mono", "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  --reading-size: 16px;
  color-scheme: dark;
}

[data-size="comfy"] { --reading-size: 17px; }
[data-size="large"]  { --reading-size: 18px; }

html { background: var(--bg-base); color: var(--text-primary); }
body {
  margin: 0;
  font-family: var(--display);
  font-size: var(--reading-size);
  font-weight: 400;
  line-height: 1.65;
  color: var(--text-secondary);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* ── Sticky header ── */
header.sticky {
  position: sticky; top: 0; z-index: 20;
  background: rgba(9, 9, 11, 0.92);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
  padding: 14px 28px;
  display: flex; justify-content: space-between; align-items: center;
  gap: 1rem;
}
header.sticky .brand {
  display: flex; align-items: center; gap: 8px;
  font-family: var(--display);
  font-size: 13px;
  font-weight: 500;
  color: var(--text-tertiary);
}
header.sticky .brand .dot {
  width: 7px; height: 7px; border-radius: 50%;
  background: var(--danger);
  box-shadow: 0 0 8px rgba(239, 68, 68, 0.55);
  animation: pulse 2s ease-in-out infinite;
}
header.sticky .brand .target { color: var(--text-primary); }
header.sticky .brand .sep { color: var(--text-tertiary); }
header.sticky .severity-row { display: flex; gap: 6px; align-items: center; }
header.sticky .size-toggle { display: flex; gap: 4px; padding-right: 8px; border-right: 1px solid var(--border); margin-right: 4px; }
header.sticky .size-toggle button {
  font-family: var(--display);
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  background: transparent;
  border: 1px solid var(--border);
  color: var(--text-tertiary);
  padding: 3px 8px;
  border-radius: 3px;
  cursor: pointer;
  transition: all 120ms ease;
}
header.sticky .size-toggle button:hover { color: var(--text-primary); border-color: var(--border-hover); }
header.sticky .size-toggle button.active { color: var(--text-primary); background: var(--bg-raised); border-color: var(--border-hover); }

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.45; }
}

/* ── Layout ── */
.layout {
  display: grid;
  grid-template-columns: 256px minmax(0, 1fr);
  gap: 64px;
  padding: 40px 28px 96px;
  max-width: 1240px;
  margin: 0 auto;
}

/* ── TOC ── */
.toc {
  position: sticky; top: 64px;
  height: calc(100vh - 80px);
  overflow-y: auto;
  padding: 8px 16px 16px 0;
  scrollbar-width: thin;
  scrollbar-color: var(--border-hover) transparent;
}
.toc::-webkit-scrollbar { width: 6px; }
.toc::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }
.toc h2 {
  font-family: var(--display);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.18em;
  color: var(--text-muted);
  margin: 0 0 12px;
}
.toc ul { list-style: none; padding: 0; margin: 0; }
.toc li { margin: 0; }
.toc li.level-3 { padding-left: 14px; }
.toc a {
  display: block;
  font-family: var(--display);
  font-size: 13px;
  font-weight: 500;
  color: var(--text-tertiary);
  padding: 5px 10px;
  border-left: 1px solid transparent;
  text-decoration: none;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: color 120ms ease, border-color 120ms ease, background 120ms ease;
}
.toc a:hover {
  color: var(--text-primary);
  border-left-color: var(--danger);
  background: var(--bg-surface);
}

/* ── Main content ── */
main { min-width: 0; max-width: 780px; }

main h1 {
  font-family: var(--display);
  font-size: 40px;
  font-weight: 800;
  letter-spacing: -0.025em;
  line-height: 1.08;
  color: #ffffff;
  margin: 0 0 28px;
}

main h2 {
  font-family: var(--display);
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  color: var(--text-muted);
  margin: 64px 0 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--border);
}

main h3 {
  font-family: var(--display);
  font-size: 24px;
  font-weight: 700;
  letter-spacing: -0.018em;
  line-height: 1.2;
  color: #ffffff;
  margin: 40px 0 16px;
}

main h4 {
  font-family: var(--display);
  font-size: 18px;
  font-weight: 600;
  letter-spacing: -0.01em;
  line-height: 1.35;
  color: var(--text-primary);
  margin: 26px 0 12px;
}

main p {
  margin: 14px 0;
  color: var(--text-secondary);
  font-family: var(--display);
  font-size: var(--reading-size);
  font-weight: 400;
  line-height: 1.7;
}
main p strong { color: var(--text-primary); font-weight: 600; }

main ul, main ol {
  padding-left: 24px;
  color: var(--text-secondary);
  font-family: var(--display);
  font-size: var(--reading-size);
  font-weight: 400;
  line-height: 1.7;
}
main li { margin: 8px 0; }
main li strong { color: var(--text-primary); font-weight: 600; }
main ul li::marker { color: var(--text-muted); }
main ol li::marker { color: var(--text-muted); font-weight: 600; }

/* ── Severity badges ── */
.severity-badge {
  display: inline-flex; align-items: center;
  font-family: var(--display);
  padding: 2px 8px;
  border-radius: 3px;
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  border: 1px solid transparent;
  vertical-align: middle;
  white-space: nowrap;
  line-height: 1.4;
}
.severity-badge.critical { background: var(--critical-bg); color: var(--critical-fg); border-color: var(--critical-border); }
.severity-badge.high { background: var(--high-bg); color: var(--high-fg); border-color: var(--high-border); }
.severity-badge.medium { background: var(--medium-bg); color: var(--medium-fg); border-color: var(--medium-border); }
.severity-badge.low { background: var(--low-bg); color: var(--low-fg); border-color: var(--low-border); }
.severity-badge.pass { background: transparent; color: var(--text-tertiary); border-color: var(--border); }
.severity-badge.skip { background: transparent; color: var(--text-tertiary); border-color: var(--border); }

/* ── Finding card ── */
.finding {
  position: relative;
  border: 1px solid var(--border);
  border-left-width: 3px;
  background: var(--bg-surface);
  padding: 18px 22px 20px;
  margin: 16px 0 28px;
  border-radius: 4px;
}
.finding.critical { border-left-color: var(--danger); }
.finding.high { border-left-color: var(--danger); opacity: 1; }
.finding.medium { border-left-color: var(--text-tertiary); }
.finding.low { border-left-color: var(--border-hover); }
.finding > h4:first-child {
  margin: 0 0 14px;
  display: flex; flex-wrap: wrap; align-items: center; gap: 10px;
  font-family: var(--display);
  font-size: 18px;
  font-weight: 700;
  letter-spacing: -0.01em;
  line-height: 1.3;
}
.finding p {
  margin: 10px 0;
  font-size: calc(var(--reading-size) - 1px);
  line-height: 1.65;
  color: var(--text-secondary);
}
.finding ul { margin: 10px 0; font-size: calc(var(--reading-size) - 1px); line-height: 1.65; }
.finding li { margin: 6px 0; }
.finding strong { color: var(--text-primary); font-weight: 600; }

/* ── Code ── */
pre, code, kbd, samp { font-family: var(--mono); }
pre {
  background: #0c0c0e;
  border: 1px solid var(--border);
  padding: 16px 18px;
  border-radius: 4px;
  overflow-x: auto;
  font-size: 13px;
  line-height: 1.65;
  color: #f4f4f5;
  margin: 16px 0;
}

/* Inline code, commands, paths, technical terms get a red-tinted highlight
   so they pop against the helvetica prose. */
code {
  background: var(--code-bg);
  padding: 2px 7px;
  border-radius: 4px;
  font-size: 0.88em;
  font-weight: 500;
  color: var(--code-fg);
  border: 1px solid var(--code-border);
  white-space: nowrap;
}
pre code {
  background: transparent;
  padding: 0;
  border: none;
  font-size: inherit;
  color: inherit;
  font-weight: 400;
  white-space: pre;
}
a code { color: var(--code-fg); }
strong code, h1 code, h2 code, h3 code, h4 code { font-weight: 600; }

img, img.screenshot {
  max-width: 100%;
  border: 1px solid var(--border);
  border-radius: 4px;
  margin: 14px 0;
  display: block;
}

/* ── Tables ── */
table {
  border-collapse: separate;
  border-spacing: 0;
  width: 100%;
  margin: 18px 0;
  font-family: var(--display);
  font-size: calc(var(--reading-size) - 1px);
  border: 1px solid var(--border);
  border-radius: 4px;
  overflow: hidden;
}
th, td {
  border-bottom: 1px solid var(--border);
  padding: 11px 16px;
  text-align: left;
  vertical-align: top;
  color: var(--text-secondary);
  line-height: 1.55;
}
tr:last-child td { border-bottom: none; }
th {
  background: var(--bg-raised);
  font-family: var(--display);
  font-weight: 700;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.16em;
  color: var(--text-primary);
}
td strong { color: var(--text-primary); font-weight: 600; }

blockquote {
  border-left: 2px solid var(--danger);
  background: var(--bg-surface);
  padding: 12px 18px;
  margin: 14px 0;
  color: var(--text-tertiary);
  font-family: var(--display);
  font-size: calc(var(--reading-size) - 2px);
  line-height: 1.6;
  border-radius: 0 4px 4px 0;
}
blockquote p { margin: 4px 0; font-size: inherit; line-height: inherit; color: inherit; }

hr {
  border: none;
  height: 1px;
  background: linear-gradient(to right, transparent, var(--border) 25%, var(--border) 75%, transparent);
  margin: 40px 0;
}

a {
  color: var(--text-primary);
  text-decoration: underline;
  text-decoration-color: var(--text-tertiary);
  text-underline-offset: 0.22em;
  text-decoration-thickness: 1px;
  transition: color 120ms ease, text-decoration-color 120ms ease;
}
a:hover { color: var(--danger); text-decoration-color: var(--danger); }

.confidential-banner {
  position: fixed; bottom: 0; left: 0; right: 0;
  background: var(--danger);
  color: #ffffff;
  padding: 9px 16px;
  text-align: center;
  font-family: var(--display);
  font-weight: 700;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  z-index: 100;
}

@media (max-width: 960px) {
  .layout { grid-template-columns: 1fr; padding: 16px; gap: 24px; }
  .toc { position: relative; top: auto; height: auto; padding: 0 0 16px; border-bottom: 1px solid var(--border); }
  header.sticky { padding: 12px 16px; flex-wrap: wrap; }
  header.sticky .severity-row { flex-wrap: wrap; }
  main h1 { font-size: 28px; }
}

@media print {
  :root { color-scheme: light; }
  html, body { background: #ffffff; color: #09090b; }
  header.sticky, .toc, .no-print, .confidential-banner { display: none !important; }
  .layout { grid-template-columns: 1fr; padding: 0; max-width: none; }
  main { max-width: none; }
  .finding { page-break-inside: avoid; background: #ffffff; border-color: #d4d4d8; }
  main h1, main h2, main h3, main h4 { color: #09090b; }
  main p, main li, .finding p, .finding ul { color: #27272a; }
  pre, code { background: #f4f4f5; color: #09090b; border-color: #d4d4d8; }
  th { background: #f4f4f5; color: #09090b; }
  th, td { color: #27272a; border-color: #d4d4d8; }
  a { color: #09090b; }
}
"""


SEVERITY_KEYWORDS = {
    "critical": "critical",
    "high": "high",
    "medium": "medium",
    "low": "low",
    "passing": "pass",
    "pass": "pass",
    "skip": "skip",
    "skipped": "skip",
}


def parse_inline(text: str) -> str:
    """Inline markdown to HTML: bold, italic, code, links, images."""
    # Images: ![alt](src)
    text = re.sub(r"!\[([^\]]*)\]\(([^)]+)\)", r'<img alt="\1" src="\2" class="screenshot">', text)
    # Links: [text](url)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
    # Inline code: `code`
    text = re.sub(r"`([^`]+)`", lambda m: f"<code>{html.escape(m.group(1))}</code>", text)
    # Bold: **text**
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    # Italic: *text*
    text = re.sub(r"(?<![*\w])\*([^*]+)\*(?!\*)", r"<em>\1</em>", text)
    return text


def severity_class(line: str) -> str | None:
    """Detect a severity keyword in a heading or finding line and return its class."""
    lower = line.lower()
    # Check heading-style finding declarations: "#### Finding 1: ... Critical"
    for keyword, cls in SEVERITY_KEYWORDS.items():
        if re.search(rf"\b{keyword}\b", lower):
            return cls
    return None


def parse_markdown(md: str) -> tuple[str, list[tuple[int, str, str]]]:
    """Parse a markdown string into HTML and a TOC list of (level, anchor, text).

    Handles: headings, paragraphs, code fences (including indented fences inside
    list items), tables, blockquotes, ul/ol with multi-line items, inline emphasis.
    Tracks the current severity context (most recent ### heading inside
    "What needs work") so #### Finding entries get wrapped as .finding sections.
    """
    lines = md.split("\n")
    out: list[str] = []
    toc: list[tuple[int, str, str]] = []
    i = 0
    in_code = False
    code_lang = ""
    code_indent = 0
    code_buf: list[str] = []
    in_table = False
    table_rows: list[list[str]] = []
    in_list = False
    list_type = "ul"
    list_items: list[str] = []
    current_severity: str | None = None  # last seen Critical/High/Medium/Low h3

    def flush_list() -> None:
        nonlocal in_list, list_items
        if in_list:
            out.append(f"<{list_type}>")
            for item in list_items:
                out.append(f"<li>{render_list_item(item)}</li>")
            out.append(f"</{list_type}>")
            list_items = []
            in_list = False

    def render_list_item(item: str) -> str:
        """Render a list item that may contain inline code blocks (delimited by
        ``` fences embedded as literal text), nested paragraphs, and inline
        formatting. Splits on ``` fences first, then runs inline parsing on the
        non-code parts."""
        if "```" not in item:
            return parse_inline(item)
        parts = item.split("```")
        rendered: list[str] = []
        for idx, part in enumerate(parts):
            if idx % 2 == 0:
                if part:
                    rendered.append(parse_inline(part))
            else:
                # First line may carry a language tag.
                first_nl = part.find("\n")
                if first_nl != -1:
                    lang = part[:first_nl].strip() or "text"
                    body = part[first_nl + 1:]
                else:
                    lang = "text"
                    body = part
                rendered.append(
                    f'<pre><code class="language-{html.escape(lang)}">'
                    + html.escape(body.rstrip("\n"))
                    + "</code></pre>"
                )
        return "".join(rendered)

    def flush_table() -> None:
        nonlocal in_table, table_rows
        if in_table and table_rows:
            out.append("<table>")
            if table_rows:
                out.append("<thead><tr>")
                for cell in table_rows[0]:
                    out.append(f"<th>{parse_inline(cell.strip())}</th>")
                out.append("</tr></thead>")
                if len(table_rows) > 2:
                    out.append("<tbody>")
                    for row in table_rows[2:]:
                        out.append("<tr>")
                        for cell in row:
                            out.append(f"<td>{parse_inline(cell.strip())}</td>")
                        out.append("</tr>")
                    out.append("</tbody>")
            out.append("</table>")
            table_rows = []
            in_table = False

    while i < len(lines):
        line = lines[i]
        stripped = line.lstrip()
        # Code fences (allow leading whitespace for fenced blocks inside list items)
        if stripped.startswith("```"):
            indent = len(line) - len(stripped)
            if in_code:
                if in_list and list_items:
                    list_items[-1] += "\n".join(code_buf) + "\n```"
                else:
                    out.append(
                        f'<pre><code class="language-{html.escape(code_lang)}">'
                        + html.escape("\n".join(code_buf))
                        + "</code></pre>"
                    )
                code_buf = []
                code_lang = ""
                code_indent = 0
                in_code = False
            else:
                if not in_list:
                    flush_list()
                flush_table()
                in_code = True
                code_indent = indent
                code_lang = stripped[3:].strip() or "text"
                if in_list and list_items:
                    list_items[-1] += "\n```" + code_lang + "\n"
            i += 1
            continue
        if in_code:
            # Strip up to code_indent leading spaces so list-item-indented code
            # blocks render with their natural indentation.
            if line.startswith(" " * code_indent):
                code_buf.append(line[code_indent:])
            else:
                code_buf.append(line)
            i += 1
            continue
        # Tables (lines containing pipes; second line should be a separator)
        if "|" in line and (i + 1 < len(lines) and re.match(r"^\s*\|?[\s\-:|]+\|?\s*$", lines[i + 1])):
            flush_list()
            in_table = True
            row = [cell for cell in line.strip().strip("|").split("|")]
            table_rows.append(row)
            i += 1
            continue
        if in_table and "|" in line:
            row = [cell for cell in line.strip().strip("|").split("|")]
            table_rows.append(row)
            i += 1
            continue
        if in_table and "|" not in line:
            flush_table()
        # Headings
        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m:
            flush_list()
            flush_table()
            level = len(m.group(1))
            heading_text = m.group(2).strip()
            anchor = re.sub(r"[^a-z0-9-]+", "-", heading_text.lower()).strip("-")
            toc.append((level, anchor, heading_text))
            tag = f"h{level}"
            # Track severity context from h3 headings inside the report.
            if level == 3:
                heading_lower = heading_text.lower().strip()
                if heading_lower in ("critical", "high", "medium", "low"):
                    current_severity = heading_lower
                else:
                    current_severity = None
            # Close any open finding before any new heading (h2/h3/h4).
            if level <= 4:
                out.append("<!--FINDING_CLOSE-->")
            # h4 "Finding N: ..." gets wrapped in a .finding section, severity
            # taken from the surrounding h3 context.
            is_finding_heading = level == 4 and re.match(r"^Finding\s+\d+", heading_text)
            if is_finding_heading and current_severity:
                severity = current_severity
                out.append(f'<section class="finding {severity}" id="{anchor}">')
                out.append(
                    f'<{tag}><span class="severity-badge {severity}">{severity}</span> '
                    f'{parse_inline(heading_text)}</{tag}>'
                )
                out.append("<!--FINDING_OPEN-->")
            else:
                out.append(f'<{tag} id="{anchor}">{parse_inline(heading_text)}</{tag}>')
            i += 1
            continue
        # Horizontal rule
        if re.match(r"^---+\s*$", line):
            flush_list()
            flush_table()
            out.append("<hr>")
            i += 1
            continue
        # Blockquote
        if line.startswith(">"):
            flush_list()
            out.append(f"<blockquote>{parse_inline(line.lstrip('> ').rstrip())}</blockquote>")
            i += 1
            continue
        # List item start
        list_match = re.match(r"^([-*]|\d+\.)\s+(.*)$", line)
        if list_match:
            flush_table()
            new_type = "ol" if list_match.group(1)[0].isdigit() else "ul"
            if not in_list:
                in_list = True
                list_type = new_type
            list_items.append(list_match.group(2))
            i += 1
            continue
        # Continuation of a list item (indented line, non-empty)
        if in_list and line.startswith("  ") and line.strip() and list_items:
            list_items[-1] += "\n" + line[2:]
            i += 1
            continue
        if in_list and line.strip() == "":
            # Blank line inside a list: peek; if next non-blank is indented, keep list open.
            j = i + 1
            while j < len(lines) and lines[j].strip() == "":
                j += 1
            if j < len(lines) and (lines[j].startswith("  ") or re.match(r"^([-*]|\d+\.)\s+", lines[j])):
                i = j
                continue
            flush_list()
            i = j
            continue
        if in_list:
            flush_list()
        # Empty line
        if line.strip() == "":
            i += 1
            continue
        # Paragraph
        flush_table()
        out.append(f"<p>{parse_inline(line)}</p>")
        i += 1

    flush_list()
    flush_table()
    if in_code:
        out.append(
            f'<pre><code class="language-{html.escape(code_lang)}">'
            + html.escape("\n".join(code_buf))
            + "</code></pre>"
        )

    body_html = "\n".join(out)

    # Resolve finding open / close markers. A finding is closed by the next
    # FINDING_CLOSE marker (emitted before any new h2/h3/h4) or by EOF.
    rebuilt: list[str] = []
    open_count = 0
    for token in re.split(r"(<!--FINDING_OPEN-->|<!--FINDING_CLOSE-->)", body_html):
        if token == "<!--FINDING_OPEN-->":
            open_count += 1
        elif token == "<!--FINDING_CLOSE-->":
            if open_count > 0:
                rebuilt.append("</section>")
                open_count -= 1
        else:
            rebuilt.append(token)
    while open_count > 0:
        rebuilt.append("</section>")
        open_count -= 1
    body_html = "".join(rebuilt)

    return body_html, toc


def render_toc(toc: list[tuple[int, str, str]]) -> str:
    """Render TOC entries (level 2 and 3) as a sticky nav."""
    out = ["<nav class='toc' aria-label='Table of contents'>", "<h2>Contents</h2>", "<ul>"]
    for level, anchor, text in toc:
        if level == 2:
            out.append(f'<li class="level-2"><a href="#{anchor}">{html.escape(text)}</a></li>')
        elif level == 3:
            out.append(f'<li class="level-3"><a href="#{anchor}">{html.escape(text)}</a></li>')
    out.append("</ul></nav>")
    return "\n".join(out)


def extract_target_name(md: str) -> str:
    m = re.search(r"^# SEO Audit Report,?\s*(.+?)$", md, re.MULTILINE)
    if m:
        return m.group(1).strip()
    return "Audit Report"


def extract_severity_counts(md: str) -> str:
    """Pull severity counts table and render as inline badges in the header."""
    pattern = re.compile(r"\| Critical \| (\d+) \|.*?\| High \| (\d+) \|.*?\| Medium \| (\d+) \|.*?\| Low \| (\d+) \|", re.DOTALL)
    m = pattern.search(md)
    if not m:
        return ""
    return (
        f'<span class="severity-badge critical">Crit {m.group(1)}</span>'
        f'<span class="severity-badge high">High {m.group(2)}</span>'
        f'<span class="severity-badge medium">Med {m.group(3)}</span>'
        f'<span class="severity-badge low">Low {m.group(4)}</span>'
    )


def render_html(md: str, confidential: bool = False) -> str:
    target = extract_target_name(md)
    severity_inline = extract_severity_counts(md)
    body_html, toc = parse_markdown(md)
    toc_html = render_toc(toc)

    confidential_html = ""
    if confidential:
        confidential_html = '<div class="confidential-banner">CONFIDENTIAL — DO NOT DISTRIBUTE</div>'

    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<title>snitch://audit, {html.escape(target)}</title>
<style>
{CSS_TEMPLATE}
</style>
</head>
<body data-size="default">
<header class="sticky">
  <div class="brand">
    <span class="dot" aria-hidden="true"></span>
    <span>snitch</span>
    <span class="sep">/</span>
    <span>marketing audit</span>
    <span class="sep">/</span>
    <span class="target">{html.escape(target)}</span>
  </div>
  <div class="severity-row">
    <div class="size-toggle" role="group" aria-label="Reading size">
      <button type="button" data-size="default" class="active" title="Default reading size">A</button>
      <button type="button" data-size="comfy" title="Comfortable">A+</button>
      <button type="button" data-size="large" title="Large">A++</button>
    </div>
    {severity_inline}
  </div>
</header>
<div class="layout">
  {toc_html}
  <main>
{body_html}
  </main>
</div>
{confidential_html}
<script>
(function () {{
  var body = document.body;
  var stored = null;
  try {{ stored = localStorage.getItem('snitchAuditSize'); }} catch (e) {{}}
  if (stored) body.setAttribute('data-size', stored);
  var current = body.getAttribute('data-size') || 'default';
  var buttons = document.querySelectorAll('header.sticky .size-toggle button');
  buttons.forEach(function (btn) {{
    btn.classList.toggle('active', btn.getAttribute('data-size') === current);
    btn.addEventListener('click', function () {{
      var size = btn.getAttribute('data-size');
      body.setAttribute('data-size', size);
      buttons.forEach(function (b) {{ b.classList.toggle('active', b === btn); }});
      try {{ localStorage.setItem('snitchAuditSize', size); }} catch (e) {{}}
    }});
  }});
}})();
</script>
</body>
</html>
"""


def main() -> int:
    parser = argparse.ArgumentParser(description="Render Snitch: Marketing markdown to HTML.")
    parser.add_argument("input", help="Path to SEO_AUDIT_REPORT.md")
    parser.add_argument("--confidential", action="store_true", help="Add CONFIDENTIAL banner")
    args = parser.parse_args()

    md_path = Path(args.input)
    if not md_path.is_file():
        print(f"error: {args.input} is not a file", file=sys.stderr)
        return 2

    md = md_path.read_text(encoding="utf-8")
    html_output = render_html(md, confidential=args.confidential)
    out_path = md_path.with_suffix(".html")
    out_path.write_text(html_output, encoding="utf-8")
    print(f"wrote {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
