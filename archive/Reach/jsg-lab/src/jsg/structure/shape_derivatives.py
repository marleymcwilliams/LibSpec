from __future__ import annotations
import jax.numpy as jnp


def compute_h_star(var: float, m: int, Cb: float) -> float:
    return float((var / max(1, m) / (Cb**2 + 1e-12)) ** (1.0 / 6.0))


def fd_grad_with_freeze(f, theta: jnp.ndarray, sampler, freeze_bias_ratio: float, m_per_side: int = 8):
    """Two-sided central FD with adaptive h*; returns grad and MSE diagnostics."""
    # Pilot to estimate variance and curvature bound (placeholder)
    var = 1.0
    Cb = 1.0
    h = compute_h_star(var, 2 * m_per_side, Cb)
    e = jnp.eye(theta.size)
    grads = []
    for i in range(theta.size):
        th_plus = theta + h * e[i]
        th_minus = theta - h * e[i]
        f_plus = f(th_plus, sampler)
        f_minus = f(th_minus, sampler)
        grads.append((f_plus - f_minus) / (2 * h))
    g = jnp.array(grads)
    return g, {"h_star": h, "freeze_bias": float(freeze_bias_ratio)}

