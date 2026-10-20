JSG Part I — Authoring Guide and Build Notes

Overview

- Part I is authored as modular LaTeX sections with stable labels and shared Tenets.
- A/B wrappers are generated from a simple manifest so you can re-slice without copy/paste.
- Cross-part composition lets you assemble arguments spanning Parts 1–N without redundancy.

Directory Layout

```
papers/part1/
  JSG_I_skeleton.tex      # Master: inputs all Part I sections
  JSG_I_A.tex             # Generated wrapper (A)
  JSG_I_B.tex             # Generated wrapper (B)
  manifest.json           # Declarative A/B section includes
  sections/               # One .tex file per section (modular content)
    intro1.tex
    calc1.tex
    stoch1.tex
    closure1.tex
    entropy1.tex
    control1.tex
    kernels1.tex
    adv-structures1.tex
    stats1.tex
    bench1.tex
    conclusion1.tex
    alignment1.tex
```

Files of Interest

- `JSG_I_skeleton.tex`: master document including Tenets + all sections, prints bibliography.
- `sections/`: each file begins with `\section{...}\label{sec:*1}`.
- `manifest.json`: declares A/B wrapper includes.
- `JSG_I_A.tex`, `JSG_I_B.tex`: generated; do not hand-edit (regenerate instead).

Conventions

- Labels: Part I uses `*1` suffix (e.g., `sec:calc1`) to avoid collisions with Part II (`*2`).
- Cross-part references: use `\xref{sec:...}`; it prints a portable companion reference.
- Shared Tenets + Symbol Registry live in `papers/common/tenets.tex` and are included once per document.

Common Tasks

- Regenerate wrappers from manifest:
  - `python jsg/tools/generate_wrappers.py --part part1`
  - or `make build` (generator runs before LaTeX builds)
- Compose an ad‑hoc document (cross‑part):
  - `python jsg/tools/generate_wrappers.py --compose part1:calc1,part2:ctrl2 --title "JSG Composed" --out jsg/papers/composed/JSG_COMPOSED.tex`
- Add a new section to Part I:
  - Create `sections/<name>1.tex` starting with `\section{Title}\label{sec:<name>1}`
  - Add it to `JSG_I_skeleton.tex` (if you want it in the master)
  - Optionally add to `manifest.json` to appear in A/B wrappers; regenerate wrappers
- Add a new constant to the Symbol Registry:
  - Edit `papers/common/tenets.tex` (SymbolRegistry block) and regenerate PDFs
- Add bibliography entries:
  - Edit `papers/common/refs.bib`; all documents include it via biblatex

Build Instructions

- Preferred: `make build` (builds Part 1 skeleton + A/B and Part 2 A/B)
- Direct (single doc): `latexmk -r jsg/latexmkrc -output-directory=build jsg/papers/part1/JSG_I_skeleton.tex`
- Dependencies: LaTeX with `latexmk` (Perl), `biblatex` (backend=bibtex). On Windows with MiKTeX, ensure Perl is installed for latexmk.
- Fallback (without latexmk):
  1. `pdflatex -halt-on-error -interaction=nonstopmode JSG_I_skeleton.tex`
  2. `bibtex JSG_I_skeleton`
  3. `pdflatex` (twice)

Agent Context (for tooling / LLMs)

- Generate a compact pack with Tenets, Symbol Registry, and section maps:
  - `make agent-context` or `python jsg/tools/agent_context.py`
  - Output: `jsg/AGENT_CONTEXT.md`

Troubleshooting

- latexmk: "script engine 'perl.exe' not found": install Perl (e.g., Strawberry Perl on Windows) or use the fallback build steps above.
- Missing labels or duplicate refs: ensure Part I labels end with `1` and Part II with `2`.
- Wrapper edits not sticking: wrappers are generated; edit `manifest.json` or section files, then regenerate.

Tips for Consistency

- Keep sections self-contained and cite contracts/tenets explicitly.
- Use `\uses{...}` and acceptance-check boxes where helpful for audits.
- Prefer cross-part `\xref{...}` over direct file links to keep PDFs portable.

See Also

- Part II readme: `jsg/papers/part2/README.md` (same workflow, `*2` labels)
- Wrapper generator: `jsg/tools/generate_wrappers.py` (supports `--part`, `--include`, `--compose`)

Linting

- Run const linter: `make lint-consts` (report) or `make lint-consts-fix` (apply fixes).


