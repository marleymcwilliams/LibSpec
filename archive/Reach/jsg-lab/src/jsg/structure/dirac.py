from __future__ import annotations
import jax.numpy as jnp
from jax.numpy.linalg import svd


def build_dirac_projection(J_basis: jnp.ndarray) -> jnp.ndarray:
    """Build energetic orthogonal projector Π from basis of maximally isotropic subspace."""
    # Constraint operator A_i synthesized from J_basis (placeholder)
    Ai = J_basis.T @ J_basis
    U, s, Vt = svd(Ai, full_matrices=False)
    tol = 1e-8
    r = jnp.sum(s > tol)
    X_kernel = Vt[r:, :].T  # basis for kernel
    X_row = U[:, :r]  # row space basis (annihilator)
    D = jnp.concatenate([X_kernel, X_row], axis=1)
    # Orthogonal projector Π = B (B^T B)^{-1} B^T with B orthonormal → simplify to B B^T
    B, _ = jnp.linalg.qr(D)
    return B @ B.T

