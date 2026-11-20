# Milestone 5 note

Milestone 5 proves the four gap statements that `statements-v5` added: what an accept means
for the true values behind a grade, how the verdict behaves as evidence narrows, and when a
rejection is definite. The proofs are in `lean/JSG/Proofs/Milestone5.lean`, with no helper
lemma. Each proof gets a five-line, plain-English explanation here; all four came in one PR.
After them come the gate record and the closing note, in your words: what is now proved,
and what it does not show.

## `accept_bounds_truth`

Proved in #127.

1. An accept means every axis of the combined grade has its upper end within θ, so it's enough to show that each axis's true composite value is at most that upper end.
2. Enclosure puts each stage's true value at or below its interval's upper end. The proof uses only that half: the lower ends play no part.
3. On a floor, `combine` takes the larger of the two upper ends, and the composite's true value is at most the larger of the two true values, so it's at most the combined upper end (`max_le_max`).
4. On a budget, `combine` adds the upper ends, and subadditivity puts the composite's true value at or below the sum of the two true values, so the same chain holds (`add_le_add`).
5. So an accepted grade bounds the truth, on floors and budgets alike. Its mutants don't: on a budget, JSG V's `jsgVSeq` takes the max, so two stages that each cost 1 pass θ = 1 though together they cost 2; on a floor, `dropCombine` lets an unknown stage whose true value is 2 drop out.

## `combine_respects_narrowing`

Proved in #127.

1. One grade narrows another when, on every axis, its interval lies inside the other's: its lower end is no lower, and its upper end no higher.
2. So it's enough to show, axis by axis, that narrowing the two parts can only raise the combined lower end and lower the combined upper end.
3. On a floor, `combine` takes the larger of each pair of ends. Raising both values can only raise the larger, and lowering both can only lower it (`max_le_max`).
4. On a budget, `combine` adds each pair of ends, and the same holds for a sum (`add_le_add`).
5. So more evidence about a stage can only narrow the grade it combines into. The mutant `dropCombine`, after SirusSC's `q.py`, drops an unknown stage: on a floor, the known 1 with the unknown gives [1, 1], but with the known 2 in its place it gives [2, 2], outside [1, 1].

## `narrowing_keeps_accept`

Proved in #127.

1. The verdict reads only upper ends: it accepts a grade when every axis's upper end is within its threshold.
2. So an accepted grade has every upper end within θ.
3. A grade that narrows it has, on every axis, an upper end at or below the accepted one's, by the definition of narrowing.
4. Chaining the two, its upper ends are within θ too, so the verdict accepts it (`le_trans`).
5. So more evidence never turns an acceptance into a rejection. The mutant `verdictLo` reads lower ends instead: under θ = 1 it accepts the unknown, [0, ∞], but rejects the known 2, which narrows it.

## `definitelyFails_spec`

Proved in #127.

1. A grade fails definitely when some axis's lower end is above its threshold. The theorem says that happens exactly when every grade that narrows it is rejected.
2. One way: a grade that narrows it has, on that axis, a lower end at least as high, and its upper end is at least its lower end, so its upper end is above the threshold too, and the verdict rejects it.
3. The other way, by contradiction: suppose every grade that narrows it is rejected, but every axis's lower end is within its threshold.
4. The grade made of the point at each axis's lower end narrows it, since each point lies in its interval, and the verdict accepts it, since its upper ends are those lower ends. That contradicts the supposition.
5. So a report can tell a rejection that more evidence can't undo from one that it can. The mutant `rejectIsFinal`, after SCp1's single kind of rejection, counts every rejected grade as definite: under θ = 1 it counts the unknown, though the known 1 narrows the unknown and is accepted.

## Gate

How each item of ROADMAP's "Gate for every milestone" is met. The evidence for the first five is `main`'s CI run on the merge of #127, [run 44794745372](https://github.com/marleymcwilliams/LibSpec/actions/runs/44794745372), and the full-strength Comparator run on the same commit, `f194ab5`, [run 44797372577](https://github.com/marleymcwilliams/LibSpec/actions/runs/44797372577), both on 2026-11-20.

- **`lake build` is green, with no `sorry` in the milestone's proof file.** The build ended "Build completed successfully (8958 jobs)", leanchecker passed, and `check.sh`'s forbidden-token scan, `Proofs/` included, printed "ok". `check.sh` and `differential.sh` both passed, and both pilot reports printed "ok".
- **`#print axioms` on each theorem lists only `propext`, `Classical.choice` and `Quot.sound`.** The axiom audit's sweep (497 theorems in 23 modules) printed each of the four with exactly those three: `accept_bounds_truth`, `combine_respects_narrowing`, `narrowing_keeps_accept` and `definitelyFails_spec`. They use no helper lemma.
- **The statements check confirms the frozen files are unchanged.** It printed "ok (statements-v5): lean/JSG/Statements.lean lean/JSG/Defs.lean lean/lean-toolchain lean/lake-manifest.json lean/lakefile.toml".
- **Comparator confirms each proof against its frozen statement.**
  - **CI's run** accepted `JSG.Solution` against `JSG.Statements` with only the three permitted axioms ("Your solution is okay!"), and listed "none" under "Frozen theorems not yet proved": all 38 frozen theorems are proved.
  - **The full-strength run** checked all 38 again, with Lean's kernel and nanoda, inside the full sandbox. Both wrapper probes passed: AF_UNIX was refused inside, and `sudo` gained nothing. The sandbox check showed landrun in force. The self-test passed, with the mutant fixture "rejected because its statement differs from the challenge". Both kernels accepted the solution, and the run ended "comparator-full.sh: passed (38 theorems, Lean kernel and nanoda, full sandbox)".
- **Each theorem's named mutant is proved to violate it, and every must-pass control is accepted.**
  - **Mutants**, in `Tests/Mutants.lean`, from `statements-v5`:
    - `accept_bounds_truth_mutant`: JSG V's `jsgVSeq`, on a budget;
    - `accept_bounds_truth_dropCombine_mutant`: `dropCombine`, on a floor;
    - `combine_respects_narrowing_mutant`: `dropCombine`;
    - `narrowing_keeps_accept_mutant`: v1's `verdictLo`;
    - `definitelyFails_spec_mutant`: `rejectIsFinal`, a reading of SCp1.
  - **Must-pass:** each theorem's witness, an instance proved to satisfy it: `accept_bounds_truth_witness`, `combine_respects_narrowing_witness`, `narrowing_keeps_accept_witness` and `definitelyFails_spec_witness`. Milestone 1's controls in `Tests/Calibration.lean` still build.
  - All nine build in that run, and the audit printed each with only the three axioms.
- **Layer-map rows are set to Proved, and the guide's text names the Lean theorem.** [The layer map](LAYER_MAP.md)'s row for the core's gap statements now says Proved and names its four theorems. It keeps its limits: `accept_bounds_truth` takes enclosure, and how true values compose, as hypotheses, and it combines two stages once. Like the other Proved rows, it points to `Milestone5.lean` and this note, and the layer map's paragraph on `statements-v5` says Milestone 5 proved them.
- **A short note, in your words.** It follows.

## Closing note

All four Milestone 5 theorems are proved. Comparator accepts each one against `statements-v5`, and none uses an axiom beyond `propext`, `Classical.choice` and `Quot.sound`. Each has a mutant proved to break it, and `accept_bounds_truth` has one on each kind of axis. With this milestone, all 38 frozen theorems are proved, and the full-strength run passes on `main` with both kernels.

**What is now proved**
- What an accept means. If two stages' grades enclose their true values, and the true values compose no worse than `combine` assumes (at most the larger on a floor, at most the sum on a budget), an accepted combination bounds the true composed value by θ on every axis.
- More evidence can't hurt. Narrowing either stage's grade narrows what they combine into, and narrowing an accepted grade keeps it accepted.
- When a rejection is definite. A grade fails definitely, with some axis's lower end above its threshold, exactly when every grade that narrows it is rejected. Any other rejection is one that more evidence can undo.

**What it does not show**
- That any grade encloses its true value. Enclosure is a hypothesis: it rests on the check behind each value, not on Lean.
- That true values compose as `combine` assumes. On a budget that is subadditivity, which value-at-risk, for one, doesn't have.
- More than two stages combined once. A window's fold, and the pilot's closure, which also masks what carries (Q14), aren't stated.
- That the pilot's report makes this split. `Release.why` tells failing evidence from missing evidence axis by axis, but no theorem ties it to `definitelyFails_spec` yet.
- That the statements say what I mean. CI shows the proofs conform to them; whether they're the right statements is my judgment, not Lean's.
