#!/usr/bin/env python3
"""Summarize LaTeX changes for CI comments (placeholder).

Prints changed .tex files and figure directories. In CI, this can be posted
to a PR as a job log or comment by an additional step.
"""
from pathlib import Path


def main() -> int:
    tex = list(Path(".").rglob("*.tex"))
    print("LaTeX sources:")
    for p in sorted(tex):
        print(f" - {p}")
    print("\nFigure directories under papers/part2/figures:")
    for d in sorted((Path("papers/part2/figures")).glob("*/")):
        print(f" - {d}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
