"""Markdown-ish text to Atlassian Document Format (ADF), version 1.

    python3 -I adf.py <body-file>

Prints a `{"type": "doc", "version": 1, "content": [...]}` object. Jira
Cloud's v3 API rejects a plain string in `fields.description`; it must be ADF.

What is converted, because it is what the write-ticket skill emits:

- `## heading` lines to heading nodes (level 1-6 from the number of #).
- Fenced code blocks (``` with an optional language) to codeBlock nodes.
- Consecutive `> ` lines to one blockquote (the quoted request).
- Lines starting with `- ` or `* ` to a bulletList; `- [ ] ` and `- [x] `
  keep their brackets as text, since ADF task lists need ids we do not have.
- Everything else to paragraphs, split on blank lines.

Inline markup (backticks, bold, links) is kept as literal text. Jira shows
it as typed, which is honest; a half-converted link is worse.
"""
import json
import re
import sys


def paragraph(text: str) -> dict:
    return {"type": "paragraph", "content": [{"type": "text", "text": text}]}


def convert(src: str) -> dict:
    content: list = []
    lines = src.splitlines()
    i = 0
    para: list[str] = []
    bullets: list[str] = []

    def flush():
        nonlocal para, bullets
        if para:
            content.append(paragraph("\n".join(para)))
            para = []
        if bullets:
            content.append({
                "type": "bulletList",
                "content": [
                    {"type": "listItem", "content": [paragraph(b)]} for b in bullets
                ],
            })
            bullets = []

    while i < len(lines):
        line = lines[i]
        fence = re.match(r"^```(\w*)\s*$", line)
        if fence:
            flush()
            lang = fence.group(1)
            i += 1
            code: list[str] = []
            while i < len(lines) and not lines[i].startswith("```"):
                code.append(lines[i])
                i += 1
            i += 1  # closing fence
            node = {"type": "codeBlock", "content": [{"type": "text", "text": "\n".join(code)}]}
            if lang:
                node["attrs"] = {"language": lang}
            content.append(node)
            continue
        heading = re.match(r"^(#{1,6})\s+(.*)$", line)
        if heading:
            flush()
            content.append({
                "type": "heading",
                "attrs": {"level": len(heading.group(1))},
                "content": [{"type": "text", "text": heading.group(2).strip()}],
            })
            i += 1
            continue
        quote = re.match(r"^>\s?(.*)$", line)
        if quote:
            flush()
            quoted = [quote.group(1)]
            i += 1
            while i < len(lines) and lines[i].startswith(">"):
                quoted.append(re.sub(r"^>\s?", "", lines[i]))
                i += 1
            content.append({"type": "blockquote", "content": [paragraph("\n".join(quoted))]})
            continue
        bullet = re.match(r"^\s*[-*]\s+(.*)$", line)
        if bullet:
            if para:
                flush()
            bullets.append(bullet.group(1))
            i += 1
            continue
        if not line.strip():
            flush()
            i += 1
            continue
        if bullets:
            flush()
        para.append(line.rstrip())
        i += 1
    flush()
    if not content:
        content.append(paragraph(""))
    return {"type": "doc", "version": 1, "content": content}


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    with open(sys.argv[1], encoding="utf-8") as f:
        src = f.read()
    json.dump(convert(src), sys.stdout)
    return 0


if __name__ == "__main__":
    sys.exit(main())
