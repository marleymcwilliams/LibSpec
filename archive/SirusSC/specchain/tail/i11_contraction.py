"""
I11 Contraction Tail (FP-safe) – simplified.
Spec: SCp4 §2 (Definition 2.1, 2.5, failure codes).
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Any, List
import math

FAILURE_CODES: List[str] = [
    "C1_FP_CONTRACTION_FAIL",
    "C2_START_OUTSIDE",
    "C3_NOT_FORWARD_INVARIANT",
    "C4_MAX_ITERS",
    "C5_COMMIT_MISMATCH",
    "C6_UNKNOWN_BUDGET",
]

@dataclass
class ContractionTail:
    gamma_fp: float
    residual_bound: float
    max_iters: int
    d0: float  # initial distance bound

    def run(self) -> Dict[str, Any]:
        if not (0 < self.gamma_fp < 1):
            return {"verdict": "REJECT", "reason_code": "C1_FP_CONTRACTION_FAIL", "family": "I11_Contraction"}
        # Use Lemma 2.6 iteration bound
        eps = self.residual_bound
        k_needed = 1 + math.ceil(math.log(eps / ((1 + self.gamma_fp) * self.d0), self.gamma_fp))
        if k_needed <= self.max_iters:
            return {"verdict": "ACCEPT", "iters": k_needed, "family": "I11_Contraction"}
        else:
            return {"verdict": "REJECT", "reason_code": "C4_MAX_ITERS", "iters": self.max_iters, "family": "I11_Contraction"}
