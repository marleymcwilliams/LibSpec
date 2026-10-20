from __future__ import annotations
import numpy as np
import jax.numpy as jnp
from dataclasses import dataclass
from typing import Tuple, Optional
from scipy.signal import tf2ss  # used once at build time; arrays converted to jnp

def _oustaloup_zeros_poles(alpha: float, N: int, omega_L: float, omega_H: float):
    """
    Classic Oustaloup recursive approximation (N pole-zero pairs) of s^alpha on [omega_L, omega_H].

    Transfer approx: K * Π_k (s + z_k) / (s + p_k), with zeros at -z_k, poles at -p_k (z_k, p_k > 0).
    The formulas below are a practical variant commonly used in control applications.
    """
    # Sanity
    assert 0.0 < omega_L < omega_H
    assert N >= 1
    # Geometric mid-frequency
    omega_0 = np.sqrt(omega_L * omega_H)
    # Log ratio
    L = np.log(omega_H / omega_L)

    # Z/P frequencies
    # NOTE: This variant spreads zeros/poles geometrically and offsets with alpha.
    k = np.arange(1, N + 1, dtype=float)
    z_k = omega_L * np.exp(((2.0 * k - 1.0) * L) / (2.0 * N) + (alpha * L) / (2.0 * N))
    p_k = omega_L * np.exp(((2.0 * k - 1.0) * L) / (2.0 * N) - (alpha * L) / (2.0 * N))
    # Raw gain; scale later to match |s^alpha| at omega_0
    K = omega_0 ** alpha
    return z_k, p_k, K, omega_0

def _tf_from_zpk(z: np.ndarray, p: np.ndarray, K: float) -> Tuple[np.ndarray, np.ndarray]:
    """Build numerator/denominator polys of Π (s + z_k)/(s + p_k) times K."""
    num = np.poly(-z)  # (s + z_1)(s + z_2)...
    den = np.poly(-p)
    num = K * num
    return num, den

def _normalize_gain(num: np.ndarray, den: np.ndarray, alpha: float, omega0: float) -> np.ndarray:
    """Scale numerator so that |H(j*omega0)| ≈ (omega0)^alpha."""
    s = 1j * omega0
    H = np.polyval(num, s) / np.polyval(den, s)
    target = (omega0 ** alpha)
    scale = target / (np.abs(H) + 1e-12)
    return num * scale

@dataclass
class ControllerState:
    x: jnp.ndarray = jnp.zeros((1,))  # will be resized by build

    def freeze(self) -> None:
        # Intentionally a no-op: state is held constant while frozen
        pass

    def unfreeze(self) -> None:
        pass

    def step(self, sys: Tuple[jnp.ndarray, jnp.ndarray, jnp.ndarray, jnp.ndarray], e: jnp.ndarray) -> jnp.ndarray:
        A, B, C, D = sys
        self.x = A @ self.x + B @ e
        return C @ self.x + D @ e

def oustaloup_ss(alpha: float, N: int, band, gains: Optional[dict]) -> Tuple[jnp.ndarray, jnp.ndarray, jnp.ndarray, jnp.ndarray]:
    """
    Build continuous-time state-space (A,B,C,D) for Oustaloup approx of s^alpha on [omega_L, omega_H].
    Returns JAX arrays; internally uses SciPy tf2ss for a robust rational realization.
    """
    omega_L, omega_H = float(band[0]), float(band[1])
    z, p, K, omega0 = _oustaloup_zeros_poles(alpha, N, omega_L, omega_H)
    num, den = _tf_from_zpk(z, p, K)
    num = _normalize_gain(num, den, alpha, omega0)

    # Realize as state-space via controllable canonical form
    A, B, C, D = tf2ss(num, den)

    # Optional static gain shaping (e.g., proportional gain) if provided
    if gains and "k" in gains:
        C = C * float(gains["k"])

    # Convert to jnp
    return jnp.asarray(A), jnp.asarray(B), jnp.asarray(C), jnp.asarray(D)
