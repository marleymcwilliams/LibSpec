"""The pilot's collector (guide/EXECUTABLE_GATE.md section 3): raw records and dependency
edges for manuscripts of the openai/math release, pinned to one commit and read as data.

usage: python3 pilot/collect.py [--cache DIR] (--all | FAMILY... [--folder FOLDER]...) > DATA

It fetches only text files at the pinned commit, and directory listings from GitHub's tree
API, and parses them with regular expressions. It writes facts: titles, notice dates,
families, dependency links, challenge names and the axioms each challenge permits. It never
runs, imports or builds anything from the release, and it stores none of its paper text or
Lean code. The release is Apache-2.0 (its root LICENSE and lean/LICENSE at this commit), and
the output names the source, the commit and the license.

Each record holds only facts. The pilot's Lean module turns them into grades
(lean/JSG/Pilot/Core.lean), so nothing the verdict depends on is computed here.

- --all: every manuscript CONTENTS.md lists, and every preprints/ folder whose README carries
  a withdrawal notice. Any other folder is an earlier version of a listed manuscript; it is
  recorded under earlierVersions, with the listed folders of the same title, and not graded.
  A docs page that links an earlier version covers its one listed version, and that
  manuscript's record names the folder the page links (docsLinks).
- FAMILY: a three-digit family number from CONTENTS.md; all its manuscripts are collected.
- --folder: a preprints/ folder to collect as well, such as a withdrawn manuscript, which
  CONTENTS.md no longer lists.
- --cache: a directory that keeps each fetched file, so that a rerun reads it from there.
- --comparator: a JSON file of our Comparator results, {"challenge": "accepted" | "rejected"}.
  A challenge without a result is "notRun".
"""
import argparse
import concurrent.futures
import hashlib
import json
import os
import re
import sys
import urllib.error
import urllib.request

REPOSITORY = "https://github.com/openai/math"
COMMIT = "7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a"
LICENSE = "Apache-2.0"
THREE_AXIOMS = {"propext", "Quot.sound", "Classical.choice"}
# A link into preprints/: a folder name runs to the next "/", and may hold parentheses.
FOLDER_LINK = r"preprints/([^/\s]+)/"
DATED = re.compile(r"-(January|February|March|April|May|June|July|August|September|October|"
                   r"November|December)-\d{1,2}-\d{4}$")

read_paths = []
cache_dir = None
memo = {}


def get(url, key):
    """The bytes at a URL, kept in the cache under key, or None on a 404."""
    if key in memo:
        return memo[key]
    # Named by a hash, since a path's own name can exceed Windows' limit.
    name = hashlib.sha256(key.encode()).hexdigest()[:32]
    path = os.path.join(cache_dir, name) if cache_dir else None
    if path and os.path.exists(path):
        return open(path, "rb").read()
    try:
        with urllib.request.urlopen(url, timeout=60) as r:
            data = r.read()
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise
    if path:
        open(path, "wb").write(data)
    return data


def raw_url(path):
    return f"https://raw.githubusercontent.com/openai/math/{COMMIT}/{path}"


def prefetch(paths):
    """Fetches files eight at a time, so that fetch then finds them."""
    todo = [p for p in paths if p not in memo]
    with concurrent.futures.ThreadPoolExecutor(8) as ex:
        for p, data in zip(todo, ex.map(lambda p: get(raw_url(p), p), todo)):
            memo[p] = data


def fetch(path):
    """A text file at the pinned commit, or None if it doesn't exist."""
    data = get(raw_url(path), path)
    if data is None:
        return None
    read_paths.append(path)
    return data.decode("utf-8")


trees = {}


def listing(path):
    """The names in one directory at the pinned commit. GitHub's recursive listing truncates,
    so this walks the tree API one directory at a time."""
    sha = COMMIT
    for part in [p for p in path.split("/") if p]:
        sha = next(e["sha"] for e in tree(sha) if e["path"] == part and e["type"] == "tree")
    return [e["path"] for e in tree(sha)]


def tree(sha):
    if sha not in trees:
        t = json.loads(get(f"https://api.github.com/repos/openai/math/git/trees/{sha}",
                           f"tree-{sha}"))
        assert not t.get("truncated"), sha
        trees[sha] = t["tree"]
    return trees[sha]


def contents_map(text):
    """CONTENTS.md: each manuscript's folder, with its family and its title there."""
    family, out = None, {}
    for line in text.split("\n"):
        h = re.match(r"\*\*(\d{3})\. ", line.strip())
        if h:
            family = h.group(1)
            continue
        for title, folder in re.findall(r"\[([^\]]+)\]\(" + FOLDER_LINK, line):
            out.setdefault(folder, {"family": family, "title": title})
    return out


def readme_facts(text):
    """A preprint README: its title, its withdrawal date if it has a notice, and the preprint
    folders the notice links to."""
    first = text.split("\n", 1)[0]
    m = re.match(r"# \[(Withdrawal notice: )?(.*?)\]\(", first)
    withdrawn = bool(m and m.group(1))
    title = m.group(2) if m else None
    date = None
    links = []
    if withdrawn:
        d = re.search(r"\*\*Withdrawn on ([A-Z][a-z]+ \d{1,2}, \d{4})\.\*\*", text)
        date = d.group(1) if d else "undated"
        notice = text.split("\n## ", 1)[0]
        links = sorted(set(re.findall(FOLDER_LINK, notice)))
    return {"title": title, "withdrawnOn": date, "noticeLinks": links}


def docs_facts(text):
    """A family's lean/docs page: the preprint folders it covers and its challenges."""
    folders = sorted(set(re.findall(FOLDER_LINK, text)))
    challenges = sorted(set(re.findall(r"ComparatorChallenges/([A-Za-z0-9_]+)\.lean", text)))
    return {"folders": folders, "challenges": challenges}


def main():
    global cache_dir
    ap = argparse.ArgumentParser()
    ap.add_argument("families", nargs="*")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--folder", action="append", default=[])
    ap.add_argument("--cache")
    ap.add_argument("--comparator")
    args = ap.parse_args()
    if args.cache:
        cache_dir = args.cache
        os.makedirs(cache_dir, exist_ok=True)
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")  # the same bytes on every OS
    results = json.load(open(args.comparator, encoding="utf-8")) if args.comparator else {}

    contents = contents_map(fetch("CONTENTS.md"))
    review = re.search(r"^review:\s*\n\s*status:\s*(\S+)", fetch("lean/formalization.yaml"), re.M)
    readmes = {}

    def readme(f):
        if f not in readmes:
            text = fetch(f"preprints/{f}/README.md")
            readmes[f] = readme_facts(text) if text is not None else {
                "title": None, "withdrawnOn": None, "noticeLinks": []}
        return readmes[f]

    earlier = []
    if args.all:
        by_title = {}
        for f in contents:
            by_title.setdefault(DATED.sub("", f), []).append(f)
        folders = set(contents)
        unlisted = sorted(set(listing("preprints")) - set(contents))
        prefetch(f"preprints/{f}/README.md" for f in unlisted)
        for f in unlisted:
            if readme(f)["withdrawnOn"]:
                folders.add(f)
            else:
                earlier.append({"folder": f, "title": readme(f)["title"],
                                "listedAs": sorted(by_title.get(DATED.sub("", f), []))})
        folders = sorted(folders)
    else:
        folders = sorted({f for f, v in contents.items() if v["family"] in args.families} |
                         set(args.folder))

    prefetch(f"preprints/{f}/README.md" for f in folders)
    # An earlier version stands for its listed version, when it has exactly one.
    later = {e["folder"]: e["listedAs"][0] for e in earlier if len(e["listedAs"]) == 1}
    pages = set(listing("lean/docs"))
    fams = {contents.get(f, {}).get("family") for f in folders} - {None}
    prefetch(f"lean/docs/{fam}.md" for fam in sorted(fams) if f"{fam}.md" in pages)
    docs = {fam: docs_facts(fetch(f"lean/docs/{fam}.md"))
            for fam in sorted(fams) if f"{fam}.md" in pages}

    prefetch(f"lean/ComparatorChallenges/{c}.json" for d in docs.values() for c in d["challenges"])
    challenges = {}
    for fam, d in docs.items():
        for c in d["challenges"]:
            cfg = json.loads(fetch(f"lean/ComparatorChallenges/{c}.json"))
            challenges[c] = {
                "family": fam,
                "solutionModule": cfg["solution_module"],
                "theorems": cfg["theorem_names"],
                "permittedAxioms": cfg["permitted_axioms"],
                "comparator": results.get(c, "notRun"),
            }

    manuscripts = []
    for f in folders:
        facts = readme(f)
        fam = contents.get(f, {}).get("family")
        linked = docs.get(fam, {}).get("folders", [])
        via = [x for x in linked if later.get(x) == f]
        mine = sorted(c for c, v in challenges.items()
                      if v["family"] == fam and (f in linked or via))
        record = {}
        if via and f not in linked:
            record["docsLinks"] = via[0]
        manuscripts.append({
            **record,
            "folder": f,
            "family": fam,
            "title": facts["title"] or contents.get(f, {}).get("title"),
            "withdrawnOn": facts["withdrawnOn"],
            "challenges": mine,
            "noticeLinks": facts["noticeLinks"],
        })

    out = {
        "source": {"repository": REPOSITORY, "commit": COMMIT, "license": LICENSE,
                   "formalizationReview": review.group(1) if review else None,
                   "read": sorted(set(read_paths))},
        "manuscripts": manuscripts,
        "challenges": [dict(name=c, **v) for c, v in sorted(challenges.items())],
        "notCollected": {
            "statementFidelity": "no named reviewer has confirmed any challenge's statement",
            "independentReview": "outside the repository",
            "novelty": "outside the repository",
            "dependencies": "bibliographies are in the PDFs, which aren't read; only "
                            "withdrawal notices' links are",
        },
    }
    if args.all:
        listed = {c for d in docs.values() for c in d["challenges"]}
        configs = {n[:-5] for n in listing("lean/ComparatorChallenges") if n.endswith(".json")}
        linked = {f for d in docs.values() for f in d["folders"]} - set(later)
        out["earlierVersions"] = earlier
        out["unlinked"] = {
            "challenges": sorted(configs - listed),
            "docsFolders": sorted(linked - set(folders)),
        }
    json.dump(out, sys.stdout, indent=1, ensure_ascii=False, sort_keys=True)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
