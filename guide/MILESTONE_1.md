# Milestone 1 note

Milestone 1 proves the algebraic core: the Milestone 1 block of `Statements.lean`, plus
`no_flip`. The proofs are in `lean/JSG/Proofs/Milestone1.lean`. Each one gets a five-line,
plain-English explanation here, added by the PR that proves it. The closing note, in your
words, goes at the end once the gate is met: what is now proved, and what it does not show.

## `combine_comm`

Proved by Marley in Phase 1 (#15).

## `combine_assoc`

Proved in #28.

1. `combine` works axis by axis, so `funext i` compares the two sides at an arbitrary axis `i`.
2. At that axis both sides apply `combineAxis (kind i)` twice, and `cases kind i` splits on whether the axis is a floor or a budget.
3. On a floor axis both endpoints combine by max, and max is associative (`max_assoc`).
4. On a budget axis both endpoints combine by +, and + is associative (`add_assoc`).
5. `Bound.ext` turns the two endpoint equations into one equation of intervals. With `combine_comm`, any number of grades combine to the same result in any order and grouping.

## `interchange`

Proved in #29.

1. Both operators are `combine`, so interchange says combine (a·b) (c·d) equals combine (a·c) (b·d), where each · is `combine` too.
2. As for associativity, `funext i` compares both sides at an arbitrary axis, and `cases kind i` splits on its kind.
3. On a floor axis each endpoint is a max of four values grouped two ways, and `max_max_max_comm` swaps the middle two.
4. On a budget axis each endpoint is a sum of four values grouped two ways, and `add_add_add_comm` does the same for +.
5. It holds because core v2 uses one operator for sequence and parallel. JSG V's rule and SCp2's pair use two different operators, and both fail it.

## `verdict_sound`

Proved in #26.

1. `verdict θ g` accepts exactly when every axis's upper bound is within its threshold: `∀ i, (g i).hi ≤ θ i`.
2. Unfolding it leaves an if-then-else, and `split_ifs` splits on that condition.
3. If the condition held, it would give `(g i).hi ≤ θ i` for our axis `i`, contradicting `hover : θ i < (g i).hi`; so that branch can't happen.
4. In the other branch the verdict is `.reject`, which is the goal.
5. So one axis over its threshold rejects the whole grade, whatever the other axes hold; an unknown on a finite threshold is just one such axis.

## `verdict_complete`

Proved in #27.

1. As before, `verdict θ g` accepts exactly when `∀ i, (g i).hi ≤ θ i`, and `split_ifs` splits on that condition.
2. In the accepting branch the goal holds at once (`rfl`).
3. In the other branch the condition is assumed false, but it's true: for each axis, `hk i` says lo = hi, so `hin i : (g i).lo ≤ θ i` becomes `(g i).hi ≤ θ i`.
4. That contradiction rules the branch out, so the verdict accepts.
5. It doesn't show that the intervals enclose the true values; complete evidence is accepted, but whether it's right is the CI layer's job.

## `residual_spec`

Proved in #30.

1. `residual θ x` is `θ - x` in ENNReal, where subtraction stops at 0.
2. Mathlib's `ENNReal.le_sub_iff_add_le_left` says `y ≤ θ - x ↔ x + y ≤ θ` when x is finite and x ≤ θ.
3. `hx` gives x ≤ θ directly.
4. x is finite because it's at most θ, which `hθ` says is finite (`ne_top_of_le_ne_top`).
5. These are the two cases your self-check found: without `hx` the cut-off at 0 hides an overspend, and without `hθ`, x = θ = ⊤ gives a residual of ⊤ − ⊤ = 0.

## `no_flip`

Proved in #25.

1. `Noninterfering gradeOf` says the grader gives a record the same grade whatever metrics come with it: `gradeOf ⟨r, m⟩ = gradeOf ⟨r, m'⟩` for every `r`, `m` and `m'`.
2. The goal compares the verdict on `gradeOf ⟨r, m⟩` with the verdict on `gradeOf ⟨r, m'⟩`.
3. Applying the hypothesis to this record and these metrics, `hni r m m'`, gives exactly that equation of grades.
4. Rewriting with it turns the left grade into the right one, so both sides read the same and `rw` closes the goal.
5. It's the proof already in `Statements.lean`, restated so Comparator counts it. It doesn't show that any real grader is noninterfering; that's proved per grader, later.

## `fold_check_vacuous`

Proved in #31.

1. `fold Rmax lam rs` starts at 0 and, for each reading y, replaces the running value x with min(Rmax, x + lam·y).
2. `List.reverseRecOn` splits the readings into two cases: none at all, or some list `l` followed by a last reading `y`.
3. With no readings the fold is its starting value 0, and 0 ≤ Rmax is the hypothesis `h`.
4. Otherwise the last step is `min Rmax (…)`, which is at most Rmax whatever came before (`min_le_left`).
5. So no weight and no readings can make the nightly check fail: the theorem proves the defect, not a safeguard.

## Closing note

*To come, in your words, when the gate is met.*
