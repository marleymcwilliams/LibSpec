#!/usr/bin/env python3
"""
Lint (and optionally fix) constref/constlabel usage across papers.

Finds patterns like:
  \constref{\tau}    -> should be \constref{tau}
  \constlabel{\epsilon} -> should be \constlabel{epsilon}

By default, prints a report. Use --fix to apply in-place edits.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAPERS = ROOT / "papers"

PATTERNS = [
    (re.compile(r"\\constref\{\\([^}]+)\}"), r"\\constref{\1}"),
    (re.compile(r"\\constlabel\{\\([^}]+)\}"), r"\\constlabel{\1}"),
    (re.compile(r"\\constantlabel\{\\([^}]+)\}"), r"\\constantlabel{\1}"),
]


def process_file(path: Path, fix: bool) -> tuple[int, int]:
    text = path.read_text(encoding="utf-8")
    original = text
    total_matches = 0
    for rx, repl in PATTERNS:
        matches = list(rx.finditer(text))
        total_matches += len(matches)
        if fix and matches:
            text = rx.sub(lambda m: repl.replace("\\1", m.group(1)), text)
    if fix and text != original:
        path.write_text(text, encoding="utf-8")
    return total_matches, 1 if text != original else 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--fix", action="store_true", help="Apply in-place fixes")
    args = ap.parse_args()

    tex_files = list(PAPERS.rglob("*.tex"))
    total = 0
    changed = 0
    flagged = []
    for f in tex_files:
        n, c = process_file(f, args.fix)
        total += n
        changed += c
        if n:
            flagged.append((f, n))

    if flagged:
        print("Const lints found in:")
        for f, n in flagged:
            print(f"  {f}: {n} issue(s)")
    else:
        print("No constref/constlabel issues found.")

    if args.fix:
        print(f"Applied fixes to {changed} file(s).")
    else:
        print("Run with --fix to apply suggested edits.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

