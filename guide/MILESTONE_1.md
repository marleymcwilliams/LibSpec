# Milestone 1 note

Milestone 1 proves the algebraic core: the Milestone 1 block of `Statements.lean`, plus
`no_flip`. The proofs are in `lean/JSG/Proofs/Milestone1.lean`. Each one gets a five-line,
plain-English explanation here, added by the PR that proves it. The closing note, in your
words, goes at the end once the gate is met: what is now proved, and what it does not show.

## `combine_comm`

Proved by Marley in Phase 1 (#15).

## `combine_assoc`

*Not yet proved.*

## `interchange`

*Not yet proved.*

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

*Not yet proved.*

## `no_flip`

Proved in #25.

1. `Noninterfering gradeOf` says the grader gives a record the same grade whatever metrics come with it: `gradeOf ⟨r, m⟩ = gradeOf ⟨r, m'⟩` for every `r`, `m` and `m'`.
2. The goal compares the verdict on `gradeOf ⟨r, m⟩` with the verdict on `gradeOf ⟨r, m'⟩`.
3. Applying the hypothesis to this record and these metrics, `hni r m m'`, gives exactly that equation of grades.
4. Rewriting with it turns the left grade into the right one, so both sides read the same and `rw` closes the goal.
5. It's the proof already in `Statements.lean`, restated so Comparator counts it. It doesn't show that any real grader is noninterfering; that's proved per grader, later.

## `fold_check_vacuous`

*Not yet proved.*

## Closing note

*To come, in your words, when the gate is met.*
