"""The release's import graph, for planning Comparator's shards (guide/EXECUTABLE_GATE.md §4).

usage: python3 pilot/imports.py LEAN_DIR DATA > pilot/data/shards.json

LEAN_DIR is the release's lean/ directory at the pinned commit, checked out as files only:

    git init -q math && cd math
    git sparse-checkout set --no-cone '/lean/**/*.lean'
    git fetch --depth 1 --filter=blob:none https://github.com/openai/math COMMIT
    git checkout -q FETCH_HEAD

Git checks files out and runs none of the release's code. This script reads each module's
header as text and parses its imports with regular expressions; it never runs, imports or
builds anything from the release. DATA is the collector's output (pilot/data/catalogue.json),
which names each challenge's family and solution module.

For each challenge, it finds the release's own modules that Comparator must build: the
transitive imports of the challenge and of its solution, within the release. Modules of
Mathlib and of the release's other dependencies are outside the checkout, so they're counted
by package, not module. Each family's shard builds the union of its challenges' closures.
"""
import json
import os
import re
import sys

COMMIT = "7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a"
# #83's run 40916190535: the release's own modules each challenge built, and the minutes its
# build took. Catalan was first, so it built everything it needed; JointDickman reused what
# Catalan had built.
MEASURED = {
    "Catalan": {"built": 988, "minutes": 43},
    "JointDickman": {"built": 1792, "minutes": 43},
}

IMPORT = re.compile(r"^(?:(?:public|private)\s+)?(?:meta\s+)?import\s+(?:all\s+)?(.+)$")


def header_imports(text):
    """The modules a file's header imports. The header ends at the first line that is
    neither an import, `module`, `prelude`, a comment nor blank."""
    text = re.sub(r"/-(?![-!]).*?-/", "", text, flags=re.S)  # block comments, not doc ones
    out = []
    for line in text.split("\n"):
        line = line.split("--", 1)[0].strip()
        if not line or line in ("module", "prelude"):
            continue
        m = IMPORT.match(line)
        if not m:
            break
        out.extend(m.group(1).split())
    return out


def main():
    lean_dir, data = os.path.abspath(sys.argv[1]), sys.argv[2]
    if os.name == "nt":
        lean_dir = "\\\\?\\" + lean_dir  # some of the release's paths pass Windows' limit
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    d = json.load(open(data, encoding="utf-8"))
    imports, size = {}, {}
    for root, _, files in os.walk(lean_dir):
        for f in files:
            if not f.endswith(".lean"):
                continue
            path = os.path.join(root, f)
            rel = os.path.relpath(path, lean_dir)[:-5].replace(os.sep, ".")
            if rel.startswith(".lake") or rel == "lakefile":
                continue
            text = open(path, encoding="utf-8", errors="replace").read()
            imports[rel] = header_imports(text)
            size[rel] = len(text.encode("utf-8"))

    closures = {}

    def closure(mod):
        """The release's own modules that mod needs, mod included, iteratively."""
        if mod in closures:
            return closures[mod]
        seen, todo = set(), [mod]
        while todo:
            x = todo.pop()
            if x in seen or x not in imports:
                continue
            seen.add(x)
            todo.extend(imports[x])
        closures[mod] = seen
        return seen

    def outside(mods):
        """The packages, by root name, that a set of modules imports from outside the release."""
        return sorted({i.split(".")[0] for m in mods for i in imports[m] if i not in imports})

    challenges = []
    for c in d["challenges"]:
        need = closure(f"ComparatorChallenges.{c['name']}") | closure(c["solutionModule"])
        challenges.append({
            "name": c["name"], "family": c["family"],
            "modules": len(need), "bytes": sum(size[m] for m in need),
            "packages": outside(need), "_need": need,
        })

    families = {}
    for c in challenges:
        f = families.setdefault(c["family"], {"challenges": [], "_need": set()})
        f["challenges"].append(c["name"])
        f["_need"] |= c["_need"]

    by_name = {c["name"]: c for c in challenges}
    calibration = {}
    for name, m in MEASURED.items():
        oai = {x for x in by_name[name]["_need"] if x.startswith("OAI.")}
        b = sum(size[x] for x in oai)
        calibration[name] = {
            "measuredBuilt": m["built"], "measuredMinutes": m["minutes"],
            "closureOAIModules": len(oai), "closureOAIBytes": b,
            "secondsPerMB": round(m["minutes"] * 60 / (b / 1e6), 1),
            "secondsPerModule": round(m["minutes"] * 60 / len(oai), 2)}
    # Two measured rates, so each estimate is a range: by source size, and by module count.
    per_mb = sorted(c["secondsPerMB"] for c in calibration.values())
    per_mod = sorted(c["secondsPerModule"] for c in calibration.values())

    def hours(mods, b):
        return {"byBytes": [round(b / 1e6 * r / 3600, 1) for r in per_mb],
                "byModules": [round(mods * r / 3600, 1) for r in per_mod]}

    fam_out = []
    for fam, f in sorted(families.items()):
        need = f["_need"]
        b = sum(size[m] for m in need)
        fam_out.append({"family": fam, "challenges": sorted(f["challenges"]),
                        "modules": len(need), "bytes": b, "buildHours": hours(len(need), b),
                        "packages": outside(need)})
    every = set().union(*(c["_need"] for c in challenges))
    every_b = sum(size[m] for m in every)
    fam_mods = sum(f["modules"] for f in fam_out)
    fam_b = sum(f["bytes"] for f in fam_out)
    out = {
        "source": {"repository": "https://github.com/openai/math", "commit": COMMIT,
                   "read": "the import headers of every .lean file under lean/"},
        "release": {"modules": len(imports), "bytes": sum(size.values())},
        "needed": {"modules": len(every), "bytes": every_b,
                   "buildHours": hours(len(every), every_b)},
        "byFamily": {"families": len(fam_out), "modules": fam_mods, "bytes": fam_b,
                     "buildHours": hours(fam_mods, fam_b),
                     "largestByBytes": [f["family"] for f in
                                        sorted(fam_out, key=lambda f: -f["bytes"])[:5]]},
        "calibration": calibration,
        "families": fam_out,
        "challenges": [{k: v for k, v in c.items() if not k.startswith("_")} for c in challenges],
    }
    json.dump(out, sys.stdout, indent=1, ensure_ascii=False)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
