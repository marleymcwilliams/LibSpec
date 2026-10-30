"""Collects Phase 7's trusted Comparator results (guide/EXECUTABLE_GATE.md §4) from the logs of the
trusted shard jobs.

usage: python3 pilot/shard_results.py [--logs DIR] RUN_ID... > pilot/data/comparator-results.json

A result counts only if it is an unmarked "result:" line of the step "Comparator on the shard",
in the log of a job named "Shard … (trusted)". Only that job writes its log, and
scripts/pilot-shard.sh prints everything of the release's marked or with repr, so no line the
release controls can pass for one. The results artifacts aren't read: the untrusted job of the
same run could have uploaded one under a trusted job's name.

Runs are read in the order given. A later result for a challenge replaces an earlier one only
when the earlier one is cutOff or notStarted, which is what a rerun in a job of its own is for.

GitHub keeps a public repository's logs for 90 days at most, and these logs are the evidence.
With --logs, each trusted job's log is saved in DIR, and its SHA-256 recorded in the output, so
that the logs can be kept as assets of the v1.1 release and checked against this file.

It needs the GitHub CLI, `gh`, signed in.
"""
import hashlib
import json
import os
import re
import subprocess
import sys

REPO = "marleymcwilliams/LibSpec"
COMMIT = "7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a"
JOB = re.compile(r"^Shard ([A-Za-z0-9_-]+) \(trusted\)$")
STEP = "Comparator on the shard"
RESULT = re.compile(r"^result: ([A-Za-z0-9_]+): (accepted|rejected|kernelsDisagree|buildError|"
                    r"tooLarge|cutOff|notStarted)(?: in (\d+) s \(cap (\d+) s\))?")
TIMESTAMP = re.compile(r"^\d{4}-\d\d-\d\dT[0-9:.]+Z ")
RERUN = {"cutOff", "notStarted"}


def gh(*args):
    out = subprocess.run(["gh"] + list(args), capture_output=True, check=True).stdout
    return out.decode("utf-8", errors="replace")


def main():
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    args, logs = sys.argv[1:], None
    if args[:1] == ["--logs"]:
        logs, args = args[1], args[2:]
        os.makedirs(logs, exist_ok=True)
    found, runs = {}, []
    for run in args:
        if not run.isdigit():
            sys.exit(f"not a run id: {run!r}")
        jobs = json.loads(gh("api", f"repos/{REPO}/actions/runs/{run}/jobs?per_page=100"))["jobs"]
        entry_run = {"run": int(run), "url": f"https://github.com/{REPO}/actions/runs/{run}",
                     "logs": []}
        for job in jobs:
            m = JOB.match(job["name"])
            if not m or job["conclusion"] not in ("success", "failure"):
                continue
            log = gh("run", "view", run, "--repo", REPO, "--job", str(job["id"]), "--log")
            if logs:
                name = f"run-{run}-job-{job['id']}-{m.group(1)}.log"
                data = log.encode("utf-8")
                open(os.path.join(logs, name), "wb").write(data)
                entry_run["logs"].append({"job": job["id"], "shard": m.group(1), "file": name,
                                          "sha256": hashlib.sha256(data).hexdigest()})
            for line in log.splitlines():
                # gh prints each line as: job name, a tab, step name, a tab, then the timestamp.
                parts = line.split("\t", 2)
                if len(parts) != 3 or parts[1] != STEP:
                    continue
                text = TIMESTAMP.sub("", parts[2], count=1)
                r = RESULT.match(text)
                if not r:
                    continue
                name, status = r.group(1), r.group(2)
                entry = {"name": name, "shard": m.group(1), "status": status,
                         "seconds": int(r.group(3) or 0), "capSeconds": int(r.group(4) or 0),
                         "run": int(run), "job": job["html_url"]}
                old = found.get(name)
                if old is None or old["status"] in RERUN:
                    found[name] = entry
        runs.append(entry_run)
    out = {
        "commit": COMMIT,
        "trusted": True,
        "why": "each result is an unmarked line of a trusted shard job's own log (EXECUTABLE_GATE §4)",
        "runs": runs,
        "results": {n: e["status"] for n, e in sorted(found.items())},
        # Each a case for Marley: nanoda failed while Lean's kernel accepted.
        "kernelsDisagree": sorted(n for n, e in found.items() if e["status"] == "kernelsDisagree"),
        "challenges": [found[n] for n in sorted(found)],
    }
    json.dump(out, sys.stdout, indent=1, ensure_ascii=False)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
