#!/usr/bin/env python3
"""
Generate a merge status report from jsg/merge/merge_map.json.

Outputs a concise CLI report and an optional Markdown file at jsg/docs/merge-status.md
with per-topic file presence and label/ref counts per part.

Usage:
  python jsg/tools/merge_status.py [--md]
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
from typing import Dict, List

ROOT = Path(__file__).resolve().parents[1]  # jsg/
MAP = ROOT / "merge" / "merge_map.json"
DOC_MD = ROOT / "docs" / "merge-status.md"

LABEL_RE = re.compile(r"\\label\{([^}]+)\}")
REF_RE = re.compile(r"\\ref\{([^}]+)\}")


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def count_labels_refs(files: List[str]) -> Dict[str, int]:
    labels = set()
    refs = []
    for f in files:
        p = ROOT / f  # jsg-root relative inputs
        if not p.exists():
            continue
        s = read_text(p)
        labels.update(LABEL_RE.findall(s))
        refs.extend(REF_RE.findall(s))
    unresolved = [r for r in refs if r not in labels]
    return {"labels": len(labels), "refs": len(refs), "unresolved": len(unresolved)}


def total_bytes(files: List[str]) -> int:
    total = 0
    for f in files:
        p = ROOT / f
        if not p.exists():
            continue
        total += len(read_text(p))
    return total


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--md", action="store_true", help="also write docs/merge-status.md")
    args = ap.parse_args()

    spec = json.loads(MAP.read_text(encoding="utf-8"))
    topics = spec.get("topics", [])

    lines = []
    lines.append("# Merge Status\n")
    lines.append("key | status | p1_files | p2_files | p3_files | p1(lbl/ref/unr) | p2(lbl/ref/unr) | p3(lbl/ref/unr) | size_p1 | size_p2 | size_p3 | cov_p3/(p1+p2)")
    lines.append("--- | --- | --- | --- | --- | --- | --- | --- | ---:| ---:| ---:| ---:")

    for t in topics:
        p1 = t.get("p1", [])
        p2 = t.get("p2", [])
        p3 = t.get("p3", [])
        s1 = count_labels_refs(p1)
        s2 = count_labels_refs(p2)
        s3 = count_labels_refs(p3)
        size1 = total_bytes(p1)
        size2 = total_bytes(p2)
        size3 = total_bytes(p3)
        denom = (size1 + size2) or 1
        cov = f"{size3/denom:.2f}"
        row = [
            t.get("key", ""),
            t.get("status", ""),
            "+".join(p1) if p1 else "-",
            "+".join(p2) if p2 else "-",
            "+".join(p3) if p3 else "-",
            f"{s1['labels']}/{s1['refs']}/{s1['unresolved']}",
            f"{s2['labels']}/{s2['refs']}/{s2['unresolved']}",
            f"{s3['labels']}/{s3['refs']}/{s3['unresolved']}",
            str(size1), str(size2), str(size3), cov
        ]
        lines.append(" | ".join(row))

    report = "\n".join(lines) + "\n"
    print(report)

    if args.md:
        DOC_MD.write_text(report, encoding="utf-8")
        print(f"Wrote {DOC_MD}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
