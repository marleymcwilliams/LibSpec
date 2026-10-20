from __future__ import annotations
import jax
import jax.numpy as jnp

def gaussian_sketch(x: jnp.ndarray, k: int, key: jax.random.KeyArray) -> jnp.ndarray:
    """
    Random projection sketch of features to k < d.
    x:[T,d] → xR:[T,k],  R ~ N(0,1/√k).
    """
    T, d = x.shape
    R = jax.random.normal(key, (d, k)) / jnp.sqrt(k)
    return x @ R

