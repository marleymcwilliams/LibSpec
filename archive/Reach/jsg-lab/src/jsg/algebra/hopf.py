from __future__ import annotations
import jax.numpy as jnp
from typing import Dict

def hopf_project(stats: Dict[str, jnp.ndarray], K: int) -> Dict[str, jnp.ndarray]:
    """
    Truncate mixed-cumulant dictionary to total degree ≤ K.
    stats keys e.g. "k11","k12","k21","k30",...
    """
    out = {}
    for k, v in stats.items():
        deg = sum(int(c) for c in k if c.isdigit())
        if deg <= K:
            out[k] = v
    return out

def hopf_residual_norm(stats: Dict[str, jnp.ndarray], K: int) -> float:
    res = 0.0
    for k, v in stats.items():
        deg = sum(int(c) for c in k if c.isdigit())
        if deg > K:
            res += float(jnp.sum(v * v))
    return res ** 0.5

