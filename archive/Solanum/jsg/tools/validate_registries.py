"""Validate JSON registries against schemas.

Usage:
  python -m tools.validate_registries [registries_root] [schemas_root]
Defaults:
  registries_root = registries
  schemas_root    = registries/schemas
"""
from __future__ import annotations

import sys
import json
from pathlib import Path


def _load_json(path: Path):
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def main(argv=None) -> int:
    import importlib

    args = list(sys.argv[1:] if argv is None else argv)
    registries_root = Path(args[0]) if args else Path("registries")
    schemas_root = Path(args[1]) if len(args) > 1 else Path("registries/schemas")

    try:
        jsonschema = importlib.import_module("jsonschema")
    except ModuleNotFoundError:
        print("jsonschema not installed; skipping strict validation (CI installs it).")
        return 0

    # Map files to schemas by simple name matching
    files_and_schemas = [
        (registries_root / "MergeRegistry.json", schemas_root / "merge_registry.schema.json"),
        (registries_root / "ContextRegistry.json", schemas_root / "context_registry.schema.json"),
        (registries_root / "InstrumentMap.json", schemas_root / "instrument_map.schema.json"),
        (registries_root / "UncertaintyDescriptor" / "polytope.json", schemas_root / "uncertainty.schema.json"),
        (registries_root / "UncertaintyDescriptor" / "lft.json", schemas_root / "uncertainty.schema.json"),
    ]

    errors = 0
    for data_path, schema_path in files_and_schemas:
        if not data_path.exists():
            print(f"SKIP: {data_path} not found")
            continue
        data = _load_json(data_path)
        schema = _load_json(schema_path)
        try:
            jsonschema.validate(instance=data, schema=schema)
            print(f"OK: {data_path} ✓")
        except Exception as e:  # noqa: BLE001
            print(f"FAIL: {data_path}: {e}")
            errors += 1

    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
