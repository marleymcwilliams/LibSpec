from __future__ import annotations
from typing import Dict
import jax.numpy as jnp

class ISSBudget:
    """
    Tracks storage H(x) and logs the ISS bound terms, including explicit frontier term:
    C0*N_cross and C0 * t/tau_min.
    """
    def __init__(self, cfg):
        self.alpha = 1.0
        self.epsilon = 0.1
        self.C0 = float(cfg.calculus.C0)
        self._t = 0
        self._H = 0.0

    def H(self, x: jnp.ndarray) -> float:
        return float(0.5 * (x @ x))

    def log_window(self, w_idx: int, margin: float, gaps: Dict, n_cross: int, tau_min: int):
        self._t += 1
        bound_frontier = {"per_crossing": self.C0 * n_cross,
                          "linear_time": self.C0 * (self._t / max(1, tau_min))}
        return {"w": w_idx, "alpha": self.alpha, "epsilon": self.epsilon, "C0": self.C0,
                "n_cross": n_cross, "t_over_tau_min": self._t/max(1, tau_min),
                "frontier_bound": bound_frontier}

