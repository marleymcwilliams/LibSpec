## JSG Merging Plan (I → II → III)

This repo ships three LaTeX parts (I, II, III). To facilitate a staged merge:

- Stage 1 (I → II): build a composed wrapper that orders themes by rigor, pairing each Part I section with its Part II counterpart (intro, calc, stoch, closure, entropy, control, kernels, adv-structures, stats, conclusion; plus benches/tables).
- Stage 2 (II → III): build a composed wrapper that appends Paper III to the curated Part II sequence, keeping cross-references and guard-order structure intact.

### How it works

- Composition spec: `jsg/papers/merge/compose.json` lists the ordered modules for both stages.
- Builder: `python jsg/tools/build_composed.py` uses the existing `generate_wrappers.py --compose` path to write stable TeX wrappers into `jsg/papers/merge/`.
- Make targets:
  - `make merge` generates the composed TeX and PDFs:
    - `build/JSG_MERGE_1into2.pdf`
    - `build/JSG_MERGE_2into3.pdf`

### Topic packs (side-by-side by theme)

- Map: `jsg/merge/merge_map.json` defines topics and the files per part.
- Builder: `python jsg/tools/build_topic.py --key control` writes `papers/merge/TOPIC_CONTROL.tex`.
- Make target: `make topic KEY=control` builds the topic PDF at `build/TOPIC_CONTROL.pdf`.

### Cross-doc references and styles

- All wrappers inherit the common style (`papers/common/jsg_common.tex`, `macros.tex`, `xref.tex`).
- Cross-document links: `xr-hyper` is enabled in `jsg_common.tex`. If the Part I/II AUX files exist in `build/`, links resolve live with prefixes `JSGI-` / `JSGII-`; otherwise the safe macros surface `[??]` visibly.
- Paper III ships `papers/part3/macros3.tex` with safe cross-part ref helpers. Compiled PDFs will not silently render “??”.

### Editing guidance

- Prefer edits in the source module files (e.g., `papers/part1/sections/calc1.tex`) so that composed builds stay in sync.
- Use the merge compositions to reconcile notation and move content “up” the rigor ladder (1 → 2 → 3).

### Outputs

After `make merge`, PDFs live under `jsg/build/`. Link targets (local paths):

- Part I/II merge: `jsg/build/JSG_MERGE_1into2.pdf`
- Part II/III merge: `jsg/build/JSG_MERGE_2into3.pdf`
