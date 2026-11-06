"""Fails unless .github/CODEOWNERS gives @marleymcwilliams each path it's given.

GitHub requires a code owner's approval to merge a pull request that touches an owned path, and
CLAUDE.md's self-merge rule points to the same file. scripts/check.sh passes every file the
statements check covers, and .github/CODEOWNERS itself, so neither can quietly leave the list.

As on GitHub, the last rule in the file that matches a path decides it. That rule must name the
path exactly, or a directory above it ending in /, from the repository's root (/lean/JSG/Defs.lean,
/lean/), and list @marleymcwilliams among its owners. A glob, or a pattern not anchored at the root, is
counted as a match whenever it might be one, so the check fails rather than guesses.

usage: python3 scripts/codeowners_check.py CODEOWNERS PATH...
"""
import re
import sys

OWNER = "@marleymcwilliams"


def rules(text):
    """Each rule in order: its line number, its pattern and its owners. '#' starts a comment."""
    found = []
    for number, line in enumerate(text.splitlines(), 1):
        words = line.split()
        if not words or words[0].startswith("#"):
            continue
        owners = []
        for word in words[1:]:
            if word.startswith("#"):
                break
            owners.append(word)
        found.append((number, words[0], owners))
    return found


def names(pattern, path):
    """Whether the pattern is the path from the root, or a directory above it ending in /."""
    return pattern == "/" + path or (
        len(pattern) > 1 and pattern.startswith("/") and pattern.endswith("/")
        and ("/" + path).startswith(pattern))


def regex(pattern):
    """The pattern as a regular expression over a file's path, read as gitignore reads it: a
    pattern that matches a directory matches everything under it. GitHub reads `docs/*` more
    narrowly, matching only the files directly in docs/, so this errs towards a match."""
    anchored = pattern.startswith("/") or "/" in pattern.rstrip("/")
    directory = pattern.endswith("/")
    body = pattern.strip("/")
    out = ""
    i = 0
    while i < len(body):
        if body.startswith("**/", i):
            out += "(?:.*/)?"
            i += 3
        elif body.startswith("**", i):
            out += ".*"
            i += 2
        elif body[i] == "*":
            out += "[^/]*"
            i += 1
        elif body[i] == "?":
            out += "[^/]"
            i += 1
        else:
            out += re.escape(body[i])
            i += 1
    return ("" if anchored else "(?:.*/)?") + out + ("/.*" if directory else "(?:/.*)?")


def matches(pattern, path):
    """Whether the pattern could match the path on GitHub. GitHub doesn't support character
    ranges, escapes or negation, so a pattern using any of them, or naming only the root, counts
    as a match."""
    if not pattern.strip("/") or any(c in pattern for c in "[]\\!"):
        return True
    return re.fullmatch(regex(pattern), path) is not None


def main(argv):
    if len(argv) < 3:
        print("usage: python3 scripts/codeowners_check.py CODEOWNERS PATH...")
        return 2
    codeowners, paths = argv[1], argv[2:]
    try:
        with open(codeowners, encoding="utf-8") as f:
            found = rules(f.read())
    except OSError as e:
        print(f"FAIL: can't read {codeowners}: {e.strerror}")
        return 1
    failed = False
    for path in paths:
        deciding = None
        for rule in found:
            if matches(rule[1], path):
                deciding = rule
        if deciding is None:
            print(f"FAIL: no rule covers {path}")
        else:
            number, pattern, owners = deciding
            if not names(pattern, path):
                print(f"FAIL: {path} is decided by line {number}, {pattern}, which is neither "
                      f"/{path} nor a directory above it ending in /")
            elif OWNER.lower() not in (owner.lower() for owner in owners):
                print(f"FAIL: {path} is decided by line {number}, {pattern}, whose owners are "
                      f"{' '.join(owners) or 'none'}")
            else:
                continue
        failed = True
    if failed:
        return 1
    print(f"ok: {OWNER} owns all {len(paths)}: {', '.join(paths)}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
