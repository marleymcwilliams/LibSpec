import JSG.Defs

/-!
The frozen statements (core v2, from the master guide's Lean stubs). Every definition
they use lives in `JSG.Defs`. Each theorem names a mutant: a plausible wrong
implementation that fails it, proved in `JSG.Tests.Mutants`.
-/

namespace JSG

/-! ## 1. Graded values -/

variable {ι : Type} (kind : ι → Kind)

theorem combine_comm (g h : Grade ι) : combine kind g h = combine kind h g := by sorry
-- Mutant: overwrite, where the later stage's grade replaces the earlier one.

theorem combine_assoc (g h k : Grade ι) :
    combine kind (combine kind g h) k = combine kind g (combine kind h k) := by sorry
-- Mutant: averaging budgets, (a + b) / 2, is commutative but not associative.

/-- Sequential and parallel composition agree: interchange is an equation. -/
theorem interchange : Interchange (seqComp kind) (parComp kind) := by sorry
-- Mutant: JSG V's rule (max on every axis in sequence, + on budgets in parallel).

/-! ## 2. Verdicts and residuals -/

/-- Fail-closed: an unknown axis rejects whenever its threshold is finite. -/
theorem verdict_unknown (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hθ : θ i < ⊤) (hu : g i = Bound.unknown) : verdict θ g = .reject := by sorry
-- Mutant: a verdict that reads `lo` instead of `hi` accepts unknowns.

/-- Completeness: complete evidence within θ is accepted. -/
theorem verdict_complete (θ : ι → ENNReal) (g : Grade ι)
    (hk : ∀ i, (g i).lo = (g i).hi) (hin : ∀ i, (g i).lo ≤ θ i) :
    verdict θ g = .accept := by sorry
-- Mutant: the always-REJECT gate, which satisfies every safety theorem here.

/-- Checking stage two against stage one's residual is checking the total. -/
theorem residual_spec (θ x y : ENNReal) (hθ : θ ≠ ⊤) (hx : x ≤ θ) :
    y ≤ residual θ x ↔ x + y ≤ θ := by sorry
-- Mutant: checking each stage against the full θ accepts x = y = θ.

/-- No confidence inflation: with a noninterfering grader, metrics cannot flip the verdict. -/
theorem no_flip {E : Type} (θ : ι → ENNReal) (gradeOf : Evidence E → Grade ι)
    (hni : Noninterfering gradeOf) (r : E) (m m' : List (String × Float)) :
    verdict θ (gradeOf ⟨r, m⟩) = verdict θ (gradeOf ⟨r, m'⟩) := by
  rw [hni r m m']
-- Mutant: the same grader; Mutants.lean exhibits metrics that flip its verdict.

/-! ## 3. Loader: safety and progress, kept separate -/

/-- Safety: every reachable state satisfies the invariant. -/
theorem Loader.safe {S O : Type} [Preorder O] (L : Loader S O) {s t : S}
    (hs : L.Inv s) (hr : Relation.ReflTransGen L.step s t) : L.Inv t := by sorry
-- Mutant: a step that skips one L-check still terminates but breaks this.

/-- Progress: no infinite run. -/
theorem Loader.terminates {S O : Type} [Preorder O] [WellFoundedLT O]
    (L : Loader S O) : WellFounded (fun t s => L.step s t) := by sorry
-- Mutant: a retry that re-emits the same obligation cannot satisfy `progress`.

/-! ## 4. Frontier charge -/

variable {E : Type} [NormedAddCommGroup E]

/-- Additive under concatenation, so regrouping can't change it. -/
theorem charge_append (A : ENNReal) (j₁ j₂ : List E) :
    charge A (j₁ ++ j₂) = charge A j₁ + charge A j₂ := by sorry
-- Mutant: v1's merged-jump charge A · ‖Σ jumps‖, under which [v] ++ [-v] costs 0
-- but [v] and [-v] cost 2A‖v‖.

/-- Chattering is never free. -/
theorem charge_chatter (A : ENNReal) (v : E) :
    charge A [v, -v] = 2 * A * (‖v‖₊ : ENNReal) := by sorry
-- Mutant: v1's merged-jump charge, under which (v, -v) costs 0.

/-! ## 5. Policy lattice -/

variable {P : Type} [CompleteLattice P]   -- larger = stricter

/-- Expiry can only make the policy stricter. -/
theorem expiry_tightens (B : P) {a a' : Set P} (h : a' ⊆ a) :
    effective B a ≤ effective B a' := by sorry
-- Mutant: "revert to the most recent policy", which can land on a weaker one.

/-- The bridge: tighter thresholds never admit more inputs. -/
theorem bridge {Inp : Type} (gradeOf : Inp → Grade ι) {θ₁ θ₂ : ι → ENNReal}
    (h : θ₂ ≤ θ₁) :
    {x | verdict θ₂ (gradeOf x) = .accept} ⊆ {x | verdict θ₁ (gradeOf x) = .accept} := by sorry
-- Mutant: a threshold dial stored un-inverted, so "stricter" raises θ.

theorem fold_check_vacuous (Rmax lam : ℝ) (h : 0 ≤ Rmax) (rs : List ℝ) :
    fold Rmax lam rs ≤ Rmax := by sorry
-- Mutant: the uncapped fold, a plain weighted sum, whose nightly check can fail;
-- the cap is what makes the check vacuous.

/-! ## 6. Calibration -/

/-- Every history the gate accepts, with no signed removals, only grows. -/
theorem mfGate_monotone {C : Type} (signed : Set C → Prop) (MF : ℕ → Set C)
    (hg : ∀ t, mfGate signed (MF t) (MF (t + 1)))
    (hs : ∀ s, signed s → s = ∅) : Monotone MF := by sorry
-- Mutant: Draft0–7's history, which dropped GOLDEN_RULE_BREACH with nothing signed. That class
-- sits outside the v1 gate (decisions/RAILS.md); the history still breaks the gate's rule.

/-! ## 7. No-Zeno kernel (analysis layer, corrected form) -/

/-- If the signed distance moves no faster than `Smax`,
    going from `+r` to `-r` takes at least `2r / Smax`. -/
theorem dwell_lower_bound {d : ℝ → ℝ} {Smax r t₁ t₂ : ℝ} (hS : 0 < Smax)
    (hlip : ∀ s t, |d t - d s| ≤ Smax * |t - s|)
    (h₁ : d t₁ = r) (h₂ : d t₂ = -r) (ht : t₁ ≤ t₂) :
    2 * r / Smax ≤ t₂ - t₁ := by sorry
-- Mutant: JSG I's version, which assumes |ḋ| ≥ α at the frontier instead of a speed
-- bound; a trajectory with |ḋ| = 100α crosses far faster than the claimed τ_min.

end JSG
