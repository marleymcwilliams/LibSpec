"""The shard plan for Phase 7's trusted Comparator runs (guide/ROADMAP.md, Phase 7).

usage: python3 pilot/plan_shards.py pilot/data/shards.json > pilot/data/shard-plan.json

It reads the import graph's estimates and packs families into shards, each run by one
trusted job, in the order Marley set:
1. "measure": families 189 and 159, each in a job of its own, to time them first;
2. "eth-and-local-smoothing": families 378 and 079, each in a job of its own;
3. "rest": everything else.

In "rest", a family whose upper estimate is over BIN_HOURS gets a job of its own. A family with
several challenges whose upper estimate is over CAP_HOURS is split, one job per challenge,
though their shared modules then build in each. Smaller families share jobs, packed
largest first, up to BIN_HOURS of estimated building each. Every estimate is the larger end
of the import graph's two ranges, by source size and by module count.

The "control" shard is one small challenge, BogomolovPopInjectivity (family 009). The
workflow runs it on its own pull requests, and the negative controls run it too.
"""
import json
import sys

BIN_HOURS = 3.5   # estimated building per shared job, in a 6-hour job with kernels on top
CAP_HOURS = 5.0   # the cap on one challenge
MEASURE = ["189", "159"]
ETH_AND_LOCAL_SMOOTHING = ["378", "079"]
CONTROL = ("009", "BogomolovPopInjectivity")


def upper(h):
    return max(h["byBytes"][1], h["byModules"][1])


def main():
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    d = json.load(open(sys.argv[1], encoding="utf-8"))
    per_mb = max(c["secondsPerMB"] for c in d["calibration"].values())
    per_mod = max(c["secondsPerModule"] for c in d["calibration"].values())
    fams = {f["family"]: f for f in d["families"]}
    chal = {c["name"]: c for c in d["challenges"]}

    def challenge_hours(name):
        c = chal[name]
        return max(c["bytes"] / 1e6 * per_mb, c["modules"] * per_mod) / 3600

    shards = {}

    def add(sid, families, challenges, hours):
        assert sid not in shards, sid
        shards[sid] = {"families": families, "challenges": sorted(challenges),
                       "estimateHours": round(hours, 2)}

    add("control", [CONTROL[0]], [CONTROL[1]], challenge_hours(CONTROL[1]))
    phases = []
    for name, ids in (("measure", MEASURE), ("eth-and-local-smoothing", ETH_AND_LOCAL_SMOOTHING)):
        phases.append({"name": name, "shards": []})
        for fam in ids:
            f = fams[fam]
            add(f"f{fam}", [fam], f["challenges"], upper(f["buildHours"]))
            phases[-1]["shards"].append(f"f{fam}")

    # The units to place: whole families, or the challenges of a large family split apart.
    units = []
    for k, f in fams.items():
        if k in MEASURE + ETH_AND_LOCAL_SMOOTHING:
            continue
        h = upper(f["buildHours"])
        if h > CAP_HOURS and len(f["challenges"]) > 1:
            units += [(f"c-{c}", [k], [c], challenge_hours(c)) for c in f["challenges"]]
        else:
            units.append((f"f{k}", [k], f["challenges"], h))
    own, bins = [], []
    for sid, families, challenges, h in sorted(units, key=lambda u: -u[3]):
        if h > BIN_HOURS:
            own.append((sid, families, challenges, h))
            continue
        for b in bins:  # first fit, largest first
            if b["hours"] + h <= BIN_HOURS:
                b["families"] = sorted(set(b["families"]) | set(families))
                b["challenges"] += challenges
                b["hours"] += h
                break
        else:
            bins.append({"families": list(families), "challenges": list(challenges), "hours": h})
    phases.append({"name": "rest", "shards": []})
    for sid, families, challenges, h in own:
        add(sid, families, challenges, h)
        phases[-1]["shards"].append(sid)
    for i, b in enumerate(bins, 1):
        sid = f"b{i:02d}"
        add(sid, b["families"], b["challenges"], b["hours"])
        phases[-1]["shards"].append(sid)

    planned = sorted(c for k, s in shards.items() if k != "control" for c in s["challenges"])
    assert planned == sorted(chal), "every challenge in exactly one shard, outside the control"
    out = {
        "source": d["source"],
        "from": "pilot/data/shards.json",
        "binHours": BIN_HOURS,
        "challengeCapHours": CAP_HOURS,
        "phases": phases,
        "shards": shards,
    }
    json.dump(out, sys.stdout, indent=1, ensure_ascii=False)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
