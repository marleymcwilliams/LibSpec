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

## Gate

How each item of ROADMAP's "Gate for every milestone" is met. The evidence for the first five is `main`'s CI run on the merge of #54: [run 40746039446](https://github.com/marleymcwilliams/LibSpec/actions/runs/40746039446).

- **`lake build` is green, with no `sorry` in the milestone's proof file.** The build and leanchecker passed, and `check.sh`'s forbidden-token scan of `Proofs/`, `Lemmas/` and `Tests/` printed "ok".
- **`#print axioms` on each theorem lists only `propext`, `Classical.choice` and `Quot.sound`.** The axiom audit's sweep (252 theorems in 8 modules) printed each of the four with exactly those three: `dwell_lower_bound`, `cvar_tail_to_level`, `kl_fisher_local` and `dro_envelope`. So did the four helper lemmas in `Lemmas/KLFisher.lean`: `klDiv_tilted_self`, `kl_ray_bound`, `kl_poly` and `kl_algebra`.
- **The statements check confirms the frozen files are unchanged.** It printed "ok (statements-v3): lean/JSG/Statements.lean lean/JSG/Defs.lean lean/lean-toolchain lean/lake-manifest.json lean/lakefile.toml".
- **Comparator confirms each proof against its frozen statement.** It accepted `JSG.Solution` against `JSG.Statements` with only the three permitted axioms ("Your solution is okay!"). Its not-yet-proved list is empty: all 26 frozen theorems are proved.
- **Each theorem's named mutant is proved to violate it, and every must-pass control is accepted.**
  - **Mutants**, in `Tests/Mutants.lean`: `dwell_lower_bound_mutant` (JSG I's lemma, with a lower bound on speed), `cvar_tail_to_level_mutant` (PDE Lemma 9.1's strict conclusion), `kl_fisher_local_mutant` (jsg-lab's raw-coordinate radius) and `dro_envelope_mutant` (JSG II's KL dual read with η as the tilt).
  - **Must-pass**, in `Tests/Mutants.lean`: each theorem's witness, `dwell_lower_bound_witness` to `dro_envelope_witness`, which proves every hypothesis and the conclusion for one instance. Milestone 1's controls in `Tests/Calibration.lean` still pass.
  - All of these build in that run, and the audit swept them, each within the three axioms.
- **Layer-map rows are set to Proved, and the guide's text names the Lean theorem.** In #55, MASTER_GUIDE's four analysis rows use your approved wording, which names their theorems and notes each row's limits. The Jacobi frontier defect's row is marked out of scope, with Q8's reason, and the layer map's opening sentence counts it apart.
- **A short note, in your words.** It follows.

## Closing note

All four Milestone 3 theorems are proved, `dwell_lower_bound` by me. Comparator accepts each one against `statements-v3`, and neither they nor the four helper lemmas in `Lemmas/KLFisher.lean` use an axiom beyond `propext`, `Classical.choice` and `Quot.sound`. Each has a mutant proved to break it. With this milestone, all 26 frozen theorems are proved.

**What is now proved**
- If a loss's CVaR at tail mass α is at most ε, the loss exceeds ε on a set of measure at most α, for any measure and any α (`cvar_tail_to_level`). No constant is lost: C₀ = 1.
- If the signed distance to a frontier moves no faster than S_max, going from +r to −r takes at least 2r/S_max (`dwell_lower_bound`).
- In whitened coordinates, if the Fisher information stays within L‖x‖ of the identity along the segment from 0 to θ, and L‖θ‖ ≤ ε ≤ 1, the KL divergence of P_θ from P₀ is within a factor 1 ± ε of ½‖κ(θ)‖² (`kl_fisher_local`).
- For a dual value of the form inf over η of ηρ + g(η), if a minimizing multiplier η*(ρ) attains the infimum near ρ₀ and is continuous at ρ₀, the dual's slope at ρ₀ is η*(ρ₀) (`dro_envelope`).

**What it does not show**
- The rest of PDE Lemma 9.1. Its rescaling to the CKN threshold and its Vitali overlap count aren't stated.
- That crossings can't pile up in finite time. The dwell bound covers a crossing from +r to −r; excluding sliding along the frontier, which JSG I's α was for, isn't stated.
- The KL–Fisher bound in raw coordinates, where it fails. `kl_fisher_local` also assumes the gradient and Hessian along the segment rather than deriving them.
- That the dual equals the worst-case risk. `dro_envelope` is about the dual value; strong duality isn't stated, so the identity isn't claimed for the risk itself.
- Anything about estimates from data. These are statements about exact distributions; jsg-lab's numerical checks, such as JSG II's 5% finite-difference test, aren't covered.
- That the statements say what I mean. CI shows the proofs conform to them; whether they're the right statements is my judgment, not Lean's.
