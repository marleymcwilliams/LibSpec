from __future__ import annotations
import jax.numpy as jnp


def mixed_wedge(a: jnp.ndarray, b: jnp.ndarray) -> jnp.ndarray:
    """Pragmatic mixed wedge on arrays (stratumwise)."""
    return jnp.tensordot(a, b, axes=0) - jnp.tensordot(b, a, axes=0)  # placeholder


def interior_contraction(v: jnp.ndarray, form: jnp.ndarray) -> jnp.ndarray:
    """ι_v form."""
    # TODO: implement contraction compatible with chosen array layout
    return form


def schouten_nijenhuis(P: jnp.ndarray, Q: jnp.ndarray) -> jnp.ndarray:
    """SN bracket (approximate, stratumwise)."""
    # TODO: implement bracket needed by kernels
    return P - Q

