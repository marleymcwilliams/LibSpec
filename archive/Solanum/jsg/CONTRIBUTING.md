Contributing

Thank you for helping improve JSG. This guide explains how to propose changes to papers, registries, tools, and docs.

Workflow
- Create a feature branch and open a Draft PR early.
- Link changes to a claim (C-1…C-10) and reference exact section labels.
- Keep artifacts immutable; add new window-stamped files rather than editing existing ones.
- Update registries and re-run schema validation.
- Update docs pages and `docs/index.md` map if claim scope changes.

Commit/PR hygiene
- Commits: conventional style is welcome (feat:, fix:, docs:, refactor:, chore:).
- PR description must answer:
  - Which claim (C-#)?
  - Which artifact updated? Provide paths under `artifacts/`.
  - Did registry hashes change?
  - Screenshots/PNGs added under `artifacts/` not `papers/`.
- Reference exact labels (e.g., `sec:calc2`, `fig:ctrl2-holonomy`).

Local checks
- Build PDFs: `make build`
- Validate registries: `python -m tools.validate_registries`
- Acceptance gates: `make test-accept`
- Docs build: `mkdocs build -f docs/mkdocs.yml`

Registries
- JSON files under `registries/` are first-class artifacts.
- Cite by file name and include hash in the paper.
- Schemas live under `registries/schemas/`; CI validates on each PR.

Artifacts
- Address by window ids: `win-YYYYMMDDThhmmssZ_*`.
- Store outputs in `artifacts/` and keep them immutable after publish.

LaTeX conventions
- Stable labels: section `sec:*`, figure `fig:*`, table `tbl:*`.
- Cross-part references: include `../common/xref.tex` and use `\xref{...}`.
- One bib: `papers/common/refs.bib`; CI fails on duplicate keys.

Code style
- Python: format with `black --line-length 100` (CI checks).
- JSON: pretty-printed, keys stable, include file-level `hash` fields where applicable.

CI
- PRs run LaTeX build, lint, registry validation, acceptance checks, and docs build.
