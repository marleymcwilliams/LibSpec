"""
TailContract interface (family-independent).
Spec: SCp4 §1 (Definition 1.2) and Theorems 1.4–1.6.
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import Any, Dict, Protocol

class TailExec(Protocol):
    def step(self) -> "TailExec": ...
    def accept(self) -> bool: ...

@dataclass
class TailContract:
    witness: Dict[str, Any]
    def check(self) -> None:
        # Placeholder schema validation hook
        if "type" not in self.witness:
            raise ValueError("Invalid witness: missing type")
