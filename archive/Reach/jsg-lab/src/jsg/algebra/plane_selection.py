from __future__ import annotations
import jax.numpy as jnp
from jax.numpy.linalg import svd
from typing import Dict, Tuple


def select_planes(A: jnp.ndarray, gap_thresh: float) -> Tuple[jnp.ndarray, jnp.ndarray, Dict]:
    U, s, Vt = svd(A, full_matrices=False)
    near_degenerate = (s.shape[0] > 1) and ((s[0] - s[1]) < gap_thresh)
    k = 4 if near_degenerate else 2
    return U[:, :k], Vt[:k, :].T, {"sigmas": s, "gap": float(s[0] - s[1] if s.shape[0] > 1 else s[0]), "near_degenerate": near_degenerate}


def j_aligned_basis(A: jnp.ndarray, U: jnp.ndarray, V: jnp.ndarray) -> jnp.ndarray:
    """Construct J-aligned basis on selected subspace."""
    # TODO: implement phase alignment / Gram-Schmidt
    return jnp.concatenate([U, V], axis=1)

