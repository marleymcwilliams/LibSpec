"""Helpers for scripts/pilot-shard.sh, the trusted job's Comparator runs (guide/EXECUTABLE_GATE.md
§4). The release's files are read as data, and anything of the release's that this prints is
printed with repr, so it can't pass for a result line or a GitHub workflow command.

usage: python3 scripts/pilot_shard.py challenges PLAN SHARD
       python3 scripts/pilot_shard.py config RELEASE_LEAN_DIR CHALLENGE OUT.json
       python3 scripts/pilot_shard.py leanpath RELEASE_LEAN_DIR
       python3 scripts/pilot_shard.py classify LOG EXIT_FILE ELAPSED CAP FULL_CAP FIRST
       python3 scripts/pilot_shard.py results RESULTS.tsv SHARD OUT.json

A shard is a name from pilot/data/shard-plan.json, or solo-<Challenge> for one challenge rerun in
a job of its own. A result is one of:
- accepted: Comparator exited 0, after its success line;
- rejected: Comparator exited 1 on one of its own rejections, a mismatched statement or
  constant, a disallowed axiom, or the refusal of Lean's kernel;
- buildError: anything else that stopped it, such as a failed build or export, a crash, a
  kill by a signal or by the memory limit, or nanoda failing while Lean's kernel accepted;
- tooLarge: it timed out as the first challenge in its job, or with the full 5-hour cap
  ("too large to check yet");
- cutOff: it timed out with less than the full cap, after other challenges in its job, so it
  gets one rerun in a job of its own;
- notStarted: its job ran out of time before it began, so it gets a rerun too.
Only a rejection is evidence that fails. Build errors and timeouts stay unknown.

nanoda reports a refusal by panicking, as it does an internal error, so its exit code can't
tell the two apart. A failure of nanoda alone is therefore a build error, with its exit code
in the detail, and a refusal counts only when Lean's kernel refuses too.
"""
import json
import os
import re
import sys

NAME = re.compile(r"^[A-Za-z0-9_]+$")
SHARD = re.compile(r"^[A-Za-z0-9_-]+$")
KEEP = ("challenge_module", "solution_module", "theorem_names", "definition_names",
        "permitted_axioms")
# Comparator's own rejections: Comparator/Compare.lean and Comparator/Axioms.lean at v4.34.0.
REJECTIONS = (
    "Const not found in challenge", "Const not found in solution",
    "Constant not found in solution", "Const does not match between challenge and target",
    "Challenge and solution constant kind don't match",
    "Challenge and solution theorem statement do not match",
    "Challenge constant is not a definition", "Solution constant is not a definition",
    "Solution constant is not a theorem", "Illegal axiom detected",
)
LEAN_KERNEL = "Running Lean default kernel on solution."
LEAN_REFUSALS = ("Lean default kernel rejects the solution",
                 "Quotient post-check rejects the solution")


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
            sys.exit(f"FAIL: {name}: {k} isn't a module name")
    # Full strength, whatever the release's config says. Anything not in KEEP, such as an
    # external kernel's command, is dropped.
    cfg["enable_nanoda"] = True
    json.dump(cfg, open(out, "w", encoding="utf-8"), indent=2)
    print("theorems:", repr(cfg.get("theorem_names", [])), file=sys.stderr)
    print("permitted axioms:", repr(cfg.get("permitted_axioms", [])), file=sys.stderr)
    print(cfg["solution_module"])  # checked against the pattern above


def leanpath(lean_dir):
    """What `lake env` would put on LEAN_PATH, found from the directories instead, so that the
    release's lakefile isn't run outside the sandbox."""
    dirs = [os.path.join(lean_dir, ".lake", "build", "lib", "lean")]
    pkgs = os.path.join(lean_dir, ".lake", "packages")
    for p in sorted(os.listdir(pkgs)):
        dirs.append(os.path.join(pkgs, p, ".lake", "build", "lib", "lean"))
    print(":".join(dirs))


def classify(log, exit_file, elapsed, cap, full_cap, first):
    """(status, detail). The detail is LibSpec's own words, never the release's."""
    elapsed, cap, full_cap, first = int(elapsed), int(cap), int(full_cap), first == "1"
    text = open(log, encoding="utf-8", errors="replace").read()
    code = None
    if os.path.exists(exit_file):
        raw = open(exit_file).read().strip()
        code = int(raw) if re.fullmatch(r"-?\d+", raw) else None
    if code == 0 and "Your solution is okay!" in text:
        return "accepted", "Comparator's success line, and exit 0"
    if code is None:
        # The wrapper's unit stopped before the shell around Comparator could record its exit.
        if elapsed >= cap - 15:
            if first or cap >= full_cap:
                return "tooLarge", f"timed out at {cap} s" + (", first in its job" if first else "")
            return "cutOff", f"timed out at {cap} s, less than the full {full_cap} s"
        return "buildError", "the wrapper's unit stopped early, as the memory limit stops it"
    if code != 1:
        return "buildError", f"Comparator exited with {code}, a crash or a signal"
    i = text.rfind("uncaught exception: ")
    message = text[i + len("uncaught exception: "):].strip() if i >= 0 else ""
    if message.startswith(REJECTIONS):
        return "rejected", "one of Comparator's own rejections: a mismatch or an axiom"
    j = text.rfind(LEAN_KERNEL)
    if j >= 0 and any(r in text[j:] for r in LEAN_REFUSALS):
        return "rejected", "Lean's kernel refused the solution"
    m = re.match(r"nanoda exited with (-?\d+)\s*$", message)
    if m:
        return "buildError", f"nanoda exited with {m.group(1)} while Lean's kernel accepted"
    if message.startswith("Child exited with"):
        return "buildError", "a sandboxed build or export failed"
    return "buildError", "Comparator stopped before comparing"


def results(tsv, shard, out):
    rows = [l.rstrip("\n").split("\t") for l in open(tsv, encoding="utf-8") if l.strip()]
    doc = {
        "shard": shard,
        "commit": "7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a",
        "run": os.environ.get("GITHUB_RUN_ID"),
        "runAttempt": os.environ.get("GITHUB_RUN_ATTEMPT"),
        "challenges": [{"name": n, "status": s, "seconds": int(t), "capSeconds": int(c),
                        "freeMBAfter": int(f), "detail": d} for n, s, t, c, f, d in rows],
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
        print("\t".join(classify(*args)))
    elif cmd == "results":
        results(*args)
    else:
        sys.exit(f"usage: {sys.argv[0]} challenges|config|leanpath|classify|results ...")


if __name__ == "__main__":
    main()
