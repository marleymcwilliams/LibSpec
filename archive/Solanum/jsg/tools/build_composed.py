#!/usr/bin/env python3
"""
Build composed TeX wrappers for staged merging across parts.

Reads jsg/papers/merge/compose.json and uses generate_wrappers.py --compose
to produce stable TeX files under jsg/papers/merge/.

Usage:
  python jsg/tools/build_composed.py
"""
from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
COMPOSE_SPEC = ROOT / "papers" / "merge" / "compose.json"
GEN = ROOT / "tools" / "generate_wrappers.py"


def run(cmd: list[str]) -> int:
    # Print an ASCII-safe version of the command to avoid encoding issues on Windows consoles
    try:
        safe = " ".join(cmd).encode("ascii", "backslashreplace").decode()
        print("+", safe)
    except Exception:
        # Fallback: print only the executable name
        print("+", cmd[0])
    return subprocess.call(cmd)


def main() -> int:
    if not COMPOSE_SPEC.exists():
        print(f"compose spec not found: {COMPOSE_SPEC}", file=sys.stderr)
        return 2
    spec = json.loads(COMPOSE_SPEC.read_text(encoding="utf-8"))
    merges = spec.get("merges", [])
    for m in merges:
        includes = m.get("include", [])
        title = m.get("title", "JSG Composed")
        out = m.get("out")
        if not out:
            print("Missing 'out' in compose spec entry", file=sys.stderr)
            return 3
        compose_arg = ",".join(includes)
        rc = run([
            sys.executable,
            str(GEN),
            "--compose", compose_arg,
            "--title", title,
            "--out", out,
        ])
        if rc != 0:
            return rc
    print("Composed wrappers written.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
