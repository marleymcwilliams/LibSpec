# JSG / SIRUS Master Guide (Skeleton)

Sep 29, 2026 · @Marley McWilliams

## Purpose and reading rules

This guide is the single canon for JSG I–V, SpecChain, the SIRUS spec, the Navier–Stokes program, and the drafts. Every component carries a tag that says what can justify it.

1. **One home per concept.** Each term is defined once, in the glossary. Other documents link to it and never restate it.
2. **Every component names its justification:** provable in Lean now, provable with analysis, checked per certificate, tested in CI, open mathematics, or a declared value (see the layer map).
3. **Conformance is not correctness.** CI shows the work conforms to the spec. Lean shows the spec's internal lemmas hold. Neither shows that a threshold, a model, or a value is right; that stays a signed human decision.
4. **Retired terms stay as aliases.** Old documents keep reading correctly, and new text uses only canonical terms.

## Where each part lives

The guide's parts have files of their own, and [README.md](README.md) maps the whole repository.

| Part | File |
| --- | --- |
| Canonical glossary, and the unified core objects (v2) | [GLOSSARY.md](GLOSSARY.md) |
| Layer map, and what each statements version adds | [LAYER_MAP.md](LAYER_MAP.md) |
| Known defects and proposed fixes | [DEFECTS.md](DEFECTS.md) |
| Corpus lineage, and the source map | [SOURCES.md](SOURCES.md) |
| The roadmap, with this guide's checklist | [ROADMAP.md](ROADMAP.md) |

Its Lean 4 statement stubs became [`lean/JSG/Defs.lean`](../lean/JSG/Defs.lean) and [`lean/JSG/Statements.lean`](../lean/JSG/Statements.lean) in Phase 2, which are now the only copy.
