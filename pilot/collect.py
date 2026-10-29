"""The pilot's collector (guide/EXECUTABLE_GATE.md section 3): raw records and dependency
edges for manuscripts of the openai/math release, pinned to one commit and read as data.

usage: python3 pilot/collect.py [--comparator RESULTS] FAMILY... [--folder FOLDER]... > DATA

It fetches only text files at the pinned commit, parses them with regular expressions, and
writes facts: titles, notice dates, families, dependency links, challenge names and the
axioms each challenge permits. It never runs, imports or builds anything from the release,
and it stores none of its paper text or Lean code. The release is Apache-2.0 (its root
LICENSE and lean/LICENSE at this commit), and the output names the source, the commit and
the license.

Each record holds only facts. The pilot's Lean module turns them into grades
(lean/JSG/Pilot/Core.lean), so nothing the verdict depends on is computed here.

- FAMILY: a three-digit family number from CONTENTS.md; all its manuscripts are collected.
- --folder: a preprints/ folder to collect as well, such as a withdrawn manuscript, which
  CONTENTS.md no longer lists.
- --comparator: a JSON file of our Comparator results, {"challenge": "accepted" | "rejected"}.
  A challenge without a result is "notRun".
"""
import argparse
import json
import re
import sys
import urllib.error
import urllib.request

REPOSITORY = "https://github.com/openai/math"
COMMIT = "7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a"
LICENSE = "Apache-2.0"
THREE_AXIOMS = {"propext", "Quot.sound", "Classical.choice"}

read_paths = []


def fetch(path):
    """A text file at the pinned commit, or None if it doesn't exist."""
    url = f"https://raw.githubusercontent.com/openai/math/{COMMIT}/{path}"
    try:
        with urllib.request.urlopen(url, timeout=60) as r:
            text = r.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise
    read_paths.append(path)
    return text


def contents_map(text):
    """CONTENTS.md: each manuscript's folder, with its family and its title there."""
    family, out = None, {}
    for line in text.split("\n"):
        h = re.match(r"\*\*(\d{3})\. ", line.strip())
        if h:
            family = h.group(1)
            continue
        for title, folder in re.findall(r"\[([^\]]+)\]\(preprints/([^/)]+)/", line):
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
        links = sorted(set(re.findall(r"preprints/([^/)\s]+)/", notice)))
    return {"title": title, "withdrawnOn": date, "noticeLinks": links}


def docs_facts(text):
    """A family's lean/docs page: the preprint folders it covers and its challenges."""
    folders = sorted(set(re.findall(r"preprints/([^/)\s]+)/", text)))
    challenges = sorted(set(re.findall(r"ComparatorChallenges/([A-Za-z0-9_]+)\.lean", text)))
    return {"folders": folders, "challenges": challenges}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("families", nargs="*")
    ap.add_argument("--folder", action="append", default=[])
    ap.add_argument("--comparator")
    args = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")  # the same bytes on every OS
    results = json.load(open(args.comparator, encoding="utf-8")) if args.comparator else {}

    contents = contents_map(fetch("CONTENTS.md"))
    review = re.search(r"^review:\s*\n\s*status:\s*(\S+)", fetch("lean/formalization.yaml"), re.M)
    folders = sorted({f for f, v in contents.items() if v["family"] in args.families} |
                     set(args.folder))

    docs = {}
    for fam in sorted({contents.get(f, {}).get("family") for f in folders} - {None}):
        page = fetch(f"lean/docs/{fam}.md")
        if page is not None:
            docs[fam] = docs_facts(page)

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
        readme = fetch(f"preprints/{f}/README.md")
        facts = readme_facts(readme) if readme is not None else {
            "title": None, "withdrawnOn": None, "noticeLinks": []}
        fam = contents.get(f, {}).get("family")
        mine = sorted(c for c, v in challenges.items()
                      if v["family"] == fam and f in docs.get(fam, {}).get("folders", []))
        manuscripts.append({
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
    json.dump(out, sys.stdout, indent=1, ensure_ascii=False, sort_keys=True)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
