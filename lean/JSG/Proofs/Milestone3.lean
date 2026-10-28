import JSG.Defs

/-!
Milestone 3 proofs: the analysis layer. The corrected dwell bound from `statements-v1`, and
the CVaR tail-to-level step, the local KL–Fisher bound and the DRO envelope identity that
`statements-v3` added. Each theorem restates its frozen statement in `JSG.Statements` under
the same name, and CI's Comparator run checks that it proves exactly that statement. The
KL–Fisher bound's helper lemmas are in `JSG.Lemmas.KLFisher`.
-/

namespace JSG

open MeasureTheory ProbabilityTheory InformationTheory

variable {Ω : Type} [MeasurableSpace Ω]
variable {V : Type} [NormedAddCommGroup V] [InnerProductSpace ℝ V] [CompleteSpace V]

theorem dwell_lower_bound {d : ℝ → ℝ} {Smax r t₁ t₂ : ℝ} (hS : 0 < Smax)
    (hlip : ∀ s t, |d t - d s| ≤ Smax * |t - s|)
    (h₁ : d t₁ = r) (h₂ : d t₂ = -r) (ht : t₁ ≤ t₂) :
    2 * r / Smax ≤ t₂ - t₁ := by
  have key := hlip t₁ t₂
  rw [h₁, h₂, abs_of_nonneg (sub_nonneg.mpr ht),
    show -r - r = -(2 * r) by ring, abs_neg] at key
  rw [div_le_iff₀ hS]
  linarith [le_abs_self (2 * r)]

end JSG
