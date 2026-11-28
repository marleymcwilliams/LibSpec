"""Checks the links in the repository, outside archive/, offline.

usage: python3 scripts/check-links.py [ROOT] [--repo OWNER/NAME] [--pin TAG=COMMIT]...

Relative links, in the Markdown: the file or directory each names must exist, and so must
the heading its #anchor names. A relative link into archive/ fails: link to the file at a
pinned tag instead.

Permanent links, in every file git tracks or would track, whatever its type: links to
https://github.com/OWNER/NAME/blob/REF/PATH or .../tree/REF/PATH, where OWNER/NAME is this
repository (REPO below, in any case). REF must be a full commit id, or a tag in PINS. That
commit must be in HEAD's history, and PATH must be a file there for blob, or a directory for
tree. An #ANCHOR is allowed only on a link to a Markdown file, and must name one of its
headings at that commit; it is compared percent-decoded. A query, ?..., fails. Each tag in
PINS must name the commit PINS gives it, whether or not a link uses it. This needs the
clone's full history and its tags, as CI's checkout has.

Anchors are computed as GitHub computes them: the heading's text, lowercased, with
punctuation other than hyphens and underscores removed, and spaces turned into hyphens; a
repeated heading gets -1, -2 and so on. Links to other sites aren't checked, since CI may
not reach them. Exits non-zero, listing each broken link, if any is broken.

--repo and --pin are for scripts/test-check-links.sh: --repo replaces REPO, and any --pin
replaces all of PINS.
"""
import argparse
import os
import re
import subprocess
import sys
import urllib.parse

REPO = "marleymcwilliams/LibSpec"

# The tags a permanent link may name, and the commit each must name. A tag can move and a
# commit id can't, so a link at a tag holds only while the tag names the commit pinned here.
PINS = {
    # The v1.1 release, whose tag is immutable; archive/ stays readable there.
    "v1.1": "6f2ffae5d3eebda441730bdd6b671258d7aeac0c",
    # Frozen section 16 cites guide/ROADMAP.md, which main no longer holds, as of this tag.
    "statements-v5": "5006a217e4b1def632173916263ff637742b8aa5",
}

SKIP = (".git", ".lake", "archive", "node_modules")
LINK = re.compile(r"!?\[(?:[^\[\]]|\[[^\]]*\])*\]\(\s*<?([^)\s>]+)>?(?:\s+\"[^\"]*\")?\s*\)")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
# A permanent link stops at a space, a bracket, a quote, | or *, and doesn't end on
# punctuation, so a sentence's full stop isn't part of it.
URL_CHAR = r"""[^\s<>()\[\]"'`|*]"""
URL_END = r"""[^\s<>()\[\]"'`|*.,;:!?]"""
FULL_ID = re.compile(r"[0-9a-f]{40}")
SHORT_ID = re.compile(r"[0-9a-f]{7,39}")


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


def anchors_in(text):
    """The anchors of a Markdown text: its headings' slugs, and its <a id> and <a name>."""
    seen, found = {}, set()
    fenced = False
    for line in text.split("\n"):
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
    return found


def anchors(path, cache={}):
    if path not in cache:
        cache[path] = anchors_in(open(path, encoding="utf-8").read())
    return cache[path]


def git(root, *args):
    r = subprocess.run(["git", "-C", root, *args],
                       stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    return r.returncode, r.stdout


def text_of(data):
    """Bytes as text with Python's newlines, or None for a binary or non-UTF-8 file."""
    if b"\0" in data:
        return None
    try:
        return data.decode("utf-8").replace("\r\n", "\n").replace("\r", "\n")
    except UnicodeDecodeError:
        return None


def relative_links(root):
    checked, broken = 0, []
    for d, dirs, files in os.walk(root):
        dirs[:] = [x for x in dirs if x not in SKIP]
        for f in files:
            if not f.endswith(".md"):
                continue
            path = os.path.join(d, f)
            for i, line in enumerate(strip_code(open(path, encoding="utf-8").read()), 1):
                for target in LINK.findall(line):
                    if re.match(r"^[a-z][a-z0-9+.-]*:", target):
                        continue  # another site, or mailto:; permanent links are checked below
                    checked += 1
                    file_part, _, anchor = target.partition("#")
                    dest = (os.path.normpath(os.path.join(d, urllib.parse.unquote(file_part)))
                            if file_part else path)
                    where = f"{os.path.relpath(path, root)}:{i}: {target}"
                    if os.path.relpath(dest, root).split(os.sep)[0] == "archive":
                        broken.append(f"{where}: inside archive/: link to it at a pinned tag")
                    elif not os.path.exists(dest):
                        broken.append(f"{where}: no such file")
                    elif anchor and dest.endswith(".md") and anchor not in anchors(dest):
                        broken.append(f"{where}: no heading #{anchor}")
    return checked, broken


def permanent_link_problem(root, kind, rest, pins, cache):
    """Why a permanent link, given as its kind and REF/PATH?QUERY#ANCHOR, is broken, or None."""
    rest, _, anchor = rest.partition("#")
    rest, query, _ = rest.partition("?")
    ref, _, path = rest.partition("/")
    path = urllib.parse.unquote(path)
    if query:
        return "a query isn't checked: drop it"
    if FULL_ID.fullmatch(ref):
        commit = ref
    elif ref in pins:
        commit = pins[ref]
    elif SHORT_ID.fullmatch(ref):
        return "a short commit id: use all 40 characters"
    else:
        return f"{ref} is a branch, or a tag not in PINS: use a full commit id or a pinned tag"
    if commit not in cache:
        code, out = git(root, "cat-file", "-t", commit)
        if code != 0 or out.strip() != b"commit":
            cache[commit] = f"{commit} isn't a commit in this clone"
        elif git(root, "merge-base", "--is-ancestor", commit, "HEAD")[0] != 0:
            cache[commit] = f"{ref} isn't in HEAD's history"
        else:
            cache[commit] = None
    if cache[commit]:
        return cache[commit]
    if path:
        code, out = git(root, "cat-file", "-t", f"{commit}:{path}")
        found = out.strip().decode() if code == 0 else None
    else:
        found = "tree"
    if found is None:
        return f"no such path at {ref}"
    if found != ("blob" if kind == "blob" else "tree"):
        return f"not a {'file' if kind == 'blob' else 'directory'} at {ref}"
    if anchor:
        if kind != "blob" or not path.endswith(".md"):
            return "an anchor is checked only on a Markdown file: drop it"
        if (commit, path) not in cache:
            data = git(root, "cat-file", "blob", f"{commit}:{path}")[1]
            cache[(commit, path)] = anchors_in(text_of(data) or "")
        if urllib.parse.unquote(anchor) not in cache[(commit, path)]:
            return f"no heading #{anchor} at {ref}"
    return None


def permanent_links(root, repo, pins):
    broken = []
    for tag, commit in sorted(pins.items()):
        code, out = git(root, "rev-parse", "-q", "--verify", f"refs/tags/{tag}^{{commit}}")
        named = out.decode().strip()
        if code != 0:
            broken.append(f"tag {tag} is missing: fetch tags (git fetch --tags)")
        elif named != commit:
            broken.append(f"tag {tag} names {named}, but PINS pins it to {commit}")
    link = re.compile(r"https?://(?:www\.)?github\.com/(?i:" + re.escape(repo) + r")/(blob|tree)/("
                      + URL_CHAR + "*" + URL_END + ")")
    code, out = git(root, "ls-files", "-z", "--cached", "--others", "--exclude-standard")
    if code != 0:
        return 0, broken + ["git ls-files failed: permanent links need a git clone"]
    checked, cache = 0, {}
    for name in sorted(set(out.decode("utf-8").split("\0"))):
        path = os.path.join(root, *name.split("/"))
        if (not name or set(name.split("/")) & set(SKIP)
                or os.path.islink(path) or not os.path.isfile(path)):
            continue
        text = text_of(open(path, "rb").read())
        if text is None:
            continue
        for i, line in enumerate(text.split("\n"), 1):
            for m in link.finditer(line):
                checked += 1
                problem = permanent_link_problem(root, m.group(1), m.group(2), pins, cache)
                if problem:
                    broken.append(f"{name}:{i}: {m.group(0)}: {problem}")
    return checked, broken


def main():
    p = argparse.ArgumentParser(description="Checks the links in the repository, offline.")
    p.add_argument("root", nargs="?", default=".")
    p.add_argument("--repo", default=REPO)
    p.add_argument("--pin", action="append", metavar="TAG=COMMIT")
    args = p.parse_args()
    # A path or an anchor can be non-ASCII, and on Windows a pipe's default encoding can't
    # print it.
    sys.stdout.reconfigure(encoding="utf-8", errors="backslashreplace")
    root = os.path.abspath(args.root)
    pins = dict(x.split("=", 1) for x in args.pin) if args.pin else PINS
    checked, broken = relative_links(root)
    for b in broken:
        print(b)
    print(f"{checked} links checked, {len(broken)} broken")
    p_checked, p_broken = permanent_links(root, args.repo, pins)
    for b in p_broken:
        print(b)
    print(f"{p_checked} permanent links and {len(pins)} pinned tags checked, "
          f"{len(p_broken)} broken")
    sys.exit(1 if broken or p_broken else 0)


if __name__ == "__main__":
    main()
