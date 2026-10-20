JSG Part II — Authoring Guide and Build Notes

Overview

- Part II mirrors Part I’s modular structure with stable labels and shared Tenets.
- A/B wrappers are generated from a manifest so you can re-slice without duplication.
- Cross-part composition lets you assemble arguments across Parts 1–N without redundancy.

Directory Layout

```
papers/part2/
  JSG_II_A.tex            # Generated wrapper (A)
  JSG_II_B.tex            # Generated wrapper (B)
  manifest.json           # Declarative A/B section includes
  sections/               # One .tex file per section (modular content)
    calc2.tex
    stoch2.tex
    closure2.tex
    entropy2.tex
    ctrl2.tex
    kernels2.tex
    adv-structures2.tex
    stats2.tex
```

Files of Interest

- `sections/`: each file begins with `\section{...}\label{sec:*2}`.
- `manifest.json`: declares A/B wrapper includes.
- `JSG_II_A.tex`, `JSG_II_B.tex`: generated; do not hand-edit (regenerate instead).

Conventions

- Labels: Part II uses `*2` suffix (e.g., `sec:calc2`) to avoid collisions with Part I (`*1`).
- Cross-part references: use `\xref{sec:...}`; it prints a portable companion reference.
- Shared Tenets + Symbol Registry live in `papers/common/tenets.tex` and are included once per document.

Common Tasks

- Regenerate wrappers from manifest:
  - `python jsg/tools/generate_wrappers.py --part part2`
  - or `make build` (generator runs before LaTeX builds)
- Compose an ad‑hoc document (within Part II):
  - `python jsg/tools/generate_wrappers.py --part part2 --include calc2,ctrl2 --title "JSG Part II (Custom)" --out jsg/papers/part2/JSG_II_CUSTOM.tex`
- Compose an ad‑hoc document (cross‑part):
  - `python jsg/tools/generate_wrappers.py --compose part1:calc1,part2:ctrl2 --title "JSG Composed" --out jsg/papers/composed/JSG_COMPOSED.tex`
- Add a new section to Part II:
  - Create `sections/<name>2.tex` starting with `\section{Title}\label{sec:<name>2}`
  - Add it to the relevant wrapper via `manifest.json`; regenerate wrappers
- Add bibliography entries:
  - Edit `papers/common/refs.bib`; all documents include it via biblatex

Build Instructions

- Preferred: `make build` (builds Part 1 skeleton + A/B and Part 2 A/B)
- Dependencies: LaTeX with `latexmk` (Perl), `biblatex` (backend=bibtex). On Windows with MiKTeX, ensure Perl is installed for latexmk.
- Fallback (without latexmk):
  1. `pdflatex -halt-on-error -interaction=nonstopmode JSG_II_A.tex` (or `JSG_II_B.tex`)
  2. `bibtex JSG_II_A` (or `JSG_II_B`)
  3. `pdflatex` (twice)

Agent Context (for tooling / LLMs)

- Generate a compact pack with Tenets, Symbol Registry, and section maps across Parts 1–2:
  - `make agent-context` or `python jsg/tools/agent_context.py`
  - Output: `jsg/AGENT_CONTEXT.md`

Troubleshooting

- latexmk: "script engine 'perl.exe' not found": install Perl (e.g., Strawberry Perl on Windows) or use fallback build steps.
- Missing labels or duplicate refs: ensure Part II labels end with `2` and Part I with `1`.
- Wrapper edits not sticking: wrappers are generated; edit `manifest.json` or section files, then regenerate.

Tips for Consistency

- Keep sections self-contained and cite contracts/tenets explicitly.
- Use `\uses{...}` and acceptance-check boxes where helpful for audits.
- Prefer cross-part `\xref{...}` over direct file links to keep PDFs portable.

Linting

- Run const linter: `make lint-consts` (report) or `make lint-consts-fix` (apply fixes).
