# JSG Merge Compositions

This folder contains staged compositions to facilitate merging by rigor:

- Stage 1: Part I → Part II (`JSG_MERGE_1into2.tex`)
- Stage 2: Part II → Part III (`JSG_MERGE_2into3.tex`)

The composition order is defined in `compose.json` and built via:

```
make merge
```

Outputs go to `jsg/build/` as PDFs. Edit the source modules in `papers/part{1,2,3}/sections/` — the composed wrappers are generated.

