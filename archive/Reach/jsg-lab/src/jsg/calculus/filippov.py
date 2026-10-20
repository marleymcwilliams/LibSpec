from __future__ import annotations
import jax
import jax.numpy as jnp
from typing import Callable, Tuple

Array = jnp.ndarray

def smooth_selector(phi: Array, eps: float) -> Array:
    """σ(φ/ε) ∈ (0,1) as a smooth selection across a frontier."""
    return jax.nn.sigmoid(phi / jnp.maximum(eps, 1e-9))

def blended_field(x: Array,
                  phi_fn: Callable[[Array], Array],
                  f1: Callable[[Array], Array],
                  f2: Callable[[Array], Array],
                  eps: float) -> Array:
    """
    Filippov-style regularization:
      ẋ = σ(φ(x)/ε) f1(x) + (1-σ(φ(x)/ε)) f2(x)
    """
    s = smooth_selector(phi_fn(x), eps)
    return s * f1(x) + (1.0 - s) * f2(x)

def tube_mask(phi: Array, r_tube: float) -> Array:
    """Indicator for being inside the tubular neighborhood |φ| < r_tube."""
    return (jnp.abs(phi) < r_tube).astype(jnp.float32)

def scan_crossings(xs: Array,
                   phi_fn: Callable[[Array], Array]) -> Tuple[int, Array]:
    """
    Count frontier sign changes along a trajectory xs:[T,d].
    Returns (N_cross, sign_series[T]).
    """
    def step(carry, x_t):
        last_sign = carry
        s = jnp.sign(phi_fn(x_t))
        cross = jnp.where(last_sign * s < 0.0, 1, 0)
        return s, cross

    s0 = jnp.sign(phi_fn(xs[0]))
    _, crosses = jax.lax.scan(step, s0, xs[1:])
    return int(jnp.sum(crosses)), jnp.concatenate([jnp.array([s0]), jnp.zeros_like(crosses)])

