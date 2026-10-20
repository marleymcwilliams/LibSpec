import pytest

from specchain.algebra.q import Axes, Q


def test_q_zero_identities():
    axes = Axes(("s",), ("m",))
    q0 = Q.zero(axes)
    assert q0.q["s"] == 0.0
    assert q0.q["m"] == float("-inf")

    q1 = Q(axes, {"s": 1.5, "m": 2.0})

    joined = q0.hetero_join(q1)
    assert joined.q["s"] == 1.5
    assert joined.q["m"] == 2.0

    sequential = q0.sequential(q1)
    assert sequential.q["m"] == 2.0

    q2 = Q(axes, {"s": 0.5, "m": 3.0})
    seq_combined = q1.sequential(q2)
    assert seq_combined.q["s"] == pytest.approx(2.0)
    assert seq_combined.q["m"] == pytest.approx(5.0)
