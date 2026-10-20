"""
Receipts, Compliance Bundle, and SurfaceV1 helpers.
Specs: SCp5 N6-N7 (receipt structure), SCp1 A5.4 (canon/v1 json + BLAKE3), SCp1 §5.1 (SurfaceV1 binding).
"""
from __future__ import annotations

from typing import Any, Dict, List, Mapping

from .digest import b3_json

REQUIRED_SURFACE_FIELDS = {
    "raw_data_digest",
    "envlock_id",
    "config_cert",
    "adapter_decls",
    "axis_types",
    "access_policy",
    "audit_plan",
}


def build_guard_receipt_envelope(receipt: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize a receipt and (re)compute its surface digest."""

    payload = dict(receipt)
    payload.pop("hash_alg", None)
    payload.pop("receipt_digest", None)
    canonical_body = dict(payload)
    canonical_body.pop("surface_digest", None)
    payload["surface_digest"] = b3_json(canonical_body)
    return payload


def _bundle_components(
    attestation_receipt: Dict[str, Any],
    guard_receipts: List[Dict[str, Any]],
    omega_receipt: Dict[str, Any],
    bundle_manifest: Mapping[str, Any],
    axis_catalog_digest: str,
    policy_digests: Mapping[str, str],
) -> tuple[Dict[str, Any], Dict[str, Any], List[Dict[str, Any]], Dict[str, Any], Dict[str, Any]]:
    attestation_envelope = build_guard_receipt_envelope(attestation_receipt)
    guard_envelopes = [build_guard_receipt_envelope(r) for r in guard_receipts]
    omega_envelope = build_guard_receipt_envelope(omega_receipt)
    manifest_dict = dict(bundle_manifest)
    policy_digest_map = dict(policy_digests)
    bundle_body = {
        "attestation_receipt": attestation_envelope,
        "guard_receipts": guard_envelopes,
        "omega_receipt": omega_envelope,
        "bundle_manifest": manifest_dict,
        "axis_catalog_digest": axis_catalog_digest,
        "policy_digests": policy_digest_map,
    }
    return bundle_body, attestation_envelope, guard_envelopes, omega_envelope, manifest_dict


def build_compliance_bundle(
    attestation_receipt: Dict[str, Any],
    guard_receipts: List[Dict[str, Any]],
    omega_receipt: Dict[str, Any],
    bundle_manifest: Mapping[str, Any],
    axis_catalog_digest: str,
    policy_digests: Mapping[str, str],
) -> Dict[str, Any]:
    bundle_body, *_ = _bundle_components(
        attestation_receipt,
        guard_receipts,
        omega_receipt,
        bundle_manifest,
        axis_catalog_digest,
        policy_digests,
    )
    bundle_digest = b3_json(bundle_body)
    compliance_bundle = dict(bundle_body)
    compliance_bundle["bundle_digest"] = bundle_digest
    return compliance_bundle


def build_surface_v1(surface_inputs: Mapping[str, Any], evidence_bundle: Dict[str, Any]) -> Dict[str, Any]:
    missing = [key for key in REQUIRED_SURFACE_FIELDS if key not in surface_inputs]
    if missing:
        raise ValueError(
            f"SurfaceV1 inputs missing required fields: {', '.join(sorted(missing))}"
        )
    surface = {k: v for k, v in surface_inputs.items() if k != "evidence_bundle"}
    surface.setdefault("surface_version", "SurfaceV1")
    surface["evidence_bundle"] = evidence_bundle
    return surface


def build_surface_artifacts(
    attestation_receipt: Dict[str, Any],
    guard_receipts: List[Dict[str, Any]],
    omega_receipt: Dict[str, Any],
    bundle_manifest: Mapping[str, Any],
    axis_catalog_digest: str,
    policy_digests: Mapping[str, str],
    surface_inputs: Mapping[str, Any],
) -> Dict[str, Any]:
    (
        bundle_body,
        attestation_envelope,
        guard_envelopes,
        omega_envelope,
        manifest_dict,
    ) = _bundle_components(
        attestation_receipt,
        guard_receipts,
        omega_receipt,
        bundle_manifest,
        axis_catalog_digest,
        policy_digests,
    )
    bundle_digest = b3_json(bundle_body)
    compliance_bundle = dict(bundle_body)
    compliance_bundle["bundle_digest"] = bundle_digest
    evidence_bundle = {
        "compliance_bundle_digest": bundle_digest,
        "attestation_receipt_digest": attestation_envelope["surface_digest"],
        "guard_receipt_digests": [env["surface_digest"] for env in guard_envelopes],
        "omega_receipt_digest": omega_envelope["surface_digest"],
        "bundle_manifest_digest": b3_json(manifest_dict),
        "axis_catalog_digest": axis_catalog_digest,
        "policy_digests": dict(policy_digests),
    }
    surface_v1 = build_surface_v1(surface_inputs, evidence_bundle)
    proof_surface = b3_json(surface_v1)
    return {
        "compliance_bundle": compliance_bundle,
        "surface_v1": surface_v1,
        "proof_surface": proof_surface,
        "compliance_bundle_digest": bundle_digest,
    }
