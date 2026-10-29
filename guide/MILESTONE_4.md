# Milestone 4 note

Milestone 4 proves the eight agreement theorems that `statements-v4` added: each executable
twin of the core's definitions agrees with its frozen definition. The proofs are in
`lean/JSG/Proofs/Milestone4.lean`, and their cast lemmas in `lean/JSG/Lemmas/Twins.lean`.
Each proof gets a five-line, plain-English explanation here, added by the PR that proves it.
The closing note, in your words, goes at the end once the gate is met: what is now proved,
and what it does not show.

## `xknown_agrees`

Proved in #63.

1. A known exact value x is the interval [x, x], and its twin is the same interval with exact ends.
2. Casting the twin casts both ends, which gives [xcast x, xcast x].
3. That is `Bound.known (xcast x)` by definition. The two sides differ only in which proof of lo ≤ hi each bound carries.
4. Lean treats any two proofs of the same fact as equal, so `rfl` closes it.
5. So a known reading keeps its width of 0 through the cast. The mutant `upperOnly`, which reads x as [0, x], doesn't.

## `xunknown_agrees`

Proved in #64.

1. The unknown's twin is [0, ∞] with exact ends, and the frozen unknown is [0, ∞] in `ENNReal`.
2. Two bounds are equal when their ends are (`Bound.ext`), so it's enough to compare lower end with lower end and upper with upper.
3. The upper ends match because `xcast` sends ∞ to ∞, by definition (`xcast_top`).
4. The lower ends take one step more: the twin's 0 is the rational 0 inside `WithTop`, and casting it through ℝ≥0 gives `ENNReal`'s 0 (`xcast_zero`).
5. So the pilot's unknown axes are the spec's unknowns, and `verdict_sound` rejects them under any finite threshold. The mutant `bottomUnknown`, [0, 0], would pass.

## `xcombine_agrees`

Proved in #66.

1. Both sides are grades, so it's enough to compare them axis by axis, and end by end.
2. On a floor axis the twin takes the max of each end, and casting preserves max, since it preserves order (`xcast_max`).
3. On a budget axis the twin adds each end, and casting preserves + (`xcast_add`). That's checked case by case: ∞ plus anything is ∞ in both carriers, and finite values add as rationals and as reals alike.
4. So casting the combined twin gives the combination of the casts, on every axis.
5. Core v2 makes `seqComp` and `parComp` both `combine`, so the twin stands for them too. SirusSC's absorbing ⊥, which discards a known lower bound, doesn't agree.

## `xverdict_agrees`

Proved in #65.

1. Both verdicts accept exactly when every axis's upper end is within its threshold. They differ only in the carrier, and in how "every axis" is decided.
2. Unfolded, the frozen verdict compares xcast (g i).hi with xcast (θ i), and the twin compares (g i).hi with θ i.
3. `xcast` preserves and reflects order (`xcast_le_iff`, from Mathlib's `WithTop.map_le_iff` and `NNRat.cast_le`), so the two conditions are the same proposition.
4. With the same condition, the two `if`s agree, however each decides it: the twin by checking each of finitely many axes, the frozen verdict classically.
5. So `verdict_sound` and `verdict_complete` hold of the executable verdict on finitely many axes. SirusSC's `Q.leq`, which skips an unknown axis, doesn't agree.

## `xresidual_agrees`

Proved in #67.

1. The twin's residual θ − x is truncated subtraction in `WithTop ℚ≥0`, and the frozen one is truncated subtraction in `ENNReal`. The claim is that the cast commutes with it (`xcast_sub`).
2. If x is ∞, both sides are 0, since subtracting ∞ leaves 0 in both carriers, ∞ − ∞ included.
3. If θ is ∞ and x is finite, both sides are ∞.
4. If both are finite, it comes down to the cast from ℚ≥0 to ℝ≥0, for which Mathlib has no truncated-subtraction lemma. A helper proves it: if x ≤ θ, write θ = x + d, and both sides are d; otherwise both are 0 (`nnrat_cast_tsub`).
5. So the twin leaves exactly the budget the spec does after each stage. v1's `residualFull`, which leaves θ, doesn't agree.

## `xthreads_agrees`

Proved in #70.

1. Both sides walk the stages from the front, so the proof is an induction on the list of stages, for every budget θ.
2. With no stages, both hold: the test returns `true`, and `Threads` is `True`.
3. With a first stage x, the test checks x ≤ θ and then threads what's left, while `Threads` checks xcast x ≤ xcast θ and threads the frozen residual.
4. `xcast_le_iff` matches the first checks, and `xresidual_agrees` turns the frozen residual into the cast of the twin's, so the induction hypothesis matches the rest.
5. Unlike `threads_spec`, it holds for an unlimited budget too. v1's residual check alone, which never checks that the early stages fit, doesn't agree: take θ = 1 with stages 2 then 0.

## `xwidth_agrees`

Proved in #68.

1. A twin's width is hi − lo, and the frozen width is the same subtraction in `ENNReal`.
2. So it is `xcast_sub` applied to the twin's two ends, the lemma behind `xresidual_agrees`.
3. Since lo ≤ hi, nothing truncates, but ∞ needs care: a known ∞, [∞, ∞], has width ∞ − ∞, which is 0 in both carriers.
4. That case matters to the pilot. A withdrawn manuscript's `withdrawn` axis is [∞, ∞], a point, not an interval of infinite width.
5. A floating-point gate gets it wrong, since ∞ − ∞ is NaN there. The mutant `floatWidth` gives ∞, and doesn't agree.

## `xleaseVerdict_agrees`

Proved in #69.

1. The lease verdict accepts exactly when every axis's upper end is within its threshold and its width within its lease.
2. The twin's widths cast to the frozen widths (`xwidth_agrees`), so after rewriting, both conditions compare cast values.
3. `xcast_le_iff` turns each cast comparison into the twin's own, so the two conditions are the same proposition.
4. As with `xverdict_agrees`, the two `if`s then agree, however each decides it.
5. So `lease_sound` and `lease_complete` hold of the executable lease verdict on finitely many axes. SirusSC's `QPrime`, which never reads a width, doesn't agree: it accepts [0, 5] leased 1 under θ = 10.

## Gate

How each item of ROADMAP's "Gate for every milestone" is met. The evidence for the first five is `main`'s CI run on the merge of #70, [run 40840441621](https://github.com/marleymcwilliams/LibSpec/actions/runs/40840441621), and the full-strength Comparator run on the same commit, `6a8a77c`, [run 40840546350](https://github.com/marleymcwilliams/LibSpec/actions/runs/40840546350).

- **`lake build` is green, with no `sorry` in the milestone's proof file.** The build and leanchecker passed, and `check.sh`'s forbidden-token scan of `Proofs/`, `Lemmas/` and `Tests/` printed "ok".
- **`#print axioms` on each theorem lists only `propext`, `Classical.choice` and `Quot.sound`.** The axiom audit's sweep (334 theorems in 10 modules) printed each of the eight with exactly those three: `xknown_agrees`, `xunknown_agrees`, `xcombine_agrees`, `xverdict_agrees`, `xresidual_agrees`, `xthreads_agrees`, `xwidth_agrees` and `xleaseVerdict_agrees`. So did the eight cast lemmas in `Lemmas/Twins.lean`: `xcast_coe`, `xcast_top`, `xcast_zero`, `xcast_le_iff`, `xcast_max`, `xcast_add`, `nnrat_cast_tsub` and `xcast_sub`.
- **The statements check confirms the frozen files are unchanged.** It printed "ok (statements-v4): lean/JSG/Statements.lean lean/JSG/Defs.lean lean/lean-toolchain lean/lake-manifest.json lean/lakefile.toml".
- **Comparator confirms each proof against its frozen statement.**
  - **CI's run** accepted `JSG.Solution` against `JSG.Statements` with only the three permitted axioms ("Your solution is okay!"). Its not-yet-proved list is empty: all 34 frozen theorems are proved.
  - **The full-strength run** checked all 34 again, with Lean's kernel and nanoda, inside the full sandbox. Both wrapper probes passed, and the mutant fixture was rejected for its statement. It ended "comparator-full.sh: passed (34 theorems, Lean kernel and nanoda, full sandbox)".
- **Each theorem's named mutant is proved to violate it, and every must-pass control is accepted.**
  - **Mutants**, in `Tests/Mutants.lean`, from `statements-v4`:
    - `xknown_agrees_mutant`: a point read as [0, x];
    - `xunknown_agrees_mutant`: the unknown at the bottom of the order, [0, 0];
    - `xcombine_agrees_mutant`: SirusSC's absorbing ⊥;
    - `xverdict_agrees_mutant`: SirusSC's `Q.leq`;
    - `xresidual_agrees_mutant`: v1's `residualFull`;
    - `xthreads_agrees_mutant`: v1's residual check alone;
    - `xwidth_agrees_mutant`: floating point's ∞ − ∞;
    - `xleaseVerdict_agrees_mutant`: SirusSC's `QPrime`.
  - **Must-pass:** each theorem's witness, `xknown_agrees_witness` to `xleaseVerdict_agrees_witness`. Each proves the statement for one instance, several of them their mutant's own counterexample. Milestone 1's controls in `Tests/Calibration.lean` still pass.
  - All sixteen build in that run, and the audit swept them, each within the three axioms.
- **Layer-map rows are set to Proved, and the guide's text names the Lean theorem.** In #71, MASTER_GUIDE's "Executable twins" row uses your approved wording, which names its eight theorems and notes the row's limits.
- **A short note, in your words.** It follows.

## Closing note

All eight Milestone 4 theorems are proved. Comparator accepts each one against `statements-v4`, and neither they nor the cast lemmas in `Lemmas/Twins.lean` use an axiom beyond `propext`, `Classical.choice` and `Quot.sound`. Each has a mutant proved to break it. With this milestone, all 34 frozen theorems are proved, and the full-strength run passes on `main` with both kernels.

**What is now proved**
- Each executable twin, computing exactly in `WithTop ℚ≥0`, agrees with its frozen definition: known and unknown values, `combine` (and so `seqComp` and `parComp`), `verdict`, `residual`, `Threads`, widths and `leaseVerdict`.
- So the earlier theorems about those definitions hold of the twins too. The twin verdict is sound and complete, and the twin lease verdict rejects any axis over its threshold or wider than its lease.

**What it does not show**
- Infinitely many axes. The twin verdicts are stated for finitely many.
- The obligations and the Loader. Their twins aren't stated yet (Q11), so `pass_sound` and the Loader theorems don't yet cover what the harness will compute.
- That the code which runs the twins is correct. The theorems are about the Lean definitions; the compiler that turns them into a program is trusted, not proved. The pilot's fixed verdicts will be checked by the kernel with `decide +kernel`, which doesn't rely on it.
- That anything runs yet. The harness, the differential tests and the pilot are still to come.
- That the statements say what I mean. CI shows the proofs conform to them; whether they're the right statements is my judgment, not Lean's.
