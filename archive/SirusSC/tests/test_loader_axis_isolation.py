import pytest

try:
    import blake3  # type: ignore
except ImportError:  # pragma: no cover
    blake3 = None

from specchain.algebra.q import Axes, Q
from specchain.loader.loader import (
    C_AXIS_LEAK,
    LoaderConfig,
    LoaderState,
    guard_CBF,
    guard_DRO,
    guard_EF,
    guard_OMEGA,
    guard_PR,
    run_pipeline,
)

pytestmark = pytest.mark.skipif(blake3 is None, reason="requires blake3 for hashing")


def _pipeline_receipts(payloads, adapter_axes):
    axes = Axes(("energy",), ("risk",))
    state = LoaderState(q=Q.zero(axes), dwell=5)
    cfg = LoaderConfig(Tmax=5, delta_quantum=0.1)
    guards = [guard_EF, guard_DRO, guard_PR, guard_CBF, guard_OMEGA]
    run_pipeline(guards, payloads, state, cfg, adapter_axes=adapter_axes)
    return state.receipts


def test_axis_isolation_pass_through():
    payloads = [
        {"frontier_update": {"energy": 1.0}},
        {},
        {},
        {},
        {},
    ]
    adapter_axes = {"guard_EF": {"energy"}}

    receipts = _pipeline_receipts(payloads, adapter_axes)
    ef_receipt = next(r for r in receipts if r.get("predicate_id") == "EF_LOCALITY")

    assert ef_receipt["outcome"]["verdict"] == "PASS"
    assert "leaked_axes" not in ef_receipt["outcome"]
    assert any(r.get("predicate_id") == "OMEGA_HORIZON" for r in receipts)


def test_axis_isolation_rejects_leak():
    payloads = [
        {"frontier_update": {"risk": 0.1}},
        {},
        {},
        {},
        {},
    ]
    adapter_axes = {"guard_EF": {"energy"}}

    receipts = _pipeline_receipts(payloads, adapter_axes)
    ef_receipt = next(r for r in receipts if r.get("predicate_id") == "EF_LOCALITY")

    assert ef_receipt["outcome"]["verdict"] == "FAIL"
    assert ef_receipt["outcome"]["reason_code"] == C_AXIS_LEAK
    assert ef_receipt["outcome"]["leaked_axes"] == ["risk"]

    rejection = next(r for r in receipts if r.get("kind") == "RejectionCert")
    assert rejection["reason_code"] == C_AXIS_LEAK
    assert all(r.get("predicate_id") != "OMEGA_HORIZON" for r in receipts)
