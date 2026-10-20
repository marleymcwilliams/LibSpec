from __future__ import annotations
import jax
import jax.numpy as jnp
from typing import Callable, Dict

def frontier_diagnostics(xs: jnp.ndarray,
                         phi_fn: Callable[[jnp.ndarray], jnp.ndarray],
                         r_tube: float) -> Dict:
    """
    Vectorized diagnostics over a trajectory xs:[T,d]:
      - N_cross: number of sign changes
      - dwell: empirical min dwell between crossings
      - tube_frac: fraction of steps in tube
    """
    phi = jax.vmap(phi_fn)(xs)
    signs = jnp.sign(phi)
    crosses = (signs[:-1] * signs[1:] < 0).astype(jnp.int32)
    idx = jnp.nonzero(crosses, size=crosses.size, fill_value=-1)[0]
    idx = idx[idx >= 0]
    diffs = jnp.diff(jnp.concatenate([jnp.array([-1]), idx]))
    dwell = float(jnp.where(diffs.size > 0, jnp.min(diffs), xs.shape[0]))
    tube_frac = float(jnp.mean((jnp.abs(phi) < r_tube).astype(jnp.float32)))
    return {"N_cross": int(jnp.sum(crosses)),
            "dwell": dwell,
            "tube_frac": tube_frac}

