"""The trusted job's rebuild of the release's dependencies, from the pin, with git alone
(guide/EXECUTABLE_GATE.md §4). It runs none of the release's code.

usage: python3 scripts/pilot_deps.py RELEASE_LEAN_DIR LIBSPEC_LEAN_DIR

For each package in the release's lake-manifest.json:
- if LibSpec's own manifest pins it at the same commit, as it does Mathlib and its own
  dependencies, LibSpec's checkout of it moves over, with the build outputs that
  `lake exe cache get` fetched for it;
- otherwise it is cloned from its URL and checked out at its commit, as Lake would.
Each gets the manifest's URL as its origin, which the release's lakefile checks.

Then every patch in the release's patches/ directory is applied to its package, as the release's
lakefile does: patches/<name>-lean4341.patch to .lake/packages/<name>. Every check is on the
release's data: names, URLs and commits must be plain, and a patch must belong to a package.
"""
import json
import os
import re
import shutil
import subprocess
import sys

SUFFIX = "-lean4341.patch"
NAME = re.compile(r"^[A-Za-z0-9_.-]+$")
REV = re.compile(r"^[0-9a-f]{40}$")
URL = re.compile(r"^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
GIT = ["git", "-c", "protocol.allow=never", "-c", "protocol.https.allow=always",
       "-c", "advice.detachedHead=false"]


def git(*args, cwd=None):
    r = subprocess.run(GIT + list(args), cwd=cwd, capture_output=True, text=True,
                       env=dict(os.environ, GIT_TERMINAL_PROMPT="0"))
    if r.returncode != 0:
        sys.exit(f"FAIL: git {' '.join(args)}\n{r.stderr}")
    return r.stdout.strip()


def packages(lean_dir):
    m = json.load(open(os.path.join(lean_dir, "lake-manifest.json"), encoding="utf-8"))
    out = {}
    for p in m["packages"]:
        name, url, rev = p["name"], p.get("url", ""), p.get("rev", "")
        # A name Lean escapes, such as «doc-gen4», has its directory under the plain name.
        if name.startswith("«") and name.endswith("»"):
            name = name[1:-1]
        if p.get("type") != "git" or not NAME.match(name) or name.startswith(".") or \
                not REV.match(rev) or not URL.match(url) or p.get("subDir"):
            sys.exit(f"FAIL: a manifest entry isn't a plain pinned Git package: {p}")
        if name in out:
            sys.exit(f"FAIL: two manifest entries for {name}")
        out[name] = (url, rev)
    return out


def main():
    release, libspec = (os.path.abspath(x) for x in sys.argv[1:3])
    theirs, ours = packages(release), packages(libspec)
    dest = os.path.join(release, ".lake", "packages")
    if os.path.exists(dest):
        sys.exit(f"FAIL: {dest} exists already; the rebuild starts from nothing")
    os.makedirs(dest)
    for name, (url, rev) in sorted(theirs.items()):
        target = os.path.join(dest, name)
        mine = os.path.join(libspec, ".lake", "packages", name)
        if name in ours and ours[name][1] == rev and os.path.isdir(mine):
            shutil.move(mine, target)
            how = "LibSpec's own"
        else:
            git("clone", "--quiet", "--no-checkout", url, target)
            git("checkout", "--quiet", "--detach", rev, cwd=target)
            how = "cloned"
        git("remote", "set-url", "origin", url, cwd=target)
        if git("rev-parse", "HEAD", cwd=target) != rev:
            sys.exit(f"FAIL: {name} isn't at {rev}")
        print(f"{name}: {rev[:12]} ({how})")

    patches = os.path.join(release, "patches")
    for f in sorted(os.listdir(patches)):
        if f == "README.md":
            continue
        name = f[:-len(SUFFIX)] if f.endswith(SUFFIX) else None
        if name not in theirs:
            sys.exit(f"FAIL: patches/{f} belongs to no package in the manifest")
        target = os.path.join(dest, name)
        git("apply", os.path.join(patches, f), cwd=target)
        git("apply", "--check", "--reverse", os.path.join(patches, f), cwd=target)
        print(f"{name}: patched with {f}")
    print(f"ok: {len(theirs)} packages at their manifest commits")


if __name__ == "__main__":
    main()
