# Decision queue

Questions only you can answer: anything that changes a statement's meaning, a Norm-layer value or anything frozen, and anything that would make a check weaker. Each entry gives the question, a recommended answer, what breaks if the answer is wrong, and whether it can be undone. At most three entries are open at once, and work never waits on one. "Not yet" is a valid answer.

## Open

### Q11. Freeze executable twins of the core definitions as statements-v4?

- **Question:** v1.0 proves things about the gate's definitions, but they can't run: `ENNReal` arithmetic is noncomputable, `verdict` decides classically, and `LoaderStep` is a relation. [EXECUTABLE_GATE.md](EXECUTABLE_GATE.md) §1 proposes executable twins over `WithTop ℚ≥0`, with a theorem that each agrees with its frozen definition, frozen as `statements-v4` and driven by a thin harness, `lake exe jsg-gate`. Should v4 freeze them, and which ones?
- **Recommended answer:** Yes, for every definition in §1's table: graded values and `combine`, `verdict`, `residual` and `Threads`, `Bound.width` and `leaseVerdict`, the typed obligations and `Passes`, and `LoaderStep` as a step function, with soundness and completeness. `Prims` stays abstract (Q7). Every frozen gate theorem then applies to what the harness computes.
- **What breaks if wrong:** If a smaller first step is better, v4 could freeze only `combine`, `verdict` and `leaseVerdict`, which are what the pilot needs. The rest can follow in a later version, which only adds. A different carrier than `WithTop ℚ≥0` changes every agreement theorem, so it's cheapest to settle now. `Float` would break agreement outright.
- **Can it be undone:** Yes, freely until `statements-v4` is tagged. After that, adding twins is a tightening, and removing one is a weakening.

### Q12. The pilot's axes and thresholds

- **Question:** The pilot (§3) grades each manuscript on seven floor axes: `withdrawn`, `dependency_withdrawn`, `formal_proof`, `statement_fidelity`, `axioms`, `independent_review` and `novelty`. Their thresholds and leases are Norm-layer values. What should they be, and what goes in the must-pass and must-fail sets?
- **Recommended answer:**
  - **Thresholds:** θ = 0 on every axis, with no leases, so a manuscript is accepted only when every doubt is known to be 0.
  - **Must-fail:** the three withdrawn manuscripts, each rejected on known axes alone, even with every unknown axis set to 0, plus synthetic controls.
  - **Must-pass:** synthetic records until a named reviewer checks a formalized manuscript's statement against its paper.

  Under this answer every real manuscript is rejected today, because `statement_fidelity`, `independent_review` and `novelty` are unknown for all 721. The pilot's report is then each manuscript's list of unknowns.
- **What breaks if wrong:** If θ = 0 everywhere is too strict to be useful, a lease on `independent_review` or `novelty` would let formalized, statement-checked results pass. That weakens "unknown axes must reject" from IDEAS, so it should be your call, not a default. Picking the reviewer for `statement_fidelity` is also yours.
- **Can it be undone:** Yes. They're declared values, so changing a threshold changes the pilot's verdicts, not any theorem. Removing a must-fail class is a weakening (decisions/RAILS.md).

### Q13. Where do heavy builds run?

- **Question:** You suggested Lewis & Clark's BLT cluster for heavy builds, if its OS can run current Lean. Its documentation says CentOS Linux 7.4. That has glibc 2.17, below the 2.26 that Lean's x86-64 Linux releases need, and a 3.10 kernel without Landlock, so neither Lean nor Comparator's sandbox would run (§4). Should BLT be used, and for what?
- **Recommended answer:** Ask BLT's administrators for its current OS, and whether it has a container runtime such as Apptainer; the documentation may be out of date, since CentOS 7 reached end of life in June 2024. Until then, run everything on GitHub Actions. Either way, use BLT, if at all, only for trusted builds (LibSpec, Mathlib-scale experiments). Never build the openai/math library outside a sandbox: building a Lean library runs its code.
- **What breaks if wrong:** If GitHub's hosted runners prove too small for some release challenges (4 cores, 16 GB, 6 hours per job), those challenges wait. The alternatives are larger paid runners, or a disposable VM elsewhere with the same sandbox.
- **Can it be undone:** Yes. Nothing is frozen.

## Answered

### Q8. Which analysis statements belong in statements-v3?

**Answered 2026-10-28: yes, as recommended,** by tagging `statements-v3` at the draft's head (#50).

- **Question:** ROADMAP's Milestone 3 lists the CVaR tail-to-level step, `dwell_lower_bound`, the local KL–Fisher bound and the DRO envelope identity. MASTER_GUIDE's roadmap line leaves out the DRO identity, and the layer map also has the geometry-scaled Jacobi frontier defect. `dwell_lower_bound` is already frozen in v1. Which of the rest go into v3?
- **Recommended answer:** CVaR, KL–Fisher and DRO, as the draft has them. MASTER_GUIDE's roadmap line gains the DRO identity, to match ROADMAP. The Jacobi defect waits, because its statement isn't well-posed yet:
  - JSG I never defines Δ\_fr. It is a commutator across the frontier, a distribution supported on Σ, so ∫‖Δ\_fr(x\_t)‖ dt along a trajectory isn't defined.
  - Its bound adds ‖S‖∞ and ‖∇S‖∞, which have different units, while calling its constants unit-free.
  - Mathlib has no multivector calculus on stratified spaces and no Filippov solutions.
- **What breaks if wrong:** If you want the Jacobi defect in Milestone 3, it needs a definition of Δ\_fr first, then a version of its own; adding it later only adds. If the DRO identity shouldn't be in Milestone 3, drop it before the tag. After the tag, removing it is a weakening.
- **Can it be undone:** Yes, freely until `statements-v3` is tagged. After that, adding a statement is a tightening, and removing one is a weakening: it takes a new version, a CHANGELOG line and a signed decision.

### Q9. State the KL–Fisher bound in whitened coordinates, with κ = ∇ψ?

**Answered 2026-10-28: yes, as recommended,** by tagging `statements-v3` at the draft's head (#50).

- **Question:** JSG I's Theorem 2 measures the cumulants in F⁻¹ but never says which norm its radius and Hessian-Lipschitz constant use. Read in raw coordinates, as jsg-lab does, it is false (the mutant). The draft states it in whitened coordinates: V's inner product is the Fisher metric at 0, so F is the identity, which `hlip` at x = 0 forces. It also takes the cumulants as ψ's gradient (`hgrad`), not as the mean of T under P\_θ. Is that the statement you want?
- **Recommended answer:** Yes, on both counts.
  - **Whitening loses no generality.** Any F ≻ 0 whitens by the change of variables T ↦ F^{−1/2}T. In those coordinates the Euclidean norms are the F and F⁻¹ norms the source writes, and JSG I says its norms are Fisher-induced (line 2243). A general-F form is equivalent, but needs square roots of operators.
  - **On κ:** the source defines κ\_mix = E\_{P\_θ}[T] = ∇ψ(θ). Stating it through ∇ψ avoids integrals valued in V. That the two agree is a standard identity, which Mathlib has in one dimension (`integral_tilted_mul_self`).
- **What breaks if wrong:** If you want the cumulants as the mean ∫ T ∂P\_θ, a corollary has to show the two agree, which takes differentiation under the integral sign in V. It also needs V finite-dimensional and ‖T‖ integrable under P\_θ. If you want general F, a corollary has to transport the bound through F^{1/2}. Either is an addition.
- **Can it be undone:** Yes, freely until the tag. After it, either corollary only adds.

### Q10. State the DRO envelope identity for the dual alone, and duality later?

**Answered 2026-10-28: yes, as recommended,** by tagging `statements-v3` at the draft's head (#50).

- **Question:** JSG II's `thm:rho-sense` says dv/dρ = η\* for v the worst-case risk. The draft states it for the dual value, the infimum over multipliers η of ηρ + g(η), which covers JSG II's KL dual (corrected) and its Wasserstein dual. Strong duality, that this dual equals the worst-case risk, isn't stated. Is that enough for v3?
- **Recommended answer:** Yes. The envelope identity is the property JSG II's 5% check and quarantine hook rely on. Strong duality for KL needs more:
  - **Weak duality is within reach,** from `llr_tilted_right`: E\_Q[ℓ] − η KL(Q‖P) ≤ η log E\_P[e^{ℓ/η}].
  - **Attainment isn't:** the tilted measure has to hit KL = ρ exactly, which is more work.
  - **The smoothed Wasserstein dual isn't the primal at all.** It differs by its smoothing bias.

  The hypothesis is a continuous minimizer selection, not JSG II's uniqueness. Uniqueness suffices when g is convex, as both duals are, but proving that needs Fenchel conjugacy.
- **What breaks if wrong:** Every dual of this shape satisfies the identity, JSG II's own wrong KL dual included. So `dro_envelope` says nothing about whether a dual is the right one, and neither does the finite-difference check built on it. If you need that, it's a duality statement, which only adds.
- **Can it be undone:** Yes. Adding duality later only adds.

### Q5. What should an overspent stage leave for the stages after it?

**Answered 2026-10-27: yes.** Check each stage's own fit as the budget threads through (`Threads`, `threads_spec`); `residual` stays as frozen.

- **Question:** `residual` truncates at 0, and `residual_spec` covers only a first stage that fits (its `hx`). Once a stage overspends, later stages are checked against 0, and a stage of 0 still passes though the total is over θ (the IDEAS.md item this settles). Should v2 make the check fail closed by checking every stage's own fit as the budget threads through? Or should the residual take a value that marks the overspend, as SCp2 §7.4 does with ⊥?
- **Recommended answer:** Check every stage's own fit, as the draft does.
  - **What changes:** `residual` stays as v1 froze it. The new `Threads θ xs` checks each stage against what the earlier ones left, so an overspent stage fails its own check.
  - **The theorem:** `threads_spec` says that, for finite θ, `Threads θ xs` holds exactly when the total is within θ, for any number of stages. That also lifts `residual_spec`'s two-stage limit.
  - **Why not SCp2's ⊥:** its marker fails closed only behind a guard that rejects a ⊥ reading first, because SCp2's order puts ⊥ below every value (the master guide's defect "Unknown sits below every value"). In ENNReal, a residual's ⊥ is 0, which `residual` already returns.
- **What breaks if wrong:** If you want the overspend recorded as a value, for a rejection certificate say, `Threads` doesn't carry it. A later version can add a marked residual beside it, which only adds. Either way no v1 statement changes, and none of the eight Milestone 1 proofs is affected.
- **Can it be undone:** Yes, freely until `statements-v2` is tagged. After that, adding a marked residual is a tightening, but removing `threads_spec` is a weakening: it takes a new version, a CHANGELOG line and a signed decision.

### Q6. Do receipt integrity and the token-bucket invariant belong in statements-v2?

**Answered 2026-10-27: yes.** Neither goes in v2; each waits for the version that first needs it.

- **Question:** The layer map lists receipt integrity (replaying the content at a receipt's address yields its grade) as "Lean now". Core object 4 prices weakenings against a token bucket. Should v2 state either?
- **Recommended answer:** Neither. Each waits for the version that first needs it.
  - **Receipt integrity:** what makes it true is collision resistance and replay determinism. Lean can't check either: both sit in the CI layer, with the determinism envelope and proof_surface replay. A Lean statement would assume a content-addressed store and a deterministic grader, and then hold almost by definition. No Milestone 2 theorem uses it, and the concrete Loader's L10 already binds the receipt bundle to its recorded root.
  - **Token bucket:** its invariant depends on the choice RAILS.md deferred: a refill rate ρ, a cap on each weakening's cumulative duration, or renewal cost escalating by γ. That choice is a Norm-layer value and yours to make first. Neither `expiry_tightens` nor `bridge` depends on it.
- **What breaks if wrong:** If you want either one in Milestone 2, it needs a version of its own sooner, which only adds statements. Nothing frozen changes.
- **Can it be undone:** Yes. This only defers; nothing is frozen.

### Q7. Does a Loader that is generic in its cryptographic primitives count as concrete?

**Answered 2026-10-27: yes.** A Loader concrete in its rules and checks, and generic in its primitives, is the concrete Loader Milestone 2 owes.

- **Question:** v2's Loader has SCp3's rules and checks. But L1–L4 and L10 call a digest, a signature check, a replay and a Merkle root that it takes as parameters (`Prims`), and its two theorems hold for every choice of them. Is that the "concrete Loader (L1–L10)" ROADMAP says Milestone 2 owes?
- **Recommended answer:** Yes. Whether BLAKE3 collides, a signature verifies or a replay is byte-identical is a CI-layer question. What Lean can check is that the rules preserve the ten checks, whatever the primitives do. Milestone 2's note would then say that the Loader is concrete in its rules and checks, and generic in its primitives.
- **What breaks if wrong:** If you want fixed primitives, an executable digest for example, a later version can fix `Prims` and restate the two theorems for it. That is an addition. Until then, Milestone 2's note shouldn't claim more than this.
- **Can it be undone:** Yes, freely until `statements-v2` is tagged. After that, by adding statements.

### Q4. `verdict_unknown` covers only grades that are exactly unknown

**Answered 2026-10-26: yes.** Replace it with `verdict_sound`, which is strictly stronger.

- **Question:** `verdict_unknown` covered only `g i = Bound.unknown`. So [5, ∞], which is what an unknown becomes after combining, and every finite value over its threshold were outside the frozen statements. A gate that rejects only unknowns satisfied all four verdict theorems. Should it be replaced by a statement that any axis over its threshold rejects the whole grade?
- **Recommended answer:** Yes. State it as:

  ```lean
  theorem verdict_sound (θ : ι → ENNReal) (g : Grade ι) (i : ι)
      (hover : θ i < (g i).hi) : verdict θ g = .reject
  ```

  - It implies `verdict_unknown`: an unknown's upper bound is ⊤, so any finite threshold is below it.
  - It also covers [5, ∞] and every finite value over its threshold, so the unknown-only gate fails it: that gate accepts [2, 2] under θ = 1.
  - Checked in a scratch file, not committed: the statement type-checks against the real `Defs` and is provable from them, and both mutants are proved to fail it.
- **What breaks if wrong:** Little. Everything `verdict_unknown` guaranteed still holds, since `verdict_sound` implies it. If a later design must accept a grade whose upper bound is over its threshold, `verdict_sound` has to be weakened, and after the tag that takes a new statements version, a CHANGELOG line and a signed decision. Keeping `verdict_unknown` instead leaves [5, ∞] and every finite overrun outside the frozen statements.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.

### Q2. `bridge` can't fail on its named mutant

**Answered 2026-10-20: yes.** Restate `bridge` over the fixed dial-to-threshold map that stores the inverse.

- **Question:** `bridge` takes thresholds directly, so its named mutant, a threshold dial stored un-inverted, has nothing to plug into and can't fail it. Today's `bridge_mutant` refutes a copy with the hypothesis reversed instead. The guide's core object 4 says "the bridge theorem catches the mistake". Should `bridge` be restated over a dial-to-threshold map, or kept, given a mutant it does catch, and the guide's sentence fixed?
- **Recommended answer:** Restate it. Add a fixed map to `Defs.lean` that stores the inverse, `noncomputable def threshold (dial : ι → ENNReal) : ι → ENNReal := fun i => (dial i)⁻¹`, and state the bridge over dials, larger meaning stricter: `dial₁ ≤ dial₂ → {x | verdict (threshold dial₂) (gradeOf x) = .accept} ⊆ {x | verdict (threshold dial₁) (gradeOf x) = .accept}`.
  - The un-inverted dial (`id` in place of `threshold`) then fails it: with dial₁ = 0 and dial₂ = 1, a grade of 1 is accepted under the stricter dial and rejected under the looser one.
  - ENNReal's inverse fits the dial: 0⁻¹ = ⊤, so dial 0 means no limit, and ⊤⁻¹ = 0.
  - This makes the guide's sentence true rather than deleting it. Today's statement becomes a lemma for the proof.
  - Checked in a scratch file, not committed: the restated statement type-checks against the real `Defs`, and the `id` mutant is proved to fail it.

  The alternative is to keep the statement and name a mutant it catches, such as a verdict that compares the wrong way (accepting when hi ≥ θ), then change the guide so it no longer says the bridge checks the dial encoding.
- **What breaks if wrong:** If restating is wrong, for example because real dials aren't stored per axis in ENNReal, `threshold` has to change, and after the freeze that's a statements change. If keeping is wrong, the bridge stays a fact about `verdict` alone, nothing checks the dial encoding, and the guide claims a check that doesn't exist.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.

### Q3. `mfGate_monotone` covers only histories with no signed removal

**Answered 2026-10-20: yes,** the general form. Whether `mfGate_monotone` stays as a corollary was left to Claude Code; it was dropped (LOG.md).

- **Question:** `mfGate_monotone` assumes `hs : ∀ s, signed s → s = ∅`, so it says nothing once any removal is signed, which is exactly when the gate matters. Should it be replaced by the general form, which follows from `hg` alone: every class that leaves MF leaves in a signed step?
- **Recommended answer:** Yes. State it as:

  ```lean
  theorem mfGate_signed {C : Type} (signed : Set C → Prop) (MF : ℕ → Set C)
      (hg : ∀ t, mfGate signed (MF t) (MF (t + 1))) {s t : ℕ} (hst : s ≤ t) {c : C}
      (hs : c ∈ MF s) (ht : c ∉ MF t) :
      ∃ u, s ≤ u ∧ u < t ∧ c ∈ MF u \ MF (u + 1) ∧ signed (MF u \ MF (u + 1))
  ```

  - This is the layer map's claim, "accepted histories keep every unsigned failure class".
  - `mfGate_monotone` follows as a corollary, so it can stay or go.
  - Either form gets a real mutant from a gate that accepts every change, run on the drafts' history: GOLDEN_RULE_BREACH then leaves in an unsigned step. Today's mutant shows only that the real gate rejects that history, which refutes neither form.
  - Checked in a scratch file, not committed: the statement type-checks, and the loose-gate mutant is proved to fail it.
- **What breaks if wrong:** If the general form is wrong, for instance because a signed removal should also have to expire, the statement records only that the step was signed and would need another change. If you keep today's form, the theorem is silent about every history with a signed removal, and the layer map's claim stays unproved.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.

### Q1. State interchange over two named operators

**Answered 2026-10-13: yes.** Use the two-operator form in the stubs.

- **Question:** Should the statements define interchange as a Prop over two named operators, `Interchange seq par`, with `seqComp` and `parComp` both defined as `combine`, and state `interchange` as `Interchange seqComp parComp`?
- **Recommended answer:** Yes. With one operator, the law follows from `combine_comm` and `combine_assoc`, so it can't fail for any commutative, associative `combine` and catches nothing. With two named operators, JSG V's rule becomes a mutant that can be stated: max on every axis in sequence, `combine` in parallel. On a budget axis with x = 1, x′ = 0, y = 0, y′ = 1, it grades 2 one way and 1 the other.
- **What breaks if wrong:** If yes is the wrong call, the cost is small: two extra definitions in `Defs.lean` that must stay equal to `combine`, and a longer statement to review. If you answer no, `interchange` stays vacuous, and it can't meet the roadmap's rule that every theorem names a mutant that fails it.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.
