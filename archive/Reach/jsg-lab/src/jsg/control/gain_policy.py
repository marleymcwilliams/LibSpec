from __future__ import annotations
import jax.numpy as jnp

def entropy_aware_gain(norm_kappa_fim: float,
                       g_nom: float,
                       phi_scale: float = 1.0,
                       g_min: float = 0.1,
                       g_max: float = 5.0) -> float:
    """
    g ← proj_G( g_nom * φ(||κ_mix||_{FIM^-1}) ), with φ monotone.
    Here φ(x) = 1 / (1 + phi_scale * x).
    """
    g = g_nom / (1.0 + phi_scale * float(norm_kappa_fim))
    return float(jnp.clip(g, g_min, g_max))

