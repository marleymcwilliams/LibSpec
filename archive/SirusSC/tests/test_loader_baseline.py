import pytest

try:
    import blake3  # type: ignore
except ImportError:  # pragma: no cover
    blake3 = None

from specchain.algebra.q import Axes, Q
from specchain.digest import b3_json
from specchain.loader.loader import (
    BaselineContext,
    C_BASELINE_RAW_DIGEST_MISMATCH,
    LoaderState,
    normalize_adapter_axes,
    run_baseline_checks,
)

pytestmark = pytest.mark.skipif(blake3 is None, reason="requires blake3 for hashing")


def _make_state_and_context(raw_payload, surface_inputs_overrides=None):
    axes = Axes(("energy",), ("risk",))
    state = LoaderState(q=Q.zero(axes), dwell=5)
    surface_inputs = {
        "raw_data_digest": b3_json(raw_payload),
        "envlock_id": "ENVLOCK-TEST",
        "config_cert": {"kind": "ConfigCertStub", "version": 1},
        "adapter_decls": [],
        "axis_types": {"energy": "continuous", "risk": "continuous"},
        "access_policy": {"classification": "public"},
        "audit_plan": {"version": 1, "checks": []},
    }
    if surface_inputs_overrides:
        surface_inputs.update(surface_inputs_overrides)
    attestation_receipt = {"predicate_id": "ATTESTATION_STUB", "outcome": {"verdict": "PASS"}}
    bundle_manifest = {"run_id": "baseline-test", "version": 1}
    policy_contents = {"policy/budgets.json": {"energy": 100.0, "risk": 0.5}}
    policy_digests = {path: b3_json(content) for path, content in policy_contents.items()}
    axis_catalog = {"axes": {"S": ["energy"], "M": ["risk"]}}
    axis_catalog_digest = b3_json(axis_catalog)
    adapter_axes = normalize_adapter_axes({"guard_EF": {"energy"}})
    ctx = BaselineContext(
        raw_payload=raw_payload,
        surface_inputs=surface_inputs,
        attestation_receipt=attestation_receipt,
        bundle_manifest=bundle_manifest,
        policy_contents=policy_contents,
        policy_digests=policy_digests,
        axis_catalog=axis_catalog,
        axis_catalog_digest=axis_catalog_digest,
        state_axes=frozenset(str(axis) for axis in axes.all()),
        adapter_axes=adapter_axes,
        guard_sequence=["guard_EF", "guard_DRO", "guard_PR", "guard_CBF", "guard_OMEGA"],
        baseline_inputs={"raw_data_payload": raw_payload},
    )
    return state, ctx


def test_run_baseline_checks_pass():
    raw_payload = {"records": []}
    state, ctx = _make_state_and_context(raw_payload)

    run_baseline_checks(state, ctx)

    predicate_ids = [r["predicate_id"] for r in state.receipts]
    assert predicate_ids[:10] == [
        "I1_RAW_DATA_DIGEST",
        "I2_SURFACE_COMPLETENESS",
        "I3_ATTESTATION_VALIDITY",
        "I4_MANIFEST_FIELDS",
        "I5_POLICY_DIGEST_INTEGRITY",
        "I6_POLICY_SET_NONEMPTY",
        "I7_AXIS_CATALOG_MATCH",
        "I8_GUARD_SEQUENCE_LOCK",
        "I9_ADAPTER_AXIS_SCOPE",
        "I10_AUDIT_PLAN_FORMAT",
    ]
    assert all(r["outcome"]["verdict"] == "PASS" for r in state.receipts[:10])


def test_run_baseline_checks_detects_raw_mismatch():
    raw_payload = {"records": []}
    state, ctx = _make_state_and_context(
        raw_payload,
        surface_inputs_overrides={"raw_data_digest": "b3:deadbeef"},
    )

    with pytest.raises(RuntimeError) as exc:
        run_baseline_checks(state, ctx)

    assert "I1_RAW_DATA_DIGEST" in str(exc.value)
    failure_receipt = state.receipts[0]
    assert failure_receipt["predicate_id"] == "I1_RAW_DATA_DIGEST"
    assert failure_receipt["outcome"]["verdict"] == "FAIL"
    assert failure_receipt["outcome"]["reason_code"] == C_BASELINE_RAW_DIGEST_MISMATCH
    rejection = state.receipts[1]
    assert rejection["kind"] == "RejectionCert"
    assert rejection["reason_code"] == C_BASELINE_RAW_DIGEST_MISMATCH
