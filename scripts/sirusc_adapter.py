"""SirusSC's specchain as an implementation under test (guide/EXECUTABLE_GATE.md section 2).

usage: python3 scripts/sirusc_adapter.py CORPUS > ANSWERS

Reads the corpus that `Gate.lean corpus` writes, and answers each vector that SirusSC has
code for, by calling that code: `specchain/algebra/q_prime.py` and `specchain/algebra/q.py`,
loaded in place from archive/. The files are read, never changed, and no bytecode is
written beside them. SirusSC's bottom, an absent reading, stands for the unknown [0, inf].

- combine: `Interval.join` on floor axes and `Interval.plus` on budget axes.
- verdict: `Q.leq` of the upper ends against the thresholds.
- lease verdict: `QPrime.guard_no_bottom`, and then `Q.leq` of the upper ends. It has no
  code that reads a width or a lease.

SirusSC has no code for residuals, threading, widths, or known and unknown values, so those
answers are null, which `Gate.lean diff` skips.
"""
import importlib.util
import json
import pathlib
import sys
from fractions import Fraction

sys.dont_write_bytecode = True  # archive/ is read-only

ROOT = pathlib.Path(__file__).resolve().parent.parent
ALGEBRA = ROOT / "archive" / "SirusSC" / "specchain" / "algebra"


def load(name):
    spec = importlib.util.spec_from_file_location(f"sirusc_{name}", ALGEBRA / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module  # dataclasses look the module up by name
    spec.loader.exec_module(module)
    return module


q_prime = load("q_prime")
q = load("q")
Interval, QPrime = q_prime.Interval, q_prime.QPrime
Q, Axes = q.Q, q.Axes

INF = float("inf")


def val(s):
    """A corpus value: "inf", "p" or "p/q"."""
    if s == "inf":
        return INF
    return float(Fraction(s))


def val_out(x):
    if x == INF:
        return "inf"
    f = Fraction(x).limit_denominator(10 ** 9)
    return str(f.numerator) if f.denominator == 1 else f"{f.numerator}/{f.denominator}"


def interval(b):
    lo, hi = val(b["lo"]), val(b["hi"])
    if lo == 0 and hi == INF:
        return Interval.bottom()
    return Interval(lo, hi)


def interval_out(iv):
    if iv.is_bottom():
        return {"lo": "0", "hi": "inf"}
    return {"lo": val_out(iv.lo), "hi": val_out(iv.hi)}


def leq_upper_ends(thresholds, grade):
    """Q.leq of the grade's upper ends against the thresholds, axis by axis."""
    names = tuple(f"a{i}" for i in range(len(grade)))
    axes = Axes(S=names, M=())
    ends = {n: (Q.BOTTOM if iv.is_bottom() else iv.hi) for n, iv in zip(names, grade)}
    caps = {n: (val(thresholds[i]) if i < len(thresholds) else INF) for i, n in enumerate(names)}
    return Q(axes, ends).leq(Q(axes, caps))


def answer(v):
    op = v["op"]
    if op == "combine":
        out = []
        for i, b in enumerate(v["g"]):
            a, c = interval(b), interval(v["h"][i])
            kind = v["kinds"][i] if i < len(v["kinds"]) else "floor"
            out.append(interval_out(a.join(c) if kind == "floor" else a.plus(c)))
        return out
    if op == "verdict":
        grade = [interval(b) for b in v["grade"]]
        return "accept" if leq_upper_ends(v["thresholds"], grade) else "reject"
    if op == "lease":
        grade = [interval(b) for b in v["grade"]]
        lifted = QPrime({f"a{i}": iv for i, iv in enumerate(grade)})
        if not lifted.guard_no_bottom():
            return "reject"
        return "accept" if leq_upper_ends(v["thresholds"], grade) else "reject"
    return None


def main(path):
    corpus = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    answers = [{"id": e["id"], "answer": answer(e["vector"])} for e in corpus["vectors"]]
    json.dump({"answers": answers}, sys.stdout)
    sys.stdout.write("\n")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[2])
    main(sys.argv[1])
