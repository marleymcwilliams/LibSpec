from __future__ import annotations
import jax.numpy as jnp
import numpy as np
from typing import Dict

def _empirical_fisher(window: np.ndarray) -> jnp.ndarray:
    """Empirical Fisher ≈ covariance of sufficient stats (here: raw features as proxy)."""
    X = jnp.asarray(window)
    Xc = X - jnp.mean(X, axis=0, keepdims=True)
    F = (Xc.T @ Xc) / jnp.maximum(1, X.shape[0] - 1)
    # Regularize slightly for numerical stability
    d = F.shape[0]
    return F + 1e-6 * jnp.eye(d)

def _third_moment_bound(window: np.ndarray) -> float:
    """Crude bound for L_psi via third absolute central moments along coordinates."""
    X = np.asarray(window)
    Xc = X - X.mean(axis=0, keepdims=True)
    m3 = np.mean(np.abs(Xc) ** 3, axis=0)  # per-dim
    return float(np.max(m3) + 1e-8)

class FisherContext:
    def __init__(self, cfg):
        self.policy = cfg.data.whitening_policy
        self._F0 = None  # baseline Fisher for "global" and conditioning reference
        self.epsilon = 0.1
        self.r = 0.05
        self.chi = 1.0

    def update(self, window) -> None:
        F_t = _empirical_fisher(window)
        if self._F0 is None:
            self._F0 = F_t

        if self.policy == "global":
            Fw = self._F0
        else:
            Fw = F_t

        # Leakage between local and global coordinates
        F0_inv = jnp.linalg.inv(self._F0)
        T = F_t @ F0_inv
        svals = jnp.linalg.svd(T, compute_uv=False)
        self.chi = float((jnp.max(svals) / jnp.min(svals)))

        # EF radius r = ε / L_psi; pick ε in [0.05, 0.2]
        self.epsilon = 0.1
        Lpsi = _third_moment_bound(window)
        self.r = float(self.epsilon / max(Lpsi, 1e-8))

    def snapshot(self) -> Dict:
        return {"epsilon": self.epsilon, "r": self.r, "chi": self.chi, "policy": self.policy}

