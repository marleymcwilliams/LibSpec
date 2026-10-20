from __future__ import annotations
import jax.numpy as jnp
import numpy as np

class PHPlant:
    """
    Lightweight port-Hamiltonian plant with hybrid (stratum-based) parameters.
    H(x) = 1/2 x^T M x;  ẋ = (J - R)∇H + G u
    """
    def __init__(self, seed: int = 0):
        self.rng = np.random.default_rng(seed)
        self._x = jnp.zeros((2,))
        self._M = jnp.eye(2)
        self._J = jnp.array([[0.0, -1.0],[1.0, 0.0]])
        self._R1 = jnp.diag(jnp.array([0.1, 0.05]))
        self._R2 = jnp.diag(jnp.array([0.2, 0.02]))
        self._G = jnp.array([[1.0],[0.0]])
        self._stratum = 0

    def state(self) -> jnp.ndarray:
        return self._x

    def stratum(self) -> int:
        return self._stratum

    def H(self, x: jnp.ndarray) -> float:
        return float(0.5 * x.T @ self._M @ x)

    def A_operator(self) -> jnp.ndarray:
        """Skew operator for algebra kernels (proxy)."""
        return self._J

    def error(self) -> jnp.ndarray:
        # Track to origin (simple regulation)
        return -self._x[:1]

    def _R(self) -> jnp.ndarray:
        return self._R1 if self._stratum == 0 else self._R2

    def step(self, u: jnp.ndarray, dt: float = 0.01) -> jnp.ndarray:
        gradH = self._M @ self._x
        dx = (self._J - self._R()) @ gradH + self._G @ u
        x_next = self._x + dt * dx
        # Switch stratum when x[0] crosses 0 to exercise frontier logic
        prev = self._x[0]
        self._x = x_next
        if (prev <= 0.0 and self._x[0] > 0.0) or (prev >= 0.0 and self._x[0] < 0.0):
            self._stratum = 1 - self._stratum
        return self._x

    def window(self, size: int):
        """Emit a synthetic window: here we just stack recent-x snapshots."""
        X = np.zeros((size, 2), dtype=float)
        x = np.array(self._x, dtype=float)
        for i in range(size):
            X[i] = x
            x = x + 0.01 * np.array([-(x[0]) + 0.1*np.sin(i/20.0), -0.05*x[1]])
        return X

