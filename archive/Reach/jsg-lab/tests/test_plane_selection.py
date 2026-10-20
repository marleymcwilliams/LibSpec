import jax.numpy as jnp
from jsg.algebra.plane_selection import select_planes


def test_plane_selection_shapes():
    A = jnp.array([[0.0, -1.0], [1.0, 0.0]])
    U, V, gaps = select_planes(A, 1e-4)
    assert U.shape[0] == 2
    assert V.shape[0] == 2

