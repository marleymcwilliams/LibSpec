"""Helpers for scripts/pilot-shard.sh, the trusted job's Comparator runs (guide/EXECUTABLE_GATE.md
§4). The release's files are read as data.

usage: python3 scripts/pilot_shard.py challenges PLAN SHARD
       python3 scripts/pilot_shard.py config RELEASE_LEAN_DIR CHALLENGE OUT.json
       python3 scripts/pilot_shard.py leanpath RELEASE_LEAN_DIR
       python3 scripts/pilot_shard.py classify LOG SOLUTION_MODULE EXIT ELAPSED CAP FULL_CAP
       python3 scripts/pilot_shard.py results RESULTS.tsv SHARD OUT.json

A shard is a name from pilot/data/shard-plan.json, or solo-<Challenge> for one challenge rerun in
a job of its own. A result is one of:
- accepted: Comparator printed its success line and exited 0;
- rejected: both modules built and exported, and the comparison or a kernel refused;
- buildError: a build or an export failed, or Comparator stopped before comparing;
- tooLarge: it hit the 5-hour cap on one challenge ("too large to check yet");
- cutOff: it was stopped earlier, because its job was running out of time, so it gets one
  rerun in a job of its own;
- notStarted: its job ran out of time before it began, so it gets a rerun too.
Only a rejection is evidence that fails. Build errors and timeouts stay unknown.
"""
import json
import os
import re
import sys

NAME = re.compile(r"^[A-Za-z0-9_]+$")
SHARD = re.compile(r"^[A-Za-z0-9_-]+$")
KEEP = ("challenge_module", "solution_module", "theorem_names", "definition_names",
        "permitted_axioms")


def challenges(plan, shard):
    if not SHARD.match(shard):
        sys.exit(f"FAIL: not a shard name: {shard!r}")
    p = json.load(open(plan, encoding="utf-8"))
    if shard.startswith("solo-"):
        name = shard[len("solo-"):]
        if not NAME.match(name) or not any(name in s["challenges"] for s in p["shards"].values()):
            sys.exit(f"FAIL: {name!r} is in no shard of the plan")
        return [name]
    if shard not in p["shards"]:
        sys.exit(f"FAIL: no shard {shard!r} in the plan")
    return p["shards"][shard]["challenges"]


def config(lean_dir, name, out):
    if not NAME.match(name):
        sys.exit(f"FAIL: not a challenge name: {name!r}")
    src = json.load(open(os.path.join(lean_dir, "ComparatorChallenges", name + ".json"),
                         encoding="utf-8"))
    cfg = {k: src[k] for k in KEEP if k in src}
    for k in ("challenge_module", "solution_module"):
        if not isinstance(cfg.get(k), str) or not re.match(r"^[A-Za-z0-9_.]+$", cfg[k]):
            sys.exit(f"FAIL: {name}: {k} isn't a module name: {cfg.get(k)!r}")
    # Full strength, whatever the release's config says. Anything not in KEEP, such as an
    # external kernel's command, is dropped.
    cfg["enable_nanoda"] = True
    json.dump(cfg, open(out, "w", encoding="utf-8"), indent=2)
    print("theorems:", ", ".join(cfg.get("theorem_names", [])), file=sys.stderr)
    print("permitted axioms:", ", ".join(cfg.get("permitted_axioms", [])), file=sys.stderr)
    print(cfg["solution_module"])


def leanpath(lean_dir):
    """What `lake env` would put on LEAN_PATH, found from the directories instead, so that the
    release's lakefile isn't run outside the sandbox."""
    dirs = [os.path.join(lean_dir, ".lake", "build", "lib", "lean")]
    pkgs = os.path.join(lean_dir, ".lake", "packages")
    for p in sorted(os.listdir(pkgs)):
        dirs.append(os.path.join(pkgs, p, ".lake", "build", "lib", "lean"))
    print(":".join(dirs))


def classify(log, solution, code, elapsed, cap, full_cap):
    code, elapsed, cap, full_cap = int(code), int(elapsed), int(cap), int(full_cap)
    text = open(log, encoding="utf-8", errors="replace").read()
    if code == 0 and "Your solution is okay!" in text:
        return "accepted"
    if elapsed >= cap - 15:
        return "tooLarge" if cap >= full_cap else "cutOff"
    exported = re.search(r"^Exporting .* from " + re.escape(solution) + r"\s*$", text, re.M)
    if exported and "Child exited with" not in text.split(exported.group(0), 1)[1]:
        return "rejected"
    return "buildError"


def results(tsv, shard, out):
    rows = [l.rstrip("\n").split("\t") for l in open(tsv, encoding="utf-8") if l.strip()]
    doc = {
        "shard": shard,
        "commit": "7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a",
        "run": os.environ.get("GITHUB_RUN_ID"),
        "runAttempt": os.environ.get("GITHUB_RUN_ATTEMPT"),
        "trusted": True,
        "challenges": [{"name": n, "status": s, "seconds": int(t), "capSeconds": int(c),
                        "freeMBAfter": int(f)} for n, s, t, c, f in rows],
    }
    json.dump(doc, open(out, "w", encoding="utf-8"), indent=2)


def main():
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == "challenges":
        print("\n".join(challenges(*args)))
    elif cmd == "config":
        config(*args)
    elif cmd == "leanpath":
        leanpath(*args)
    elif cmd == "classify":
        print(classify(*args))
    elif cmd == "results":
        results(*args)
    else:
        sys.exit(f"usage: {sys.argv[0]} challenges|config|leanpath|classify|results ...")


if __name__ == "__main__":
    main()
