#!/usr/bin/env python3
"""
Lint cross-references across JSG parts.

Scans LaTeX section files under jsg/papers/part{1,2,3}/sections for:
 - defined labels (\label{...})
 - local refs (\ref{...}) and safe cross-doc macros (\jsgi*, \jsgii*)

Emits a simple report of defined labels per part, and references whose
targets are not present locally (to aid reconciliation during merging).

Usage:
  python jsg/tools/lint_xrefs.py
"""
from __future__ import annotations

import re
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]

LABEL_RE = re.compile(r"\\label\{([^}]+)\}")
REF_RE = re.compile(r"\\ref\{([^}]+)\}")
JSG_RE = re.compile(r"\\(jsgi(?:Lem|Thm|Def|Sec)|jsgii(?:Lem|Thm|Def|Sec))\{([^}]+)\}")


def tex_files(part: str) -> list[Path]:
    base = ROOT / part / "sections"
    return sorted([p for p in base.glob("*.tex") if p.is_file()])


def collect(part: str):
    labels = set()
    refs = set()
    xdocs = set()
    for p in tex_files(part):
        s = p.read_text(encoding="utf-8", errors="ignore")
        labels.update(LABEL_RE.findall(s))
        refs.update(REF_RE.findall(s))
        xdocs.update(m[1] for m in JSG_RE.finditer(s))
    return labels, refs, xdocs


def main() -> int:
    parts = ["papers/part1", "papers/part2", "papers/part3"]
    report = {}
    for pt in parts:
        labels, refs, xdocs = collect(pt)
        report[pt] = {"labels": labels, "refs": refs, "xdocs": xdocs}

    print("# Label summary")
    for pt in parts:
        print(f"- {pt}: {len(report[pt]['labels'])} labels, {len(report[pt]['refs'])} local refs, {len(report[pt]['xdocs'])} cross-doc refs")

    # Local unresolved refs (heuristic): ref not defined in same part
    print("\n# Potential local unresolved refs")
    for pt in parts:
        labels = report[pt]["labels"]
        unresolved = sorted(r for r in report[pt]["refs"] if r not in labels)
        if unresolved:
            print(f"- {pt}:")
            for r in unresolved:
                print(f"  \- {r}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

