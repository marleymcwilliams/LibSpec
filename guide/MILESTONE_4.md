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
