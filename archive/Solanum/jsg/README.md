JSG Repository

This repository hosts the LaTeX sources for Part I and Part II (A/B) of the project, machine-readable registries referenced by the text, and reproducible artifacts that serve as auditable evidence.

Quick pointers:
- Idea lens: see `docs/index.md` and topic pages under `docs/`.
- Paper sources: `papers/part2/JSG_II_A.tex` and `papers/part2/JSG_II_B.tex`.
- Shared LaTeX assets: `papers/common/`.
- Registries (contracts cited in text): `registries/` with JSON Schemas in `registries/schemas/`.
- Evidence artifacts: `artifacts/` (immutable, window-addressed names).
- Small runnable benchmarks: `benchmarks/`.
- Tools and checks: `tools/`.
- CI workflows: `.github/workflows/`.

Getting started
- Build PDFs: `make build` (outputs in `build/`).
- Verify acceptance artifacts: `make test-accept`.
- Validate registries: `python -m tools.validate_registries registries registries/schemas`.
- Serve docs locally: `mkdocs serve -f docs/mkdocs.yml`.

Conventions
- Stable section labels: `sec:calc2`, etc.; figures/tables: `fig:calc2-*`, `tbl:*`.
- Cross-part references: `\input{../common/xref.tex}` and `\xref{sec:calc2}`.
- One `.bib` in `papers/common/refs.bib`.
- Artifacts under `artifacts/` are immutable once published and addressed by window id.

See `BUSY.md` for a one-page orientation and `CONTRIBUTING.md` for contribution guidelines.
