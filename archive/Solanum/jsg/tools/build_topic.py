#!/usr/bin/env python3
"""
Build a topic-specific composed TeX wrapper across Parts 1, 2, 3.

Reads jsg/merge/merge_map.json to get files per topic.
Uses generate_wrappers.py --compose to write jsg/papers/merge/TOPIC_<key>.tex,
then you can latexmk it (Makefile target provided).

Usage:
  python jsg/tools/build_topic.py --key control --title "JSG Topic: Control"
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # jsg/
MAP = ROOT / "merge" / "merge_map.json"
GEN = ROOT / "tools" / "generate_wrappers.py"
OUT_DIR = ROOT / "papers" / "merge"


def run(cmd: list[str]) -> int:
    try:
        safe = " ".join(cmd).encode("ascii", "backslashreplace").decode()
        print("+", safe)
    except Exception:
        print("+", cmd[0])
    return subprocess.call(cmd)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--key", required=True, help="topic key from merge_map.json (e.g., control, stoch, intro)")
    ap.add_argument("--title", help="custom title for the topic pack")
    args = ap.parse_args()

    spec = json.loads(MAP.read_text(encoding="utf-8"))
    topics = {t.get("key"): t for t in spec.get("topics", [])}
    if args.key not in topics:
        print(f"Unknown topic key: {args.key}")
        print("Available:", ", ".join(sorted(topics)))
        return 2
    t = topics[args.key]
    # Build include spec list, keeping order p1, p2, p3
    includes: list[str] = []
    for part_key in ("p1", "p2", "p3"):
        for f in t.get(part_key, []) or []:
            includes.append(f)
    if not includes:
        print("No files mapped for topic", args.key)
        return 0

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / f"TOPIC_{args.key.upper()}.tex"
    title = args.title or f"JSG Topic Pack: {args.key.title()}"
    compose_arg = ",".join(includes)
    rc = run([
        os.fspath(Path(os.sys.executable)),
        os.fspath(GEN),
        "--compose", compose_arg,
        "--title", title,
        "--out", os.fspath(out_path),
    ])
    if rc != 0:
        return rc
    print(f"Wrote {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

