import sys
import json
import pathlib
import argparse


def main(argv=None):
    p = argparse.ArgumentParser()
    p.add_argument("--root", default="artifacts", help="Artifacts root directory")
    p.add_argument("--require", nargs="*", default=None, help="Required subdirs")
    args = p.parse_args(argv)

    ROOT = pathlib.Path(args.root)
    required = set(args.require or {"transport-pack", "frontier-ledger", "pr-witness", "dro-kkt", "automata-evidence"})
    missing = [d for d in required if not (ROOT / d).exists()]
    if missing:
        print("❌ Missing artifact dirs:", ", ".join(missing))
        return 1

    # spot check: at least one GKYP witness + ledger row present
    if not list((ROOT / "pr-witness").glob("*.json")):
        print("❌ No PR witnesses found.")
        return 1
    if not list((ROOT / "frontier-ledger").glob("*.csv")) and not list((ROOT / "frontier-ledger").glob("*.json")):
        print("❌ No Frontier Ledger rows found.")
        return 1

    print("✅ Acceptance artifacts present.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
