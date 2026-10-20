import jax.numpy as jnp
from jsg.control.oustaloup import oustaloup_ss, ControllerState


def test_controller_step():
    sys = oustaloup_ss(0.85, 2, (0.5, 8.0), None)
    ctrl = ControllerState()
    y = ctrl.step(sys, jnp.array([[0.0]]))
    assert y.shape == (1, 1)

