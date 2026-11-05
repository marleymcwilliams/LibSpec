"""Collects Phase 7's trusted Comparator results (guide/EXECUTABLE_GATE.md §4) from the logs of the
trusted shard jobs.

usage: python3 pilot/shard_results.py [--logs DIR] RUN_ID... > pilot/data/comparator-results.json

A result counts only if it is an unmarked "result:" line of the step "Comparator on the shard",
in the log of a job named "Shard … (trusted)". Only that job writes its log, and
scripts/pilot-shard.sh prints everything of the release's marked or with repr, so no line the
release controls can pass for one. The results artifacts aren't read: the untrusted job of the
same run could have uploaded one under a trusted job's name.

The log is the job's raw log, as GitHub's API serves it, and the step is found by its own header
in it. gh's split of a log into steps can't be relied on: it named every step of one job
"UNKNOWN STEP" (run 41146560423, f189). Lines are split at newlines alone, as the runner splits
them, since str.splitlines() also splits at characters such as U+2028 that the release could
print in a marked line, and so could start a line of its own.

Runs are read in the order given, and each run's attempts oldest first. Every attempt stays
listed: each challenge has its "attempts", each with its run, its attempt, its job and
"libspecCommit", the commit the run used, which says which build of the tools gave that result.
The attempt that counts is the latest, as long as those before it are unknown (cutOff,
notStarted, outOfMemory, buildError, kernelsDisagree or tooLarge). An acceptance or a rejection
is never replaced. A challenge with both among its attempts is listed under "conflicts", and
what counts is whichever came first.

A rerun copies the jobs it doesn't rerun into its new attempt, under new ids, with the same times
and the same log. So a job is one name and start time, kept once, under its latest id, with the
attempt that really ran it.

A trusted job gives no results, and is listed in its run's entry, if it hasn't finished
("notFinished") or if GitHub has no log for it ("noLog"), as when its runner was lost.

GitHub keeps a public repository's logs for 90 days at most, and these logs are the evidence.
With --logs, each trusted job's raw log is saved in DIR, byte for byte, and its SHA-256 recorded
in the output, so that the logs can be kept as assets of the v1.1 release and checked against
this file.

It needs the GitHub CLI, `gh`, signed in.
"""
import hashlib
import json
import os
import re
import subprocess
import sys
import time

REPO = "marleymcwilliams/LibSpec"
COMMIT = "7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a"
JOB = re.compile(r"^Shard ([A-Za-z0-9_-]+) \(trusted\)$")
# The header GitHub writes at the start of the step "Comparator on the shard": "##[group]Run" and
# the step's first line in .github/workflows/pilot-shards.yml. The step ends where the next
# step's header, or the job's cleanup, begins.
STEP_HEADER = '##[group]Run export PILOT_FROZEN="$RUNNER_TEMP/frozen.txt"'
STEP_END = ("##[group]Run ", "Post job cleanup.")
RESULT = re.compile(r"^result: ([A-Za-z0-9_]+): (accepted|rejected|kernelsDisagree|outOfMemory|"
                    r"buildError|tooLarge|cutOff|notStarted)(?: in (\d+) s \(cap (\d+) s\))?")
UNIT = re.compile(r"^unit: ([A-Za-z0-9_]+): (result=\S+ code=\S+ status=\S+ peak_mb=\S+ "
                  r"oom_kills=\S+|not recorded)$")
SAMPLE = re.compile(r"^sample: ([A-Za-z0-9_]+): (threads=\S+ lean_max=\d+ lean_anon_mb=\d+ "
                    r"lean_rss_mb=\d+ nanoda_anon_mb=\d+ unit_anon_mb=\d+ samples=\d+|not recorded)$")
TIMESTAMP = re.compile(r"^\d{4}-\d\d-\d\dT[0-9:.]+Z ")
UNKNOWN = {"cutOff", "notStarted", "outOfMemory", "buildError", "kernelsDisagree", "tooLarge"}
EVIDENCE = {"accepted", "rejected"}


def gh(*args):
    return subprocess.run(["gh"] + list(args), capture_output=True, check=True).stdout


def api(path):
    return json.loads(gh("api", f"repos/{REPO}/actions/{path}").decode("utf-8"))


def attempt_jobs(run, attempt):
    """Every job of one attempt of a run."""
    jobs, page = [], 1
    while True:
        got = api(f"runs/{run}/attempts/{attempt}/jobs?per_page=100&page={page}")["jobs"]
        jobs += got
        if len(got) < 100:
            return jobs
        page += 1


def run_jobs(run):
    """A run's commit, how many attempts it has, and each job it really ran, oldest attempt first."""
    info = api(f"runs/{run}")
    seen = {}
    for attempt in range(info["run_attempt"], 0, -1):
        for job in attempt_jobs(run, attempt):
            seen.setdefault((job["name"], job["started_at"]), job)["attempt"] = attempt
    return info["head_sha"], info["run_attempt"], sorted(seen.values(), key=lambda j: j["attempt"])


def counted(attempts):
    """The attempt that counts, of a challenge's attempts in order: the latest, unless an earlier
    one was accepted or rejected, which is never replaced."""
    best = None
    for a in attempts:
        if best is None or best["status"] in UNKNOWN:
            best = a
    return best


def job_log(job_id):
    """A job's raw log. A download that fails on the way, as one did on a TLS handshake timeout,
    is tried twice more; GitHub's 404 for a job with no log isn't. The raw log keeps the terminal
    escapes of the echoed scripts, which gh refuses to pass on without --allow-escape-sequences.
    They're data here, never printed."""
    for attempt in range(3):
        try:
            return gh("api", "--allow-escape-sequences", f"repos/{REPO}/actions/jobs/{job_id}/logs")
        except subprocess.CalledProcessError as e:
            if b"HTTP 404" in e.stderr or attempt == 2:
                raise
            time.sleep(15)


def step_lines(log, where):
    """The lines of the step "Comparator on the shard" in a raw job log, without timestamps: none
    if the job stopped before the step, and an error if its header appears more than once."""
    # Every line the runner writes starts with its timestamp, so a line without one isn't a line.
    lines = [TIMESTAMP.sub("", line.rstrip("\r"), count=1)
             for line in log.lstrip("\ufeff").split("\n") if TIMESTAMP.match(line)]
    starts = [i for i, line in enumerate(lines) if line == STEP_HEADER]
    if len(starts) > 1:
        sys.exit(f"{where}: the step's header appears {len(starts)} times")
    out = []
    for line in lines[starts[0] + 1:] if starts else []:
        if line.startswith(STEP_END):
            break
        out.append(line)
    return out


def main():
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    args, logs = sys.argv[1:], None
    if args[:1] == ["--logs"]:
        logs, args = args[1], args[2:]
        os.makedirs(logs, exist_ok=True)
    attempts, runs = {}, []
    for run in args:
        if not run.isdigit():
            sys.exit(f"not a run id: {run!r}")
        commit, tries, jobs = run_jobs(run)
        entry_run = {"run": int(run), "url": f"https://github.com/{REPO}/actions/runs/{run}",
                     "libspecCommit": commit, "attempts": tries,
                     "logs": [], "noLog": [], "notFinished": []}
        for job in jobs:
            m = JOB.match(job["name"])
            if not m:
                continue
            if job["conclusion"] not in ("success", "failure"):
                # Still running, cancelled or skipped: no results from it, and listed.
                entry_run["notFinished"].append({"job": job["id"], "attempt": job["attempt"],
                                                 "shard": m.group(1),
                                                 "conclusion": job["conclusion"]})
                continue
            try:
                data = job_log(job["id"])
            except subprocess.CalledProcessError as e:
                # A job whose runner was lost can leave no log, and GitHub answers 404. It gives
                # no results, and is listed, so that its shard can be rerun.
                why = e.stderr.decode("utf-8", errors="replace").strip().splitlines()[:1]
                entry_run["noLog"].append({"job": job["id"], "attempt": job["attempt"],
                                           "shard": m.group(1), "conclusion": job["conclusion"],
                                           "why": why[0] if why else f"gh exited {e.returncode}"})
                print(f"no log: run {run}, job {job['id']} ({m.group(1)})", file=sys.stderr)
                continue
            if logs:
                file = f"run-{run}-job-{job['id']}-{m.group(1)}.log"
                open(os.path.join(logs, file), "wb").write(data)
                entry_run["logs"].append({"job": job["id"], "attempt": job["attempt"],
                                          "shard": m.group(1), "file": file,
                                          "sha256": hashlib.sha256(data).hexdigest()})
            log = data.decode("utf-8", errors="replace")
            units, samples = {}, {}
            for text in step_lines(log, f"run {run}, job {job['id']}"):
                u = UNIT.match(text)
                if u:
                    units[u.group(1)] = u.group(2)
                sampled = SAMPLE.match(text)
                if sampled:
                    samples[sampled.group(1)] = sampled.group(2)
                r = RESULT.match(text)
                if not r:
                    continue
                name, status = r.group(1), r.group(2)
                entry = {"shard": m.group(1), "status": status,
                         "seconds": int(r.group(3) or 0), "capSeconds": int(r.group(4) or 0),
                         "run": int(run), "attempt": job["attempt"], "libspecCommit": commit,
                         "job": job["html_url"]}
                if name in units:
                    entry["unit"] = units[name]
                if name in samples:
                    entry["sample"] = samples[name]
                attempts.setdefault(name, []).append(entry)
        runs.append(entry_run)
    found = {n: counted(a) for n, a in attempts.items()}
    # An acceptance and a rejection of one challenge would be a real contradiction: never settled
    # here, always shown.
    conflicts = sorted(n for n, a in attempts.items()
                       if len({e["status"] for e in a} & EVIDENCE) > 1)
    for n in conflicts:
        print(f"CONFLICT: {n} has both an acceptance and a rejection", file=sys.stderr)
    out = {
        "commit": COMMIT,
        "trusted": True,
        "why": "each result is an unmarked line of a trusted shard job's own log (EXECUTABLE_GATE §4)",
        "runs": runs,
        "results": {n: e["status"] for n, e in sorted(found.items())},
        # Each a case for Marley: nanoda failed while Lean's kernel accepted.
        "kernelsDisagree": sorted(n for n, e in found.items() if e["status"] == "kernelsDisagree"),
        "conflicts": conflicts,
        "challenges": [{"name": n, **found[n], "attempts": attempts[n]} for n in sorted(found)],
    }
    json.dump(out, sys.stdout, indent=1, ensure_ascii=False)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
