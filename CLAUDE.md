# Working rules for this repo

## Roles
- The human owns `lean/JSG/Statements.lean`. Never edit it.
  If a statement looks wrong or unprovable, stop and explain why.
- Proofs go in `lean/JSG/Proofs/`, helper lemmas in `lean/JSG/Lemmas/`.
- `archive/` is read-only.

## Definition of done
- `lake build` passes with no errors, and no warnings in files you touched.
- No `sorry`, `admit`, `axiom`, or native evaluation (`native_decide`, `decide +native`).
- `#print axioms` on each target shows only propext, Classical.choice, Quot.sound.
- Every theorem has a named mutant, and `JSG/Tests/Mutants.lean` proves the mutant violates it.
  Prefer mutants taken from real defects in archive/ over invented ones.
- Every theorem also has a witness instance in `JSG/Tests/` where it holds.
- `scripts/check.sh` passes.

## How to work
- Never push to `main`. Work on a branch and open a PR.
- One target per session unless told otherwise.
- Search Mathlib (Loogle, exact?, apply?) before writing a helper lemma.
- Treat any Mathlib name recalled from memory, yours or another model's, as a guess until Loogle confirms it.
- Never weaken a hypothesis or change a statement to make a proof go through.
- After three failed approaches, stop. Report what you tried, what blocked you,
  and whether the statement itself might be false.
- End every session with: files changed, theorems closed, ideas added to guide/IDEAS.md.
