from __future__ import annotations
import jax
import jax.numpy as jnp
import numpy as np
from typing import Dict, Tuple
from .shrinkage import ledoit_wolf_shrinkage
from .sketch import gaussian_sketch

def running_moments_scan(xs: jnp.ndarray):
    """
    Streaming first/second moments via lax.scan for windowed cumulants.
    xs:[T,d] → (mean, cov)
    """
    def step(carry, x):
        n, mu, M2 = carry
        n1 = n + 1
        delta = x - mu
        mu1 = mu + delta / n1
        M21 = M2 + delta * (x - mu1)
        return (n1, mu1, M21), None

    (n, mu, M2), _ = jax.lax.scan(step, (0.0, jnp.zeros(xs.shape[1]), jnp.zeros(xs.shape[1])), xs)
    cov = M2 / jnp.maximum(n - 1.0, 1.0)
    return mu, cov

def estimate_cumulants(window: np.ndarray,
                       order: int = 3,
                       sketch_dim: int | None = None,
                       key: jax.random.KeyArray | None = None) -> Dict:
    """
    Compute basic cumulant proxies up to K=3 with shrinkage + optional sketching.
    Returns dict with FIM-proxy norm and HAC-ready scalar influence (mean0).
    """
    X = jnp.asarray(window)
    if sketch_dim and key is not None and X.shape[1] > sketch_dim:
        X = gaussian_sketch(X, sketch_dim, key)

    Xc = X - jnp.mean(X, axis=0, keepdims=True)
    Sigma = (Xc.T @ Xc) / jnp.maximum(1, X.shape[0] - 1)
    Sigma_sh, lam = ledoit_wolf_shrinkage(Sigma, Xc)

    # Order-3 cumulant proxy: coordinatewise skewness magnitude
    m3 = jnp.mean(Xc ** 3, axis=0)
    k3_norm = float(jnp.linalg.norm(m3))

    norm_FIM = float(jnp.linalg.norm(Sigma_sh, ord='fro'))
    infl_scalar = np.asarray(jnp.squeeze(jnp.mean(Xc, axis=1)))  # mean0 influence
    return {"norm_FIM": norm_FIM,
            "k3_norm": k3_norm,
            "shrink_lam": float(lam),
            "influence_series": infl_scalar}
