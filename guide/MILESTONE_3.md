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

Proved in #53.

1. Suppose instead that more than α of the mass has X > ε. Then ε is finite, since nothing exceeds ⊤.
2. The tails {X > ε + 1/n} grow to {X > ε}, so by continuity from below one of them, at a level s above ε, still holds more than α of the mass.
3. Every level t then gives t + E[(X − t)₊]/α ≥ s. That's clear if t ≥ s. If t < s, Markov's inequality gives E[(X − t)₊] ≥ (s − t)·μ{X > s}, which is at least (s − t)·α.
4. So the CVaR, the infimum over all levels, is at least s, which is above ε. That contradicts h.
5. The threshold stays ε throughout, which is the claim that C₀ = 1. The strict tail matters: a loss equal to ε everywhere has CVaR ε with all its mass at ε, which is why Lemma 9.1's "E < ε\_CKN" fails.

## `kl_fisher_local`

Proved in #54.

1. Along the ray t ↦ tθ, the log-partition function is the one-dimensional cgf of ⟪θ, T⟫, and the KL divergence of P\_θ from P₀ is ψ'(1) − ψ(1). That comes from the log-likelihood ratio of a tilted measure (`klDiv_tilted_self`).
2. Write m(t) = ψ'(t) = ⟪θ, κ(tθ)⟫. By `hlip`, its derivative ⟪θ, H(tθ)θ⟫ stays within δt‖θ‖² of ‖θ‖², where δ = L‖θ‖, and that pins m(t) between ‖θ‖²(t − δt²/2) and ‖θ‖²(t + δt²/2).
3. Cauchy's mean value theorem, applied to t·m(t) − ψ(tθ) and m(t)²/2, gives KL = ½m(1)²·ξ/m(ξ) for some ξ in (0, 1). The bounds on m put ξ/m(ξ) between 1/(1 + δ/2) and 1/(1 − δ/2), divided by ‖θ‖² (`kl_ray_bound`).
4. That controls κ(θ)'s component along θ. Cauchy–Schwarz caps m(1)² by ‖θ‖²‖κ(θ)‖², and the mean value inequality keeps κ(θ) within L‖θ‖² of θ, which bounds the rest.
5. A polynomial inequality then gives both halves, for every ε ≤ 1 (`kl_poly`, `kl_algebra`). The bound is in whitened coordinates; read in raw ones, as jsg-lab computes its radius, it fails (QUEUE.md, Q9).

## `dro_envelope`

Proved in #52.

1. Near ρ₀, η\*(ρ) attains the infimum, so the dual value there is exactly η\*(ρ)·ρ + g(η\*(ρ)) (`ciInf_le` one way, `le_ciInf` the other).
2. Using η\*(ρ₀) as the multiplier at ρ gives v(ρ) − v(ρ₀) ≤ η\*(ρ₀)(ρ − ρ₀): the line through v(ρ₀) with slope η\*(ρ₀) stays above v.
3. Using η\*(ρ) as the multiplier at ρ₀ gives v(ρ) − v(ρ₀) ≥ η\*(ρ)(ρ − ρ₀).
4. So v(ρ) − v(ρ₀) − η\*(ρ₀)(ρ − ρ₀) is at most |η\*(ρ) − η\*(ρ₀)|·|ρ − ρ₀|. Continuity makes the first factor as small as we like, which is the little-o that `hasDerivAt_iff_isLittleO` asks for.
5. So the dual's slope in ρ is the minimizing multiplier. Every dual of this shape satisfies it, a wrong one included, so it doesn't show that the dual is the worst-case risk (QUEUE.md, Q10).

## Closing note

*To come, in your words, when the gate is met.*
