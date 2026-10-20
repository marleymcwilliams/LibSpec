from __future__ import annotations
import jax.numpy as jnp
from typing import Tuple

def ledoit_wolf_shrinkage(cov: jnp.ndarray, x: jnp.ndarray) -> Tuple[jnp.ndarray, float]:
    """
    Simple Ledoit–Wolf shrinkage of covariance toward μ I.
    x:[T,d] zero-centered; cov: empirical covariance.
    Returns (Σ_hat, λ).
    """
    T, d = x.shape
    mu = jnp.trace(cov) / d
    prior = mu * jnp.eye(d)
    # Compute pi_hat (variance of sample covariance entries)
    x2 = x ** 2
    phi_mat = (x2.T @ x2) / T - cov ** 2
    phi = jnp.sum(phi_mat)
    # rho_hat (Fro norm between cov and prior)
    delta = cov - prior
    rho = jnp.sum(delta ** 2)
    lam = jnp.clip(phi / jnp.maximum(rho, 1e-12) / T, 0.0, 1.0)
    sigma = lam * prior + (1 - lam) * cov
    return sigma, float(lam)

