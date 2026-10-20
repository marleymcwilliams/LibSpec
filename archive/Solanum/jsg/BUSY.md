Start Here (BUSY)

Map claims to evidence fast:

- Idea: read `docs/index.md` for the C-1…C-10 map.
- Claim text: jump to the section label inside
  - `papers/part2/JSG_II_A.tex` or `papers/part2/JSG_II_B.tex`, e.g. §`sec:calc2`.
- Evidence: inspect `artifacts/` folders referenced by the claim
  - `frontier-ledger/`, `pr-witness/`, `dro-kkt/`, `automata-evidence/`, `transport-pack/`.
- Registry contract: see `registries/` JSON and their schemas under `registries/schemas/`.
- Acceptance check: `make test-accept`.

Quickstart
1. Skim the idea → `docs/index.md`
2. Open the section → e.g., `papers/part2/JSG_II_A.tex` §`sec:calc2`
3. Check evidence → `artifacts/frontier-ledger/` & `artifacts/dro-kkt/`
4. Verify acceptance → `make test-accept`
5. Build PDFs → `make build`

Notes
- Use stable labels: `sec:calc2` and `fig:calc2-*`, `tbl:*`.
- Cross-part refs: `\input{../common/xref.tex}` and `\xref{sec:calc2}`.
- Artifacts are immutable and addressed by window ids: `win-YYYYMMDDThhmmssZ_*`.
