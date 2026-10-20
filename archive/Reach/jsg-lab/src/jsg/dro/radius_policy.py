from __future__ import annotations

def radius_from_drift(L_hat: float, rp_cfg) -> float:
    """ρ_t = c · L̂_t · τ (adaptive trust region)."""
    return float(rp_cfg.c * L_hat * rp_cfg.tau)

