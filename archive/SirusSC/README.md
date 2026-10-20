# SpecChain Reference Build (Parts 1–5)

This repository is a **reference implementation scaffold** of the SpecChain normative stack described in the attached specs.
It provides:
- Canonical JSON encoder `canon/v1`
- BLAKE3-256 digest binding and ledger block type
- Acceptance algebra **Q** (S/M axes) and the uncertainty lift **Q′**
- Frontier debit `Δ_fr` interfaces with safe upper-bound placeholders
- Normative Loader automaton with No-Zeno dwell discipline and uniform receipts
- TailContract interfaces and a concrete I11 Contraction example
- Canonical JSON Schemas for receipts/certificates
- Example policy, axis catalog, budgets, and a tiny replayable run
- CLI and tests

> **Spec citations:** See inline docstrings and comments annotated with `SCp1…SCp5` section references.

## Quick start (Python 3.11+)

```bash
python -m venv .venv && source .venv/bin/activate
pip install -U pip
pip install blake3 pydantic jsonschema click
pip install pytest
# Run tests
pytest -q
# Try a tiny run
python -m specchain.cli run examples/minimal_run.json
```

> If `blake3` is unavailable, digest tests will be skipped with a clear message. Install `blake3` to enable hashing.

## Layout

- `specchain/canon.py` – canon/v1 encoder (sorted keys, minimal decimals, UTF‑8, no whitespace)
- `specchain/digest.py` – BLAKE3-256 digests
- `specchain/ledger.py` – Block header/payload, `H(b)=BLAKE3-256(hbytes||pbytes)`
- `specchain/algebra/q.py` – Q product, ⊙ (hetero-join), ∧ (sequential), ⊥ ledgering
- `specchain/algebra/q_prime.py` – uncertainty lift Q′ carriers (intervals / subGaussian placeholders)
- `specchain/frontier/debit.py` – Δ_fr interface + safe upper-bounds (greedy/DP/relax-and-round stubs)
- `specchain/loader/loader.py` – Normative Loader with guards EF→DRO→PR→CBF→Ω and No‑Zeno
- `specchain/tail/` – TailContract interface + I11 Contraction instance
- `schemas/` – JSON Schemas (RetuneCert, RejectionCert, TailReceipt, AttestationReceipt, DwellReceipt, CBF_AUDIT, OmegaReceipt, ComplianceBundle)
- `policy/` – example axis catalog + budgets
- `examples/` – tiny run files and witness stubs
- `tests/` – unit tests targeting canonicalization, ledger, loader windows, and receipts

This is **not** a full production system; it is a faithful scaffold aligned with the normative text to enable
rapid completion.
