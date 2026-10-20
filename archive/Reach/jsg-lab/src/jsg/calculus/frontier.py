from __future__ import annotations
from typing import Dict


def jacobi_defect_budget(kappa_max: float, theta_min: float) -> float:
    """Per-crossing defect bound C_fr = f(kappa_max, theta_min)."""
    # TODO: derive/encode explicit bound; placeholder monotone form:
    return kappa_max / max(theta_min, 1e-6)


def iss_frontier_term(C0: float, n_cross: int = 0, t: int = 0, tau_min: int = 1) -> Dict[str, float]:
    return {
        "per_crossing": C0 * n_cross,
        "linear_time": C0 * (t / max(1, tau_min)),
    }

