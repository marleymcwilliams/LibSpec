"""Tests of pilot/shard_results.py's rules, which scripts/test-pilot-shard.sh runs: the step found by
its own header in a raw job log, lines split at newlines alone, and which attempt counts. They
need no network. Run them with `python3 -B`, so that importing the collector leaves no bytecode.
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "pilot"))
import shard_results as sr  # noqa: E402

T = "2026-10-31T00:13:39.0064919Z "
H = sr.STEP_HEADER
failed = False


def lines(*xs):
    return "﻿" + "\n".join(T + x for x in xs) + "\n"


def results(log):
    return [sr.RESULT.match(t).group(1) for t in sr.step_lines(log, "test") if sr.RESULT.match(t)]


def check(label, got, want):
    global failed
    if got == want:
        print(f"ok: {label}")
    else:
        print(f"FAIL: {label}: expected {want!r}, got {got!r}")
        failed = True


base = ["##[group]Run lake exe cache get", "result: Early: accepted in 1 s (cap 1 s)", H,
        "shell: /usr/bin/bash -e {0}", "##[endgroup]", "== Challenge A",
        "result: A: accepted in 10 s (cap 18000 s), 1 MB free; x"]
late = "result: Late: accepted in 1 s (cap 1 s)"
check("a result in the step counts", results(lines(*base)), ["A"])
check("one after the next step's header doesn't",
      results(lines(*base, "##[group]Run actions/upload-artifact@v4", late)), ["A"])
check("one after the job's cleanup doesn't", results(lines(*base, "Post job cleanup.", late)), ["A"])
for sep, label in ((" ", "U+2028"), ("\x1c", "x1c"), ("\x85", "x85"), ("\x0b", "x0b"),
                   (" ", "U+2029")):
    forged = "    comparator| x" + sep + "result: Forged: accepted in 1 s (cap 18000 s)"
    check(f"a marked line with {label} can't start a result", results(lines(*base, forged)), ["A"])
check("CRLF line ends are fine", results("﻿" + "\r\n".join(T + x for x in base) + "\r\n"), ["A"])
check("no header gives no results", results(lines(*base[:2])), [])
check("a line without a timestamp doesn't count", results(lines(*base) + late + "\n"), ["A"])
try:
    sr.step_lines(lines(*base, H, late), "test")
    check("two headers stop the collector", "no stop", "stop")
except SystemExit:
    check("two headers stop the collector", "stop", "stop")

for line, want in (("result: X: outOfMemory in 5 s (cap 9 s), 1 MB free; y", "outOfMemory"),
                   ("result: X: notStarted, with 1 s of the job left", "notStarted")):
    check(f"{want} is read", sr.RESULT.match(line).group(2), want)
check("a unit line is read",
      sr.UNIT.match("unit: X: result=oom-kill code=killed status=KILL peak_mb=13312 oom_kills=1").group(2),
      "result=oom-kill code=killed status=KILL peak_mb=13312 oom_kills=1")
check("an unrecorded unit is read", sr.UNIT.match("unit: X: not recorded").group(2), "not recorded")
check("a marked unit line isn't read", sr.UNIT.match("    comparator| unit: X: not recorded"), None)
SAMPLED = "threads=2 lean_max=2 lean_anon_mb=6000 lean_rss_mb=9000 nanoda_anon_mb=0 unit_anon_mb=7000 samples=9"
check("a sample line is read", sr.SAMPLE.match(f"sample: X: {SAMPLED}").group(2), SAMPLED)
check("an unrecorded sample is read", sr.SAMPLE.match("sample: X: not recorded").group(2), "not recorded")
check("a marked sample line isn't read", sr.SAMPLE.match(f"    comparator| sample: X: {SAMPLED}"), None)


def status(*xs):
    return sr.counted([{"status": s, "i": i} for i, s in enumerate(xs)])


for unknown in sorted(sr.UNKNOWN):
    for later in ("accepted", "rejected", "buildError"):
        check(f"a later {later} replaces an earlier {unknown}", status(unknown, later)["i"], 1)
for standing in sorted(sr.EVIDENCE):
    for later in sorted(sr.UNKNOWN | sr.EVIDENCE):
        check(f"a later {later} never replaces an earlier {standing}", status(standing, later)["i"], 0)
check("the latest of several unknowns counts", status("cutOff", "buildError", "tooLarge")["i"], 2)
check("the first evidence stands, after unknowns",
      status("buildError", "accepted", "tooLarge", "rejected")["i"], 1)
check("the statuses the collector reads are all unknown or evidence",
      set(sr.RESULT.pattern.split("(")[2].split(")")[0].split("|")) - (sr.UNKNOWN | sr.EVIDENCE), set())

print("test_shard_results.py: " + ("FAILED" if failed else "passed"))
sys.exit(1 if failed else 0)
