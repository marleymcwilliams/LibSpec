import jax.numpy as jnp
from jsg.structure.shape_derivatives import fd_grad_with_freeze


def f(theta, sampler):
    return jnp.sum(theta)


def test_fd_grad_runs():
    g, info = fd_grad_with_freeze(f, jnp.zeros(3), None, 0.0)
    assert g.shape == (3,)

