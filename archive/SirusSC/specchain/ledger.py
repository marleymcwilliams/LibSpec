"""
Ledger blocks and content address H(b)=BLAKE3-256(hbytes||pbytes)
Spec: SCp1 §4.2 (Block, hash, integrity); header fields §4 Table 1.
"""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Dict, Any, List
from .canon import dumps_canon_v1
from .digest import b3_hex

@dataclass
class Block:
    header: Dict[str, Any]
    payload: Dict[str, Any]

    def hbytes(self) -> bytes:
        return dumps_canon_v1(self.header)

    def pbytes(self) -> bytes:
        return dumps_canon_v1(self.payload)

    def digest(self) -> str:
        return b3_hex(self.hbytes() + self.pbytes())

def make_genesis(payload: Dict[str, Any], suite: str, meta: Dict[str, Any] | None = None) -> Block:
    header = {
        "parent_hashes": [],  # genesis
        "suite": suite,
        "meta": meta or {},
    }
    return Block(header=header, payload=payload)
