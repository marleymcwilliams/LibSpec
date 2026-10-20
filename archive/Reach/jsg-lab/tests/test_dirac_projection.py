import jax.numpy as jnp
from hypothesis import given, strategies as st
from jsg.structure.dirac import build_dirac_projection


@st.composite
def vecs(draw):
    n = draw(st.integers(min_value=2, max_value=4))
    return jnp.eye(n)


@given(vecs())
def test_power_preservation(JB):
    Pi = build_dirac_projection(JB)
    # Idempotent and symmetric projector
    assert jnp.allclose(Pi @ Pi, Pi, atol=1e-6)
    assert jnp.allclose(Pi, Pi.T, atol=1e-6)

