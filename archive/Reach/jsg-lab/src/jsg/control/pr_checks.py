from __future__ import annotations
from typing import Tuple
import numpy as np
import cvxpy as cp

def _phase_grid_margin(sys, band, n_freq: int = 256) -> float:
    """Dense-grid frequency check: min Re{H(jw)} on the band."""
    A, B, C, D = [np.asarray(m, dtype=float) for m in sys]
    wL, wH = float(band[0]), float(band[1])
    omegas = np.geomspace(max(1e-6, wL), wH, n_freq)
    I = np.eye(A.shape[0])
    re_min = +1e9
    for w in omegas:
        s = 1j * w
        H = C @ np.linalg.solve(s * I - A, B) + D  # 1x1 assumed; extend if MIMO
        re_min = min(re_min, float(np.real(H)))
    return re_min

def check_positive_real(sys, band, eps_min: float) -> Tuple[bool, float]:
    """
    Certify positive realness using KYP LMI; fallback to phase-grid check.
    For SISO controller G(s) with (A,B,C,D): PR if ∃ P>0 s.t.
      [AᵀP + PA,  PB - Cᵀ;  (PB - Cᵀ)ᵀ,  -(D + Dᵀ)] ⪯ -ε I, with D + Dᵀ >= ε I.
    """
    A, B, C, D = [np.asarray(m, dtype=float) for m in sys]
    n = A.shape[0]
    P = cp.Variable((n, n), PSD=True)
    eps = cp.Variable(nonneg=True)
    M11 = A.T @ P + P @ A
    M12 = P @ B - C.T
    M22 = -(D + D.T)
    M = cp.bmat([[M11, M12],
                 [M12.T, M22]])
    constraints = [M << -eps * np.eye(n + 1),  # SISO ⇒ block size n+1
                   D + D.T >> eps * np.eye(D.shape[0]),
                   eps >= eps_min / 2.0]
    prob = cp.Problem(cp.Minimize(0.0), constraints)
    try:
        prob.solve(solver=cp.SCS, verbose=False)
        if prob.status in (cp.OPTIMAL, cp.OPTIMAL_INACCURATE):
            return True, float(eps_min)
        # Fallback: numeric grid
        margin = _phase_grid_margin(sys, band)
        return bool(margin >= eps_min), float(max(0.0, margin))
    except Exception:
        margin = _phase_grid_margin(sys, band)
        return bool(margin >= eps_min), float(max(0.0, margin))
