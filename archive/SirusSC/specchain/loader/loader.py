"""
Normative Loader automaton with EF+DRO+PR+CBF+Omega receipts, baseline checks, and No-Zeno dwell discipline.
Specs: SCp3 A5.1-A5.4, SCp5 N5-N7 (guard receipts), SCp2 (bottom fail-closed).
"""
from __future__ import annotations

import inspect
from dataclasses import dataclass, field
from typing import Any, Callable, Dict, FrozenSet, Iterable, List, Mapping, Sequence, Set

from ..algebra.q import Q
from ..digest import B3_PREFIX, b3_json, require_blake3
from ..receipts import REQUIRED_SURFACE_FIELDS

Receipt = Dict[str, Any]
BOTTOM_SENTINELS = {Q.BOTTOM, "\u22a5", "⊥"}
GUARD_IDS = {
    "guard_EF": "EF_LOCALITY",
    "guard_DRO": "DRO_SIDECHANNEL",
    "guard_PR": "PR_PROFILE",
    "guard_CBF": "CBF_LEDGER_INTEGRITY",
    "guard_OMEGA": "OMEGA_HORIZON",
}
AXIS_UPDATE_KEYS = (
    "frontier_update",
    "delta_q",
    "axis_updates",
    "writes",
    "writes_axes",
    "axes_written",
)
C_AXIS_LEAK = "C_AXIS_LEAK"
C_BASELINE_RAW_MISSING = "C_BASELINE_RAW_MISSING"
C_BASELINE_SURFACE_DIGEST_MISSING = "C_BASELINE_SURFACE_DIGEST_MISSING"
C_BASELINE_RAW_DIGEST_MISMATCH = "C_BASELINE_RAW_DIGEST_MISMATCH"
C_BASELINE_SURFACE_FIELDS_MISSING = "C_BASELINE_SURFACE_FIELDS_MISSING"
C_BASELINE_SURFACE_FIELDS_EMPTY = "C_BASELINE_SURFACE_FIELDS_EMPTY"
C_BASELINE_ATTESTATION_INVALID = "C_BASELINE_ATTESTATION_INVALID"
C_BASELINE_MANIFEST_INCOMPLETE = "C_BASELINE_MANIFEST_INCOMPLETE"
C_BASELINE_POLICY_DIGEST_MISMATCH = "C_BASELINE_POLICY_DIGEST_MISMATCH"
C_BASELINE_POLICY_SET_EMPTY = "C_BASELINE_POLICY_SET_EMPTY"
C_BASELINE_AXIS_CATALOG_MISMATCH = "C_BASELINE_AXIS_CATALOG_MISMATCH"
C_BASELINE_GUARD_SEQUENCE = "C_BASELINE_GUARD_SEQUENCE"
C_BASELINE_ADAPTER_SCOPE = "C_BASELINE_ADAPTER_SCOPE"
C_BASELINE_AUDIT_PLAN_INVALID = "C_BASELINE_AUDIT_PLAN_INVALID"


@dataclass
class LoaderConfig:
    Tmax: int = 100
    delta_quantum: float = 0.1


@dataclass
class LoaderState:
    q: Q
    rank: List[int] = field(default_factory=lambda: [0, 0, 0, 0, 0])  # r0..r4
    dwell: int = 100
    receipts: List[Receipt] = field(default_factory=list)


Guard = Callable[[Dict[str, Any]], Receipt]
BaselineCheckFn = Callable[["BaselineContext"], "BaselineResult"]


@dataclass(frozen=True)
class BaselineResult:
    payload: Mapping[str, Any]
    verdict: str
    reason_code: str | None = None
    outcome_fields: Mapping[str, Any] | None = None


@dataclass(frozen=True)
class BaselineContext:
    raw_payload: Any | None
    surface_inputs: Mapping[str, Any]
    attestation_receipt: Mapping[str, Any]
    bundle_manifest: Mapping[str, Any]
    policy_contents: Mapping[str, Any]
    policy_digests: Mapping[str, str]
    axis_catalog: Mapping[str, Any]
    axis_catalog_digest: str
    state_axes: FrozenSet[str]
    adapter_axes: Mapping[str, FrozenSet[str]]
    guard_sequence: Sequence[str]
    baseline_inputs: Mapping[str, Any] | None = None


@dataclass(frozen=True)
class BaselineCheck:
    predicate_id: str
    checker: BaselineCheckFn


def no_zeno_step(state: LoaderState, strict_decrease: bool, cfg: LoaderConfig) -> None:
    if not strict_decrease and state.dwell == 0:
        raise RuntimeError("HALT: No-Zeno dwell exhausted")
    if strict_decrease:
        state.dwell = cfg.Tmax
    else:
        state.dwell = max(0, state.dwell - 1)
    receipt = {
        "predicate_id": "NO_ZENO_WINDOW",
        "window_size": cfg.Tmax,
        "post_dwell": state.dwell,
        "strict_decrease": strict_decrease,
    }
    receipt["surface_digest"] = b3_json(receipt)
    state.receipts.append(receipt)


def _build_receipt(
    pid: str,
    payload: Mapping[str, Any],
    checker_fn: Callable[..., Any],
    verdict: str,
    reason_code: str | None = None,
    outcome_fields: Mapping[str, Any] | None = None,
) -> Receipt:
    require_blake3()
    outcome: Dict[str, Any] = {"verdict": verdict}
    if reason_code:
        outcome["reason_code"] = reason_code
    if outcome_fields:
        for key, value in outcome_fields.items():
            outcome[key] = value
    try:
        source = inspect.getsource(checker_fn)
    except (OSError, TypeError):
        source = getattr(checker_fn, "__qualname__", repr(checker_fn))
    receipt = {
        "predicate_id": pid,
        "inputs_digest": b3_json(payload),
        "checker_hash": b3_json({"checker": getattr(checker_fn, "__name__", str(checker_fn)), "source": source}),
        "outcome": outcome,
    }
    receipt["surface_digest"] = b3_json(receipt)
    return receipt


def _build_rejection_cert(
    pid: str,
    reason_code: str,
    counterexample_digest: str | None = None,
) -> Receipt:
    require_blake3()
    cert: Receipt = {
        "kind": "RejectionCert",
        "predicate_id": pid,
        "reason_code": reason_code,
    }
    if counterexample_digest:
        cert["counterexample_digest"] = counterexample_digest
    cert["surface_digest"] = b3_json(cert)
    return cert


def normalize_adapter_axes(
    adapter_axes: Mapping[str, Iterable[str]] | None,
) -> Dict[str, FrozenSet[str]]:
    normalized: Dict[str, FrozenSet[str]] = {}
    if not adapter_axes:
        return normalized
    for key, axes in adapter_axes.items():
        if axes is None:
            normalized[str(key)] = frozenset()
            continue
        normalized[str(key)] = frozenset(str(axis) for axis in axes if isinstance(axis, str))
    return normalized


def _resolve_allowed_axes(
    adapter_axes: Mapping[str, FrozenSet[str]],
    guard_name: str,
    predicate_id: str,
) -> FrozenSet[str] | None:
    if guard_name in adapter_axes:
        return adapter_axes[guard_name]
    if predicate_id in adapter_axes:
        return adapter_axes[predicate_id]
    return None


def _record_axes_from_sequence(seq: Iterable[Any], axes: Set[str]) -> None:
    for item in seq:
        if isinstance(item, str):
            axes.add(str(item))
        elif isinstance(item, Mapping):
            axis = item.get("axis")
            if isinstance(axis, str):
                axes.add(str(axis))
            axes_field = item.get("axes")
            if isinstance(axes_field, (list, tuple, set, frozenset)):
                _record_axes_from_sequence(axes_field, axes)
        elif isinstance(item, (list, tuple, set, frozenset)):
            _record_axes_from_sequence(item, axes)


def _collect_frontier_axes(payload: Mapping[str, Any]) -> Set[str]:
    axes: Set[str] = set()
    if not isinstance(payload, Mapping):
        return axes
    for key in AXIS_UPDATE_KEYS:
        if key not in payload:
            continue
        value = payload[key]
        if isinstance(value, Mapping):
            axes.update(str(k) for k in value.keys() if isinstance(k, str))
        elif isinstance(value, (list, tuple, set, frozenset)):
            _record_axes_from_sequence(value, axes)
        elif isinstance(value, str):
            axes.add(str(value))
    return axes


def _detect_axis_leaks(
    payload: Mapping[str, Any],
    allowed_axes: FrozenSet[str] | None,
    global_axes: FrozenSet[str],
) -> Set[str]:
    writes = _collect_frontier_axes(payload)
    if not writes:
        return set()
    leaks = {axis for axis in writes if axis not in global_axes}
    if allowed_axes is not None:
        leaks.update(axis for axis in writes if axis not in allowed_axes)
    return leaks


def _check_raw_data_digest(ctx: BaselineContext) -> BaselineResult:
    expected = ctx.surface_inputs.get("raw_data_digest")
    if ctx.raw_payload is None:
        return BaselineResult({"expected_digest": expected}, "FAIL", C_BASELINE_RAW_MISSING)
    require_blake3()
    computed = b3_json(ctx.raw_payload)
    payload = {"computed_digest": computed, "expected_digest": expected}
    if not isinstance(expected, str):
        return BaselineResult(payload, "FAIL", C_BASELINE_SURFACE_DIGEST_MISSING)
    if computed != expected:
        return BaselineResult(payload, "FAIL", C_BASELINE_RAW_DIGEST_MISMATCH)
    return BaselineResult(payload, "PASS")


def _check_surface_completeness(ctx: BaselineContext) -> BaselineResult:
    present = {key: key in ctx.surface_inputs for key in REQUIRED_SURFACE_FIELDS}
    missing = [key for key, is_present in present.items() if not is_present]
    payload = {"surface_keys": sorted(ctx.surface_inputs.keys())}
    if missing:
        payload["missing_fields"] = missing
        return BaselineResult(payload, "FAIL", C_BASELINE_SURFACE_FIELDS_MISSING)
    return BaselineResult(payload, "PASS")


def _check_attestation_receipt(ctx: BaselineContext) -> BaselineResult:
    predicate_id = ctx.attestation_receipt.get("predicate_id")
    outcome = ctx.attestation_receipt.get("outcome")
    payload = {
        "predicate_id": predicate_id,
        "has_outcome": isinstance(outcome, Mapping),
    }
    if not isinstance(predicate_id, str) or not predicate_id:
        return BaselineResult(payload, "FAIL", C_BASELINE_ATTESTATION_INVALID)
    if not isinstance(outcome, Mapping):
        return BaselineResult(payload, "FAIL", C_BASELINE_ATTESTATION_INVALID)
    verdict = outcome.get("verdict")
    payload["verdict"] = verdict
    if not isinstance(verdict, str) or verdict not in {"PASS", "FAIL"}:
        return BaselineResult(payload, "FAIL", C_BASELINE_ATTESTATION_INVALID)
    return BaselineResult(payload, "PASS")


def _check_manifest(ctx: BaselineContext) -> BaselineResult:
    run_id = ctx.bundle_manifest.get("run_id")
    version = ctx.bundle_manifest.get("version")
    payload = {"run_id": run_id, "version": version}
    if not isinstance(run_id, str) or not run_id:
        return BaselineResult(payload, "FAIL", C_BASELINE_MANIFEST_INCOMPLETE)
    if not isinstance(version, int):
        return BaselineResult(payload, "FAIL", C_BASELINE_MANIFEST_INCOMPLETE)
    return BaselineResult(payload, "PASS")


def _check_policy_digests(ctx: BaselineContext) -> BaselineResult:
    require_blake3()
    mismatched: Dict[str, Dict[str, str]] = {}
    for path, content in ctx.policy_contents.items():
        actual = b3_json(content)
        declared = ctx.policy_digests.get(path)
        if declared != actual:
            mismatched[path] = {"declared": declared, "actual": actual}
    payload = {"policy_files": sorted(ctx.policy_contents.keys())}
    if mismatched:
        payload["mismatched"] = mismatched
        return BaselineResult(payload, "FAIL", C_BASELINE_POLICY_DIGEST_MISMATCH)
    return BaselineResult(payload, "PASS")


def _check_policy_set(ctx: BaselineContext) -> BaselineResult:
    payload = {"policy_count": len(ctx.policy_digests), "policies": sorted(ctx.policy_digests.keys())}
    if not ctx.policy_digests:
        return BaselineResult(payload, "FAIL", C_BASELINE_POLICY_SET_EMPTY)
    malformed = [path for path, digest in ctx.policy_digests.items() if not isinstance(digest, str) or not digest.startswith(B3_PREFIX)]
    if malformed:
        payload["malformed"] = malformed
        return BaselineResult(payload, "FAIL", C_BASELINE_POLICY_SET_EMPTY)
    return BaselineResult(payload, "PASS")


def _check_axis_catalog(ctx: BaselineContext) -> BaselineResult:
    require_blake3()
    actual_digest = b3_json(ctx.axis_catalog)
    payload = {
        "expected_digest": ctx.axis_catalog_digest,
        "actual_digest": actual_digest,
    }
    axes = ctx.axis_catalog.get("axes") if isinstance(ctx.axis_catalog, Mapping) else {}
    declared_axes: Set[str] = set()
    if isinstance(axes, Mapping):
        for family in ("S", "M"):
            family_axes = axes.get(family)
            if isinstance(family_axes, list):
                declared_axes.update(str(axis) for axis in family_axes)
    payload["declared_axes"] = sorted(declared_axes)
    if actual_digest != ctx.axis_catalog_digest:
        return BaselineResult(payload, "FAIL", C_BASELINE_AXIS_CATALOG_MISMATCH)
    if declared_axes != set(ctx.state_axes):
        payload["state_axes"] = sorted(ctx.state_axes)
        return BaselineResult(payload, "FAIL", C_BASELINE_AXIS_CATALOG_MISMATCH)
    return BaselineResult(payload, "PASS")


def _check_guard_sequence(ctx: BaselineContext) -> BaselineResult:
    expected = ["guard_EF", "guard_DRO", "guard_PR", "guard_CBF", "guard_OMEGA"]
    payload = {"guard_sequence": list(ctx.guard_sequence), "expected": expected}
    if list(ctx.guard_sequence) != expected:
        return BaselineResult(payload, "FAIL", C_BASELINE_GUARD_SEQUENCE)
    return BaselineResult(payload, "PASS")


def _check_adapter_axes(ctx: BaselineContext) -> BaselineResult:
    payload = {"adapter_keys": sorted(ctx.adapter_axes.keys())}
    leaks: Dict[str, List[str]] = {}
    for key, axes in ctx.adapter_axes.items():
        unknown = sorted(axis for axis in axes if axis not in ctx.state_axes)
        if unknown:
            leaks[key] = unknown
    if leaks:
        payload["leaks"] = leaks
        return BaselineResult(payload, "FAIL", C_BASELINE_ADAPTER_SCOPE)
    return BaselineResult(payload, "PASS")


def _check_audit_plan(ctx: BaselineContext) -> BaselineResult:
    audit_plan = ctx.surface_inputs.get("audit_plan")
    payload = {"has_audit_plan": isinstance(audit_plan, Mapping)}
    if not isinstance(audit_plan, Mapping):
        return BaselineResult(payload, "FAIL", C_BASELINE_AUDIT_PLAN_INVALID)
    checks = audit_plan.get("checks")
    payload["checks_type"] = type(checks).__name__
    if not isinstance(checks, list):
        return BaselineResult(payload, "FAIL", C_BASELINE_AUDIT_PLAN_INVALID)
    return BaselineResult(payload, "PASS")


BASELINE_CHECKS: Sequence[BaselineCheck] = (
    BaselineCheck("I1_RAW_DATA_DIGEST", _check_raw_data_digest),
    BaselineCheck("I2_SURFACE_COMPLETENESS", _check_surface_completeness),
    BaselineCheck("I3_ATTESTATION_VALIDITY", _check_attestation_receipt),
    BaselineCheck("I4_MANIFEST_FIELDS", _check_manifest),
    BaselineCheck("I5_POLICY_DIGEST_INTEGRITY", _check_policy_digests),
    BaselineCheck("I6_POLICY_SET_NONEMPTY", _check_policy_set),
    BaselineCheck("I7_AXIS_CATALOG_MATCH", _check_axis_catalog),
    BaselineCheck("I8_GUARD_SEQUENCE_LOCK", _check_guard_sequence),
    BaselineCheck("I9_ADAPTER_AXIS_SCOPE", _check_adapter_axes),
    BaselineCheck("I10_AUDIT_PLAN_FORMAT", _check_audit_plan),
)


def run_baseline_checks(state: LoaderState, ctx: BaselineContext) -> None:
    for check in BASELINE_CHECKS:
        result = check.checker(ctx)
        receipt = _build_receipt(
            check.predicate_id,
            result.payload,
            check.checker,
            result.verdict,
            result.reason_code,
            result.outcome_fields,
        )
        state.receipts.append(receipt)
        if result.verdict != "PASS":
            rejection = _build_rejection_cert(
                check.predicate_id,
                result.reason_code or "UNKNOWN",
                receipt.get("inputs_digest"),
            )
            state.receipts.append(rejection)
            raise RuntimeError(
                f"HALT: Baseline check {check.predicate_id} failed ({result.reason_code or 'UNKNOWN'})."
            )


def run_pipeline(
    guards: List[Guard],
    inputs: List[Dict[str, Any]],
    state: LoaderState,
    cfg: LoaderConfig,
    adapter_axes: Mapping[str, Iterable[str]] | None = None,
) -> None:
    require_blake3()
    assert len(guards) == 5, "Expect 5 guards: EF, DRO, PR, CBF, OMEGA"
    normalized_axes = normalize_adapter_axes(adapter_axes)
    global_axes = frozenset(str(axis) for axis in state.q.axes.all())
    for guard, payload in zip(guards, inputs):
        pid = GUARD_IDS.get(guard.__name__, guard.__name__)
        allowed_axes = _resolve_allowed_axes(normalized_axes, guard.__name__, pid)
        axis_leaks = _detect_axis_leaks(payload, allowed_axes, global_axes)
        if axis_leaks:
            receipt = _build_receipt(
                pid,
                payload,
                guard,
                "FAIL",
                C_AXIS_LEAK,
                {"leaked_axes": sorted(axis_leaks)},
            )
        else:
            receipt = guard(payload)
        state.receipts.append(receipt)
        if receipt.get("predicate_id") != pid:
            raise RuntimeError(
                f"HALT: Guard {guard.__name__} returned mismatched predicate"
            )
        strict = guard.__name__ in ("guard_CBF", "guard_OMEGA")
        if receipt.get("outcome", {}).get("verdict") != "PASS":
            reason_code = receipt.get("outcome", {}).get("reason_code", "UNKNOWN")
            rejection = _build_rejection_cert(pid, reason_code, receipt.get("inputs_digest"))
            state.receipts.append(rejection)
            no_zeno_step(state, strict_decrease=strict, cfg=cfg)
            break
        no_zeno_step(state, strict_decrease=strict, cfg=cfg)


# Example guard kernels (policy-pinned in real system)
def _guard_first_unknown(payload: Dict[str, Any]) -> bool:
    """Return True if any priced coordinate equals the absorbing bottom (fail-closed)."""

    def has_bottom(value: Any) -> bool:
        if isinstance(value, dict):
            return any(has_bottom(child) for child in value.values())
        if isinstance(value, (list, tuple)):
            return any(has_bottom(child) for child in value)
        return value in BOTTOM_SENTINELS

    return has_bottom(payload)


def guard_EF(payload: Dict[str, Any]) -> Receipt:
    pid = GUARD_IDS["guard_EF"]
    if _guard_first_unknown(payload):
        return _build_receipt(pid, payload, guard_EF, "FAIL", "C_UNK_PRICED")
    return _build_receipt(pid, payload, guard_EF, "PASS")


def guard_DRO(payload: Dict[str, Any]) -> Receipt:
    pid = GUARD_IDS["guard_DRO"]
    if _guard_first_unknown(payload):
        return _build_receipt(pid, payload, guard_DRO, "FAIL", "C_UNK_PRICED")
    return _build_receipt(pid, payload, guard_DRO, "PASS")


def guard_PR(payload: Dict[str, Any]) -> Receipt:
    pid = GUARD_IDS["guard_PR"]
    if _guard_first_unknown(payload):
        return _build_receipt(pid, payload, guard_PR, "FAIL", "C_UNK_PRICED")
    return _build_receipt(pid, payload, guard_PR, "PASS")


def guard_CBF(payload: Dict[str, Any]) -> Receipt:
    pid = GUARD_IDS["guard_CBF"]
    if _guard_first_unknown(payload):
        return _build_receipt(pid, payload, guard_CBF, "FAIL", "C_UNK_PRICED")
    return _build_receipt(pid, payload, guard_CBF, "PASS")


def guard_OMEGA(payload: Dict[str, Any]) -> Receipt:
    pid = GUARD_IDS["guard_OMEGA"]
    if _guard_first_unknown(payload):
        return _build_receipt(pid, payload, guard_OMEGA, "FAIL", "C_UNK_PRICED")
    return _build_receipt(pid, payload, guard_OMEGA, "PASS")
