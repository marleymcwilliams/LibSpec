# Working rules for this repo

## Roles
- The human owns `lean/JSG/Statements.lean` and `lean/JSG/Defs.lean`, the definitions it uses.
  Never edit them. If a statement looks wrong or unprovable, stop and explain why.
- Proofs go in `lean/JSG/Proofs/`. Each proof file imports `JSG.Defs` and restates frozen theorems
  under their exact names; `lean/JSG/Solution.lean` imports every proof file, and Comparator
  checks each one against its frozen statement. Helper lemmas go in `lean/JSG/Lemmas/`, never
  in a proof file. `lean/JSG/Tests.lean` imports every test file. The axiom audit sweeps
  Proofs/, Lemmas/ and Tests/ and fails on any file that these two roots don't reach.
- `archive/` is read-only.

## Definition of done
- `lake build` passes with no errors, and no warnings in files you touched.
- No `sorry`, `admit`, `axiom`, or native evaluation (`native_decide`, `decide +native`).
- `#print axioms` on each target shows only propext, Classical.choice, Quot.sound.
- Every theorem has a named mutant, and `JSG/Tests/Mutants.lean` proves the mutant violates it.
  Prefer mutants taken from real defects in archive/ over invented ones.
- Every theorem also has a witness instance in `JSG/Tests/` where it holds.
- `scripts/check.sh` passes, and CI's Comparator step passes.

## How to work
- Never push to `main`. Work on a branch and open a PR.
- Never create, move or delete a statements-v* tag; I do the tagging.
- One target per session unless told otherwise.
- Search Mathlib (Loogle, exact?, apply?) before writing a helper lemma.
- Treat any Mathlib name recalled from memory, yours or another model's, as a guess until Loogle confirms it.
- Never weaken a hypothesis or change a statement to make a proof go through.
- After three failed approaches, stop. Report what you tried, what blocked you,
  and whether the statement itself might be false.
- End every session with: files changed, theorems closed, ideas added to guide/IDEAS.md.

## When to ask the human
- Decide it yourself and log it in guide/LOG.md if it is reversible and doesn't change
  what a statement means: layout, tactics, CI, wording, which lemma or mutant.
- Exception: anything that makes a check weaker goes in the queue, even if reversible:
  covering fewer files or theorems, permitting an axiom, turning off leanchecker or
  Comparator, deleting a test or mutant. Making a check stronger is your call.
- Queue it in guide/QUEUE.md if it changes a statement's meaning, a Norm-layer value, or
  anything frozen. Each entry: question, recommended answer, what breaks if wrong,
  whether it can be undone. At most three open entries; never block on one.
- Reviewer notes follow the same rule: apply and log the reversible ones, queue the rest.
- "Not yet" is a valid answer: if no current statement depends on a decision, defer it
  to the milestone that needs it.
- You may merge your own PR once CI is green if it touches none of: the statements and
  every file the statements check covers, archive/, CLAUDE.md, .gitattributes, scripts/,
  .github/, guide/decisions/, the checks that live in lean/ (lean/ComparatorTargets.lean,
  lean/AxiomAudit.lean, lean/JSG/Tests/Comparator/), and any existing file in
  lean/JSG/Tests/. Adding a new test file stays self-mergeable. I merge everything else.
- Don't prove expiry_tightens. I'm writing it myself (Phase 1).
