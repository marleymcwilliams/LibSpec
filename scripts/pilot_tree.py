"""The tree that Phase 7's two jobs compare (guide/EXECUTABLE_GATE.md §4): the release's lean/
directory as `lake update` leaves it, sources only.

usage: python3 scripts/pilot_tree.py pack RELEASE_DIR OUT.tar      (the untrusted job)
       python3 scripts/pilot_tree.py verify DOWNLOAD_DIR RELEASE_DIR (the trusted job)

The tree is every file and symbolic link under RELEASE_DIR/lean, except:
- anything in a .git directory;
- the files directly in lean/.lake, and everything in it outside lean/.lake/packages;
- each package's own .lake directory, which holds its build outputs.

`pack` writes the tree as a tar. `verify` refuses, exiting 1, unless DOWNLOAD_DIR holds exactly
one file, release-tree.tar, whose entries are exactly RELEASE_DIR's tree, byte for byte. It reads
the tar as a stream and extracts nothing, so nothing in it lands on disk. The trusted job builds
only from its own RELEASE_DIR, so a tar that passes changes nothing it uses. A tar that fails
stops the job before any build.
"""
import hashlib
import json
import os
import sys
import tarfile

NAME = "release-tree.tar"


def skip_dir(rel):
    parts = rel.split("/")
    if ".git" in parts:
        return True
    if parts[:2] == ["lean", ".lake"]:
        if len(parts) == 2:
            return False  # lean/.lake itself: go in, to reach the packages
        if parts[2] != "packages":
            return True  # lean/.lake/build, lean/.lake/config and the like
        if len(parts) >= 5 and parts[4] == ".lake":
            return True  # a package's own build outputs
    return False


def entries(root):
    """{path: identity} for the tree under root/lean. A file's identity is its SHA-256, and a
    link's is its target."""
    out = {}
    base = os.path.join(root, "lean")
    for d, dirs, files in os.walk(base):
        rel_d = os.path.relpath(d, root).replace(os.sep, "/")
        for x in list(dirs):
            full = os.path.join(d, x)
            if os.path.islink(full):
                dirs.remove(x)
                files.append(x)  # a link to a directory is an entry, not a place to go
            elif skip_dir(f"{rel_d}/{x}"):
                dirs.remove(x)
        if rel_d == "lean/.lake":
            continue  # its own files, such as lakefile.olean, are build state
        for x in files:
            full = os.path.join(d, x)
            rel = f"{rel_d}/{x}"
            if os.path.islink(full):
                out[rel] = "link:" + os.readlink(full)
            elif os.path.isfile(full):
                h = hashlib.sha256()
                with open(full, "rb") as f:
                    for chunk in iter(lambda: f.read(1 << 20), b""):
                        h.update(chunk)
                out[rel] = h.hexdigest()
    return out


def pack(root, out):
    tree = entries(root)
    with tarfile.open(out, "w", format=tarfile.GNU_FORMAT) as t:
        for rel in sorted(tree):
            t.add(os.path.join(root, *rel.split("/")), arcname=rel, recursive=False)
    print(f"packed {len(tree)} entries into {out}")


def tar_entries(path):
    """{path: identity} for a tar, read as a stream. Any entry that isn't a plain file or link
    with a clean relative path under lean/ is a refusal in itself."""
    out, bad = {}, []
    with tarfile.open(path, "r|") as t:
        for m in t:
            name = m.name
            parts = name.split("/")
            if (not name.startswith("lean/") or name.startswith("/") or ".." in parts
                    or "" in parts or "\\" in name):
                bad.append(f"unsafe path: {name!r}")
                continue
            if m.issym():
                out[name] = "link:" + m.linkname
            elif m.isfile():
                h = hashlib.sha256()
                f = t.extractfile(m)
                for chunk in iter(lambda: f.read(1 << 20), b""):
                    h.update(chunk)
                out[name] = h.hexdigest()
            elif not m.isdir():
                bad.append(f"not a file or a link: {name!r}")
    return out, bad


def same_manifest(a, b):
    """lake update may rewrite lake-manifest.json; the same packages at the same commits pass."""
    try:
        return json.loads(a) == json.loads(b)
    except ValueError:
        return False


def verify(download, root):
    found = sorted(os.listdir(download))
    if found != [NAME] or not os.path.isfile(os.path.join(download, NAME)) or \
            os.path.islink(os.path.join(download, NAME)):
        print(f"REFUSED: the artifact should hold exactly {NAME}; it holds {found}")
        sys.exit(1)
    theirs, bad = tar_entries(os.path.join(download, NAME))
    ours = entries(root)
    problems = list(bad)
    for rel in sorted(set(theirs) | set(ours)):
        if rel not in ours:
            problems.append(f"not in the pin's tree: {rel}")
        elif rel not in theirs:
            problems.append(f"missing from the untrusted tree: {rel}")
        elif theirs[rel] != ours[rel]:
            if rel == "lean/lake-manifest.json":
                problems.append("lean/lake-manifest.json differs; comparing its contents")
                continue
            problems.append(f"differs from the pin: {rel}")
    if any(p.startswith("lean/lake-manifest.json differs") for p in problems):
        problems.remove("lean/lake-manifest.json differs; comparing its contents")
        mine = open(os.path.join(root, "lean", "lake-manifest.json"), "rb").read()
        with tarfile.open(os.path.join(download, NAME), "r|") as t:
            for m in t:
                if m.name == "lean/lake-manifest.json" and m.isfile():
                    if not same_manifest(t.extractfile(m).read(), mine):
                        problems.append("differs from the pin: lean/lake-manifest.json")
                    else:
                        print("note: lake update rewrote lean/lake-manifest.json, same contents")
                    break
    if problems:
        print(f"REFUSED: the untrusted job's tree doesn't match the pin ({len(problems)} problems)")
        for p in problems[:50]:
            print("  " + p)
        sys.exit(1)
    print(f"ok: the untrusted job's tree matches the trusted rebuild, {len(ours)} entries")


def main():
    cmd, a, b = sys.argv[1:4]
    if cmd == "pack":
        pack(a, b)
    elif cmd == "verify":
        verify(a, b)
    else:
        sys.exit(f"usage: {sys.argv[0]} pack|verify ...")


if __name__ == "__main__":
    main()
