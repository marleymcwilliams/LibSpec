Benchmarks

Small, runnable, and fast testbeds intended for CI and local verification.

Folders
- negative-control/: sanity checks where nothing should pass
- degeneracy-stress/: edge cases for degeneracy and robustness
- formal-spec/: minimal formal specification examples

Each benchmark should:
- be self-contained and runnable in under 60s
- emit artifacts under `artifacts/` following window-id naming
- document intended acceptance criteria
