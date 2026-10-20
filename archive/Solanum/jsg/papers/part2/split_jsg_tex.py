#!/usr/bin/env python3
"""
Split a monolithic Part II TeX into A/B wrappers.

Usage:
  python split_jsg_tex.py input.tex --outA JSG_II_A.tex --outB JSG_II_B.tex

This is a minimal placeholder that documents the intended interface.
"""
import argparse
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("--outA", default="JSG_II_A.tex")
    ap.add_argument("--outB", default="JSG_II_B.tex")
    args = ap.parse_args()
    src = Path(args.input)
    if not src.exists():
        print(f"Input not found: {src}")
        return 1
    # Placeholder: copy as both outputs for now.
    a = Path(args.outA)
    b = Path(args.outB)
    a.write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
    b.write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
    print(f"Wrote {a} and {b}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
