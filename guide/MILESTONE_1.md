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

*Not yet proved.*

## `verdict_complete`

*Not yet proved.*

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
