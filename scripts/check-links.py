"""Checks every relative link in the repository's Markdown, outside archive/: the file or
directory it names must exist, and so must the heading its #anchor names.

usage: python3 scripts/check-links.py [ROOT]

Anchors are computed as GitHub computes them: the heading's text, lowercased, with
punctuation other than hyphens and underscores removed, and spaces turned into hyphens; a
repeated heading gets -1, -2 and so on. Links to other sites aren't checked, since CI may
not reach them. Exits non-zero, listing each broken link, if any is broken.
"""
import os
import re
import sys
import urllib.parse

LINK = re.compile(r"!?\[(?:[^\[\]]|\[[^\]]*\])*\]\(\s*<?([^)\s>]+)>?(?:\s+\"[^\"]*\")?\s*\)")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")


def strip_code(text):
    """Text with fenced blocks and inline code removed, line numbers kept."""
    out, fenced = [], False
    for line in text.split("\n"):
        if re.match(r"^\s*(```|~~~)", line):
            fenced = not fenced
            out.append("")
            continue
        out.append("" if fenced else re.sub(r"`[^`]*`", "", line))
    return out


def slug(heading):
    h = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", heading)  # links keep their text
    h = re.sub(r"<[^>]+>", "", h).replace("`", "").replace("*", "")
    h = h.lower()
    h = "".join(c for c in h if c.isalnum() or c in " -_")
    return h.replace(" ", "-")


def anchors(path, cache={}):
    if path not in cache:
        seen, found = {}, set()
        fenced = False
        for line in open(path, encoding="utf-8").read().split("\n"):
            if re.match(r"^\s*(```|~~~)", line):
                fenced = not fenced
                continue
            m = None if fenced else HEADING.match(line)
            if m:
                s = slug(m.group(2))
                n = seen.get(s, 0)
                found.add(s if n == 0 else f"{s}-{n}")
                seen[s] = n + 1
            for a in re.findall(r"<a\s+(?:id|name)=\"([^\"]+)\"", line):
                found.add(a)
        cache[path] = found
    return cache[path]


def main():
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
    broken, checked = [], 0
    for d, dirs, files in os.walk(root):
        dirs[:] = [x for x in dirs if x not in (".git", ".lake", "archive", "node_modules")]
        for f in files:
            if not f.endswith(".md"):
                continue
            path = os.path.join(d, f)
            for i, line in enumerate(strip_code(open(path, encoding="utf-8").read()), 1):
                for target in LINK.findall(line):
                    if re.match(r"^[a-z][a-z0-9+.-]*:", target):
                        continue  # another site, or mailto:
                    checked += 1
                    file_part, _, anchor = target.partition("#")
                    dest = (os.path.normpath(os.path.join(d, urllib.parse.unquote(file_part)))
                            if file_part else path)
                    where = f"{os.path.relpath(path, root)}:{i}: {target}"
                    if not os.path.exists(dest):
                        broken.append(f"{where}: no such file")
                    elif anchor and dest.endswith(".md") and anchor not in anchors(dest):
                        broken.append(f"{where}: no heading #{anchor}")
    for b in broken:
        print(b)
    print(f"{checked} links checked, {len(broken)} broken")
    sys.exit(1 if broken else 0)


if __name__ == "__main__":
    main()
