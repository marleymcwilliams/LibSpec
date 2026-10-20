from __future__ import annotations
import jax
import jax.numpy as jnp
from typing import Dict

def _pairwise_l2(a: jnp.ndarray, b: jnp.ndarray) -> jnp.ndarray:
    aa = jnp.sum(a * a, axis=1, keepdims=True)
    bb = jnp.sum(b * b, axis=1, keepdims=True).T
    ab = a @ b.T
    return jnp.sqrt(jnp.maximum(aa + bb - 2.0 * ab, 0.0))

def _logsumexp(x: jnp.ndarray, axis: int = -1) -> jnp.ndarray:
    m = jnp.max(x, axis=axis, keepdims=True)
    return jnp.squeeze(m + jnp.log(jnp.sum(jnp.exp(x - m), axis=axis, keepdims=True)), axis=axis)

class DRO:
    def __init__(self, cfg):
        self.last_eta = 0.0
        self.last_rho = 0.0
        self.last_drift = 0.0

    def estimate_w1_drift(self, window) -> float:
        # Keep simple sliced-W1 in previous version
        import numpy as np
        X = np.asarray(window)
        if not hasattr(self, "_prev"): self._prev = X.copy(); return 1e-2
        Y = self._prev; self._prev = X.copy()
        rng = np.random.default_rng(123)
        d = X.shape[1]; acc = 0.0; dirs = 32
        for _ in range(dirs):
            u = rng.normal(size=(d,)); u /= (np.linalg.norm(u) + 1e-12)
            x = np.sort(X @ u); y = np.sort(Y @ u); m = min(len(x), len(y))
            acc += float(np.mean(np.abs(x[:m] - y[:m])))
        return acc / dirs

    def _g(self, eta: float, X: jnp.ndarray, Z: jnp.ndarray) -> float:
        D = _pairwise_l2(X, Z)
        w = jax.nn.softmax(-eta * D, axis=1)
        d_bar = jnp.sum(w * D, axis=1)
        return float(jnp.mean(d_bar))

    def _bisect_eta(self, rho: float, X: jnp.ndarray, Z: jnp.ndarray,
                    lo: float = 1e-6, hi: float = 1e3, iters: int = 40) -> float:
        gl = self._g(lo, X, Z)
        gh = self._g(hi, X, Z)
        while gh > rho and hi < 1e6:
            hi *= 2.0
            gh = self._g(hi, X, Z)
        for _ in range(iters):
            mid = 0.5 * (lo + hi)
            gm = self._g(mid, X, Z)
            lo, hi = (mid, hi) if gm > rho else (lo, mid)
        return 0.5 * (lo + hi)

    def step(self, window, fisher, rho_t: float, log) -> None:
        X = jnp.asarray(window)
        Z = X
        eta_star = self._bisect_eta(rho_t, X, Z)
        self.last_eta = float(eta_star)
        self.last_rho = float(rho_t)

    def snapshot(self) -> Dict:
        return {"eta_star": self.last_eta, "rho_t": self.last_rho, "drift": self.last_drift}
