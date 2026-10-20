import json
from typing import Any, Dict, Mapping, Sequence, Set

import click

from .loader.loader import (
    BaselineContext,
    GUARD_IDS,
    LoaderConfig,
    LoaderState,
    guard_CBF,
    guard_DRO,
    guard_EF,
    guard_OMEGA,
    guard_PR,
    normalize_adapter_axes,
    run_baseline_checks,
    run_pipeline,
)
from .algebra.q import Axes, Q
from .digest import b3_json, blake3_available, require_blake3
from .receipts import build_surface_artifacts


@click.group()
def cli():
    """SpecChain reference CLI."""


@cli.command()
@click.argument("run_json", type=click.Path(exists=True))
def run(run_json: str) -> None:
    if not blake3_available():
        raise click.ClickException("BLAKE3 required. Install `pip install blake3` before running.")
    with open(run_json, "r", encoding="utf-8") as fh:
        data = json.load(fh)

    axes = Axes(tuple(data["axes"]["S"]), tuple(data["axes"]["M"]))
    q0 = Q.zero(axes)
    state = LoaderState(q=q0, dwell=100)
    cfg = LoaderConfig(Tmax=10, delta_quantum=0.1)
    guards = [guard_EF, guard_DRO, guard_PR, guard_CBF, guard_OMEGA]

    surface_inputs = data.get("surface_inputs")
    if not isinstance(surface_inputs, dict):
        raise click.ClickException("run manifest must include surface_inputs mapping for SurfaceV1")

    attestation_receipt = data.get("attestation_receipt")
    bundle_manifest = data.get("bundle_manifest")
    if not attestation_receipt or not bundle_manifest:
        raise click.ClickException("run manifest must include attestation_receipt and bundle_manifest")

    baseline_inputs = data.get("baseline_inputs", {})
    if baseline_inputs is None:
        baseline_inputs = {}
    policy_files = data.get("policy_files", ["policy/budgets.json"])

    known_axes = set(axes.all())
    adapter_axes: Dict[str, Set[str]] = {}
    for decl_map in (
        _parse_adapter_decls(data.get("adapter_decls"), known_axes),
        _parse_adapter_decls(surface_inputs.get("adapter_decls"), known_axes),
    ):
        for key, declared_axes in decl_map.items():
            adapter_axes.setdefault(key, set()).update(declared_axes)
    normalized_adapter_axes = normalize_adapter_axes(adapter_axes if adapter_axes else None)

    require_blake3()
    axis_catalog = _load_json("policy/axis_catalog.json")
    axis_catalog_digest = b3_json(axis_catalog)
    policy_contents = {path: _load_json(path) for path in policy_files}
    policy_digests = {path: b3_json(content) for path, content in policy_contents.items()}

    baseline_ctx = BaselineContext(
        raw_payload=baseline_inputs.get("raw_data_payload"),
        surface_inputs=surface_inputs,
        attestation_receipt=attestation_receipt,
        bundle_manifest=bundle_manifest,
        policy_contents=policy_contents,
        policy_digests=policy_digests,
        axis_catalog=axis_catalog,
        axis_catalog_digest=axis_catalog_digest,
        state_axes=frozenset(str(axis) for axis in axes.all()),
        adapter_axes=normalized_adapter_axes,
        guard_sequence=[guard.__name__ for guard in guards],
        baseline_inputs=baseline_inputs if isinstance(baseline_inputs, dict) else {},
    )

    try:
        run_baseline_checks(state, baseline_ctx)
    except RuntimeError as exc:
        raise click.ClickException(str(exc)) from exc

    run_pipeline(
        guards,
        data["guards_inputs"],
        state,
        cfg,
        adapter_axes=normalized_adapter_axes if normalized_adapter_axes else None,
    )

    guard_predicates = [GUARD_IDS[name] for name in ("guard_EF", "guard_DRO", "guard_PR", "guard_CBF")]
    guard_receipts = [r for r in state.receipts if r.get("predicate_id") in guard_predicates]
    omega_receipt_candidates = [r for r in state.receipts if r.get("predicate_id") == GUARD_IDS["guard_OMEGA"]]
    if not omega_receipt_candidates:
        raise click.ClickException("Omega-stage receipt missing from pipeline run")
    omega_receipt = omega_receipt_candidates[-1]

    try:
        artifacts = build_surface_artifacts(
            attestation_receipt=attestation_receipt,
            guard_receipts=guard_receipts,
            omega_receipt=omega_receipt,
            bundle_manifest=bundle_manifest,
            axis_catalog_digest=axis_catalog_digest,
            policy_digests=policy_digests,
            surface_inputs=surface_inputs,
        )
    except ValueError as exc:  # surface inputs validation failures
        raise click.ClickException(str(exc)) from exc

    output = {
        "receipts": state.receipts,
        "surface_v1": artifacts["surface_v1"],
        "compliance_bundle": artifacts["compliance_bundle"],
        "compliance_bundle_digest": artifacts["compliance_bundle_digest"],
        "proof_surface": artifacts["proof_surface"],
    }
    click.echo(json.dumps(output, indent=2))


def _parse_adapter_decls(
    raw: Any,
    known_axes: Set[str],
) -> Dict[str, Set[str]]:
    if raw is None:
        return {}
    if not isinstance(raw, Sequence) or isinstance(raw, (str, bytes)):
        raise click.ClickException("adapter_decls must be a list of objects")
    result: Dict[str, Set[str]] = {}
    for idx, entry in enumerate(raw):
        if not isinstance(entry, Mapping):
            raise click.ClickException(f"adapter_decls[{idx}] must be an object")
        axes = _coerce_axes(entry.get("writes"))
        axes |= _coerce_axes(entry.get("axes"))
        axes |= _coerce_axes(entry.get("S"))
        axes |= _coerce_axes(entry.get("M"))
        axes |= _coerce_axes(entry.get("allow"))
        axes |= _coerce_axes(entry.get("allow_axes"))
        unknown = [axis for axis in axes if axis not in known_axes]
        if unknown:
            joined = ", ".join(sorted(set(unknown)))
            raise click.ClickException(
                f"adapter_decls[{idx}] references unknown axis(es): {joined}"
            )
        identifiers: Set[str] = set()
        for field in ("guard", "guard_name", "name"):
            value = entry.get(field)
            if isinstance(value, str) and value:
                identifiers.add(value)
        stage = entry.get("stage")
        if isinstance(stage, str) and stage:
            stage_key = stage.strip()
            if stage_key:
                upper_stage = stage_key.upper()
                identifiers.add(stage_key)
                identifiers.add(upper_stage)
                if not upper_stage.startswith("GUARD_"):
                    identifiers.add(f"guard_{upper_stage}")
        predicate_id = entry.get("predicate_id")
        if isinstance(predicate_id, str) and predicate_id:
            identifiers.add(predicate_id)
        if not identifiers:
            raise click.ClickException(
                f"adapter_decls[{idx}] missing guard/stage/predicate identifier"
            )
        for ident in identifiers:
            bucket = result.setdefault(ident, set())
            bucket.update(axes)
    return result


def _coerce_axes(value: Any) -> Set[str]:
    axes: Set[str] = set()
    if value is None:
        return axes
    if isinstance(value, str):
        axes.add(value)
        return axes
    if isinstance(value, Mapping):
        for item in value.values():
            axes.update(_coerce_axes(item))
        return axes
    if isinstance(value, (list, tuple, set, frozenset)):
        for item in value:
            axes.update(_coerce_axes(item))
    return axes


def _load_json(path: str):
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


if __name__ == "__main__":
    cli()
