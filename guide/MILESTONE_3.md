# Milestone 3 note

Milestone 3 proves the analysis layer: the corrected dwell bound from `statements-v1`, and
the CVaR tail-to-level step, the local KL–Fisher bound and the DRO envelope identity that
`statements-v3` added. The proofs are in `lean/JSG/Proofs/Milestone3.lean`, and the
KL–Fisher bound's helper lemmas in `lean/JSG/Lemmas/KLFisher.lean`. Each proof gets a
five-line, plain-English explanation here, added by the PR that proves it. The closing
note, in your words, goes at the end once the gate is met: what is now proved, and what it
does not show.

## `dwell_lower_bound`

Proved by Marley (#51).

## `cvar_tail_to_level`

*Not yet proved.*

## `kl_fisher_local`

*Not yet proved.*

## `dro_envelope`

Proved in #52.

1. Near ρ₀, η\*(ρ) attains the infimum, so the dual value there is exactly η\*(ρ)·ρ + g(η\*(ρ)) (`ciInf_le` one way, `le_ciInf` the other).
2. Using η\*(ρ₀) as the multiplier at ρ gives v(ρ) − v(ρ₀) ≤ η\*(ρ₀)(ρ − ρ₀): the line through v(ρ₀) with slope η\*(ρ₀) stays above v.
3. Using η\*(ρ) as the multiplier at ρ₀ gives v(ρ) − v(ρ₀) ≥ η\*(ρ)(ρ − ρ₀).
4. So v(ρ) − v(ρ₀) − η\*(ρ₀)(ρ − ρ₀) is at most |η\*(ρ) − η\*(ρ₀)|·|ρ − ρ₀|. Continuity makes the first factor as small as we like, which is the little-o that `hasDerivAt_iff_isLittleO` asks for.
5. So the dual's slope in ρ is the minimizing multiplier. Every dual of this shape satisfies it, a wrong one included, so it doesn't show that the dual is the worst-case risk (QUEUE.md, Q10).

## Closing note

*To come, in your words, when the gate is met.*
