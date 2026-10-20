#!/usr/bin/env python3
"""Generate a simple placeholder hitmap artifact.

Writes a JSON grid to artifacts/pr-witness/win-YYYYMMDDThhmmssZ_hitmap.json.
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path


def main() -> int:
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out_dir = Path("artifacts/pr-witness")
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"win-{ts}_hitmap.json"
    payload = {"grid": [[0, 1], [1, 0]], "generated": ts}
    out.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
