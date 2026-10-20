# JSG Docs — Map of Maps

This site reframes the math as contract checklists. Each claim (C-1…C-10) maps to a section in the papers and corresponding evidence artifacts.

Claims map
- C-1: Calculus — section `sec:calc2` → artifacts: `frontier-ledger/`, `pr-witness/`
- C-2: Stochastic — section `sec:stoch2` → artifacts: `automata-evidence/`
- C-3: Closure — section `sec:closure2` → artifacts: `dro-kkt/`
- C-4: Entropy — section `sec:entropy2` → artifacts: `pr-witness/`
- C-5: Control — section `sec:ctrl2` → artifacts: `transport-pack/`
- C-6: Kernels — section `sec:kernels2` → artifacts: `frontier-ledger/`
- C-7: Advanced — section `sec:adv-structures2` → artifacts: `replay-pack/`
- C-8: Statistics — section `sec:stats2` → artifacts: `coverage/`

How to audit
- Find the claim in papers Part II (A/B) by label.
- Inspect linked artifacts in `artifacts/`.
- Run `make test-accept` to assert presence of required evidence.

See topic pages for details:
- Geometry
- Sensing
- DRO
- Control
- Reporting
- Audit Guide
- Evidence Cookbook
