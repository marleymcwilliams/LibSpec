"""
BLAKE3-256 digests for canonical JSON bytes.
Spec: SCp1 A5.4.1-4.2; SCp5 N0 (BLAKE3 binding).
"""
from __future__ import annotations

from typing import Any

from .canon import dumps_canon_v1

try:
    import blake3  # type: ignore
except Exception:  # pragma: no cover
    blake3 = None  # type: ignore

B3_PREFIX = "b3:"


def blake3_available() -> bool:
    return blake3 is not None


def require_blake3() -> None:
    if not blake3_available():
        raise RuntimeError("BLAKE3 module not available. Install `pip install blake3`." )


def b3(data: bytes) -> bytes:
    require_blake3()
    return blake3.blake3(data).digest()  # type: ignore[attr-defined]


def b3_hex(data: bytes) -> str:
    require_blake3()
    return blake3.blake3(data).hexdigest()  # type: ignore[attr-defined]


def b3_json(obj: Any) -> str:
    digest_hex = b3_hex(dumps_canon_v1(obj))
    return f"{B3_PREFIX}{digest_hex}"
