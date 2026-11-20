# Milestone 5 note

Milestone 5 proves the four gap statements that `statements-v5` added: what an accept means
for the true values behind a grade, how the verdict behaves as evidence narrows, and when a
rejection is definite. The proofs are in `lean/JSG/Proofs/Milestone5.lean`, with no helper
lemma. Each proof gets a five-line, plain-English explanation here; all four came in one PR.
The gate record and the closing note, in your words, come in the milestone's closing PR, once
the gate is met: what is now proved, and what it does not show.

## `accept_bounds_truth`

Proved in #N.

1. An accept means every axis of the combined grade has its upper end within θ, so it's enough to show that each axis's true composite value is at most that upper end.
2. Enclosure puts each stage's true value at or below its interval's upper end. The proof uses only that half: the lower ends play no part.
3. On a floor, `combine` takes the larger of the two upper ends, and the composite's true value is at most the larger of the two true values, so it's at most the combined upper end (`max_le_max`).
4. On a budget, `combine` adds the upper ends, and subadditivity puts the composite's true value at or below the sum of the two true values, so the same chain holds (`add_le_add`).
5. So an accepted grade bounds the truth, on floors and budgets alike. Its mutants don't: on a budget, JSG V's `jsgVSeq` takes the max, so two stages that each cost 1 pass θ = 1 though together they cost 2; on a floor, `dropCombine` lets an unknown stage whose true value is 2 drop out.

## `combine_respects_narrowing`

Proved in #N.

1. One grade narrows another when, on every axis, its interval lies inside the other's: its lower end is no lower, and its upper end no higher.
2. So it's enough to show, axis by axis, that narrowing the two parts can only raise the combined lower end and lower the combined upper end.
3. On a floor, `combine` takes the larger of each pair of ends. Raising both values can only raise the larger, and lowering both can only lower it (`max_le_max`).
4. On a budget, `combine` adds each pair of ends, and the same holds for a sum (`add_le_add`).
5. So more evidence about a stage can only narrow the grade it combines into. The mutant `dropCombine`, after SirusSC's `q.py`, drops an unknown stage: on a floor, the known 1 with the unknown gives [1, 1], but with the known 2 in its place it gives [2, 2], outside [1, 1].

## `narrowing_keeps_accept`

Proved in #N.

1. The verdict reads only upper ends: it accepts a grade when every axis's upper end is within its threshold.
2. So an accepted grade has every upper end within θ.
3. A grade that narrows it has, on every axis, an upper end at or below the accepted one's, by the definition of narrowing.
4. Chaining the two, its upper ends are within θ too, so the verdict accepts it (`le_trans`).
5. So more evidence never turns an acceptance into a rejection. The mutant `verdictLo` reads lower ends instead: under θ = 1 it accepts the unknown, [0, ∞], but rejects the known 2, which narrows it.

## `definitelyFails_spec`

Proved in #N.

1. A grade fails definitely when some axis's lower end is above its threshold. The theorem says that happens exactly when every grade that narrows it is rejected.
2. One way: a grade that narrows it has, on that axis, a lower end at least as high, and its upper end is at least its lower end, so its upper end is above the threshold too, and the verdict rejects it.
3. The other way, by contradiction: suppose every grade that narrows it is rejected, but every axis's lower end is within its threshold.
4. The grade made of the point at each axis's lower end narrows it, since each point lies in its interval, and the verdict accepts it, since its upper ends are those lower ends. That contradicts the supposition.
5. So a report can tell a rejection that more evidence can't undo from one that it can. The mutant `rejectIsFinal`, after SCp1's single kind of rejection, counts every rejected grade as definite: under θ = 1 it counts the unknown, though the known 1 narrows the unknown and is accepted.
