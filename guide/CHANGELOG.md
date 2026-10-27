# Changelog

Every statements version after `statements-v1` records here whether it tightens or weakens the statements, and so does every change in between to a file the statements check covers: `lean/JSG/Defs.lean`, `lean/JSG/Statements.lean`, their project imports, `lean/lean-toolchain`, `lean/lake-manifest.json` and `lean/lakefile.toml`, so Lean and Mathlib upgrades count too. A weakening also needs a signed decision (`guide/decisions/RAILS.md`).

## statements-v2

Tightens: it only adds statements. Seven theorems for Milestone 2, and the definitions they use, go in new sections 8–11 of `lean/JSG/Defs.lean` and `lean/JSG/Statements.lean`. No `statements-v1` definition or statement changes, so the eight Milestone 1 proofs stand as they are.

- **Leases** (PDE I4b): `lease_breach`, `lease_complete`.
- **Typed obligations** (JSG V §3): `pass_sound`, `pass_complete`.
- **A concrete Loader** whose invariant is L1–L10, SCp3's ten baseline checks: `LoaderStep.inv_step`, `LoaderStep.progress`.
- **Residual threading** through any number of stages, an overspent stage included: `threads_spec` (QUEUE.md, Q5).

## statements-v1

First freeze: core v2, 16 theorems.
