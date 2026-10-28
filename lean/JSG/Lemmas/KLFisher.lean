import Mathlib

/-!
Helper lemmas for `kl_fisher_local` (Milestone 3): the KL divergence of a tilted measure, the
one-dimensional bound along the ray from 0 to θ, and the closing algebra.
`JSG.Proofs.Milestone3` imports this module, so the axiom audit reaches it through
`JSG.Solution`.
-/

namespace JSG

open MeasureTheory InformationTheory

variable {Ω : Type} [MeasurableSpace Ω]

/-- The KL divergence of a tilted probability measure from its base: for μ tilted by f, the
    mean of f under the tilted measure, minus log E_μ[e^f]. -/
lemma klDiv_tilted_self (μ : Measure Ω) [IsProbabilityMeasure μ] {f : Ω → ℝ}
    (hexp : Integrable (fun ω => Real.exp (f ω)) μ) (hf : AEMeasurable f μ)
    (hfi : Integrable f (μ.tilted f)) :
    klDiv (μ.tilted f) μ =
      ENNReal.ofReal (∫ ω, f ω ∂(μ.tilted f) - Real.log (∫ ω, Real.exp (f ω) ∂μ)) := by
  have : IsProbabilityMeasure (μ.tilted f) := isProbabilityMeasure_tilted hexp
  have hac : μ.tilted f ≪ μ := tilted_absolutelyContinuous μ f
  have h1 : llr (μ.tilted f) μ =ᵐ[μ] fun ω => f ω - Real.log (∫ z, Real.exp (f z) ∂μ) := by
    filter_upwards [llr_tilted_left (Measure.AbsolutelyContinuous.refl μ) hexp hf, llr_self μ]
      with ω h1 h2
    rw [h1, h2]
    simp
  have h2 : llr (μ.tilted f) μ =ᵐ[μ.tilted f]
      fun ω => f ω - Real.log (∫ z, Real.exp (f z) ∂μ) := hac.ae_le h1
  have hint : Integrable (llr (μ.tilted f) μ) (μ.tilted f) :=
    (hfi.sub (integrable_const _)).congr h2.symm
  rw [klDiv_of_ac_of_integrable hac hint, integral_congr_ae h2,
    integral_sub hfi (integrable_const _)]
  simp

/-- The one-dimensional core of `kl_fisher_local`. On [0, 1], let g have derivative m, and m
    derivative h within δ·t·r2 of r2, with g(0) = m(0) = 0 and δ ≤ 1. Then m(1) is within
    r2(1 ± δ/2), and K = m(1) − g(1) is nonnegative with
    K(1 − δ/2)(2 r2) ≤ m(1)² ≤ K(1 + δ/2)(2 r2), by Cauchy's mean value theorem. -/
lemma kl_ray_bound {g m h : ℝ → ℝ} {r2 δ : ℝ} (hr2 : 0 < r2) (hδ1 : δ ≤ 1)
    (hg : ∀ t ∈ Set.Icc (0 : ℝ) 1, HasDerivAt g (m t) t)
    (hm : ∀ t ∈ Set.Icc (0 : ℝ) 1, HasDerivAt m (h t) t)
    (hh : ∀ t ∈ Set.Icc (0 : ℝ) 1, |h t - r2| ≤ δ * t * r2)
    (hg0 : g 0 = 0) (hm0 : m 0 = 0) :
    r2 * (1 - δ / 2) ≤ m 1 ∧ m 1 ≤ r2 * (1 + δ / 2) ∧ 0 ≤ m 1 - g 1 ∧
      (m 1 - g 1) * (1 - δ / 2) * (2 * r2) ≤ m 1 ^ 2 ∧
      m 1 ^ 2 ≤ (m 1 - g 1) * (1 + δ / 2) * (2 * r2) := by
  have hcm : ContinuousOn m (Set.Icc 0 1) :=
    fun t ht => (hm t ht).continuousAt.continuousWithinAt
  have hcg : ContinuousOn g (Set.Icc 0 1) :=
    fun t ht => (hg t ht).continuousAt.continuousWithinAt
  have hlo : ∀ t ∈ Set.Icc (0 : ℝ) 1, r2 * (t - δ * (t * t) / 2) ≤ m t := by
    intro t ht
    refine image_le_of_deriv_right_le_deriv_boundary
      (f := fun t => r2 * (t - δ * (t * t) / 2)) (f' := fun t => r2 * (1 - δ * t))
      (B := m) (B' := h) ?_ ?_ ?_ hcm ?_ ?_ ht
    · exact (by fun_prop : Continuous fun t : ℝ => r2 * (t - δ * (t * t) / 2)).continuousOn
    · intro x _
      have h1 := ((hasDerivAt_id' x).sub
        ((((hasDerivAt_id' x).mul (hasDerivAt_id' x)).const_mul δ).div_const 2)).const_mul r2
      exact (h1.congr_deriv (by ring)).hasDerivWithinAt
    · simp [hm0]
    · intro x hx
      exact (hm x (Set.Ico_subset_Icc_self hx)).hasDerivWithinAt
    · intro x hx
      have h1 := (abs_le.1 (hh x (Set.Ico_subset_Icc_self hx))).1
      nlinarith
  have hhi : ∀ t ∈ Set.Icc (0 : ℝ) 1, m t ≤ r2 * (t + δ * (t * t) / 2) := by
    intro t ht
    refine image_le_of_deriv_right_le_deriv_boundary
      (f := m) (f' := h)
      (B := fun t => r2 * (t + δ * (t * t) / 2)) (B' := fun t => r2 * (1 + δ * t)) hcm ?_ ?_ ?_
      ?_ ?_ ht
    · intro x hx
      exact (hm x (Set.Ico_subset_Icc_self hx)).hasDerivWithinAt
    · simp [hm0]
    · exact (by fun_prop : Continuous fun t : ℝ => r2 * (t + δ * (t * t) / 2)).continuousOn
    · intro x _
      have h1 := ((hasDerivAt_id' x).add
        ((((hasDerivAt_id' x).mul (hasDerivAt_id' x)).const_mul δ).div_const 2)).const_mul r2
      exact (h1.congr_deriv (by ring)).hasDerivWithinAt
    · intro x hx
      have h1 := (abs_le.1 (hh x (Set.Ico_subset_Icc_self hx))).2
      nlinarith
  have hF : ∀ t ∈ Set.Ioo (0 : ℝ) 1, HasDerivAt (fun t => t * m t - g t) (t * h t) t := by
    intro t ht
    have ht' := Set.Ioo_subset_Icc_self ht
    have h1 := ((hasDerivAt_id t).mul (hm t ht')).sub (hg t ht')
    refine h1.congr_deriv ?_
    simp
  have hQ : ∀ t ∈ Set.Ioo (0 : ℝ) 1, HasDerivAt (fun t => m t ^ 2 / 2) (m t * h t) t := by
    intro t ht
    have h1 := ((hm t (Set.Ioo_subset_Icc_self ht)).pow 2).div_const 2
    refine h1.congr_deriv ?_
    simp
    ring
  obtain ⟨ξ, hξ, heq⟩ := exists_ratio_hasDerivAt_eq_ratio_slope (fun t => t * m t - g t)
    (fun t => t * h t) zero_lt_one ((continuousOn_id.mul hcm).sub hcg) hF
    (fun t => m t ^ 2 / 2) (fun t => m t * h t) ((hcm.pow 2).div_const 2) hQ
  simp only [hm0, hg0] at heq
  have hξ' : ξ ∈ Set.Icc (0 : ℝ) 1 := Set.Ioo_subset_Icc_self hξ
  obtain ⟨hξ0, hξ1⟩ := hξ
  have hhξ : 0 < h ξ := by
    have h1 := (abs_le.1 (hh ξ hξ')).1
    have h2 : δ * ξ < 1 := by nlinarith
    nlinarith
  have hmξlo := hlo ξ hξ'
  have hmξhi := hhi ξ hξ'
  have hm1lo := hlo 1 ⟨zero_le_one, le_rfl⟩
  have hm1hi := hhi 1 ⟨zero_le_one, le_rfl⟩
  have hkey : m 1 ^ 2 / 2 * ξ = (m 1 - g 1) * m ξ := by
    have h1 : (m 1 ^ 2 / 2 * ξ) * h ξ = ((m 1 - g 1) * m ξ) * h ξ := by
      have := heq
      ring_nf at this ⊢
      linarith
    exact mul_right_cancel₀ hhξ.ne' h1
  have hmξpos : 0 < m ξ := by
    have h1 : 0 < ξ - δ * (ξ * ξ) / 2 := by nlinarith
    have h2 := mul_pos hr2 h1
    linarith
  have hK0 : 0 ≤ m 1 - g 1 := by
    by_contra hneg
    push Not at hneg
    have : (m 1 - g 1) * m ξ < 0 := mul_neg_of_neg_of_pos hneg hmξpos
    nlinarith [sq_nonneg (m 1)]
  refine ⟨by nlinarith, by nlinarith, hK0, ?_, ?_⟩
  · have h1 : (m 1 - g 1) * (r2 * ξ * (1 - δ / 2)) ≤ (m 1 - g 1) * m ξ := by
      apply mul_le_mul_of_nonneg_left _ hK0
      nlinarith
    have h2 : (m 1 - g 1) * (1 - δ / 2) * (2 * r2) * ξ ≤ m 1 ^ 2 * ξ := by nlinarith
    exact le_of_mul_le_mul_right h2 hξ0
  · have h1 : (m 1 - g 1) * m ξ ≤ (m 1 - g 1) * (r2 * ξ * (1 + δ / 2)) := by
      apply mul_le_mul_of_nonneg_left _ hK0
      nlinarith
    have h2 : m 1 ^ 2 * ξ ≤ (m 1 - g 1) * (1 + δ / 2) * (2 * r2) * ξ := by nlinarith
    exact le_of_mul_le_mul_right h2 hξ0

/-- The polynomial inequality behind `kl_fisher_local`'s lower bound:
    (1 − ε)(δ² + 2A − 1)(1 + δ/2) ≤ A² when 0 ≤ δ ≤ ε ≤ 1 and A ≥ 1 − δ/2. -/
lemma kl_poly {δ ε A : ℝ} (hδ0 : 0 ≤ δ) (hδε : δ ≤ ε) (hε : ε ≤ 1) (hA : 1 - δ / 2 ≤ A) :
    (1 - ε) * (δ ^ 2 + 2 * A - 1) * (1 + δ / 2) ≤ A ^ 2 := by
  have hδ1 : δ ≤ 1 := hδε.trans hε
  have hpos : 0 ≤ (δ ^ 2 + 2 * A - 1) * (1 + δ / 2) := by
    apply mul_nonneg _ (by linarith)
    nlinarith [sq_nonneg (δ - 1 / 2)]
  have h1 : (1 - ε) * (δ ^ 2 + 2 * A - 1) * (1 + δ / 2) ≤
      (1 - δ) * (δ ^ 2 + 2 * A - 1) * (1 + δ / 2) := by
    have := mul_le_mul_of_nonneg_right (show 1 - ε ≤ 1 - δ by linarith) hpos
    linarith [this]
  -- P(A) = P(1 - δ/2) + (A - (1 - δ/2)) * ((A - (1 - δ/2)) + δ ^ 2)
  have hq : 0 ≤ δ ^ 3 - 147 / 100 * δ + 686 / 1000 := by
    nlinarith [mul_nonneg (sq_nonneg (δ - 7 / 10)) (show 0 ≤ δ + 7 / 5 by linarith)]
  have hP0 : 0 ≤ δ * (1 / 2 - 3 / 4 * δ + δ ^ 3 / 2) := by
    apply mul_nonneg hδ0
    nlinarith
  have hstep : 0 ≤ (A - (1 - δ / 2)) * ((A - (1 - δ / 2)) + δ ^ 2) := by
    apply mul_nonneg (by linarith)
    nlinarith
  have hid : A ^ 2 - (1 - δ) * (δ ^ 2 + 2 * A - 1) * (1 + δ / 2) =
      δ * (1 / 2 - 3 / 4 * δ + δ ^ 3 / 2) + (A - (1 - δ / 2)) * ((A - (1 - δ / 2)) + δ ^ 2) := by
    ring
  linarith

/-- The closing algebra of `kl_fisher_local`, in real numbers. From the bounds along the ray
    (`kl_ray_bound`), Cauchy–Schwarz and ‖κ(θ) − θ‖ ≤ Lρ², the gap K lies between
    (1 − ε)/2 and (1 + ε)/2 times n2 = ‖κ(θ)‖². -/
lemma kl_algebra {ρ L ε a K n2 : ℝ} (hρ : 0 < ρ) (hL : 0 ≤ L) (hr : L * ρ ≤ ε) (hε : ε ≤ 1)
    (hm1lo : ρ ^ 2 * (1 - L * ρ / 2) ≤ a) (_hm1hi : a ≤ ρ ^ 2 * (1 + L * ρ / 2))
    (hK0 : 0 ≤ K) (hKup : K * (1 - L * ρ / 2) * (2 * ρ ^ 2) ≤ a ^ 2)
    (hKlo : a ^ 2 ≤ K * (1 + L * ρ / 2) * (2 * ρ ^ 2)) (hCS : a ^ 2 ≤ ρ ^ 2 * n2)
    (hnorm : n2 ≤ (L * ρ) ^ 2 * ρ ^ 2 + 2 * a - ρ ^ 2) (hn2 : 0 ≤ n2) :
    (1 - ε) / 2 * n2 ≤ K ∧ K ≤ (1 + ε) / 2 * n2 := by
  set δ := L * ρ with hδdef
  have hδ0 : 0 ≤ δ := mul_nonneg hL hρ.le
  have hδ1 : δ ≤ 1 := hr.trans hε
  have hρ2 : 0 < ρ ^ 2 := by positivity
  constructor
  · set A := a / ρ ^ 2 with hAdef
    have hA : a = A * ρ ^ 2 := by rw [hAdef, div_mul_cancel₀ a hρ2.ne']
    have hAlo : 1 - δ / 2 ≤ A := by
      rw [hAdef, le_div_iff₀ hρ2]
      linarith
    have hpoly := kl_poly hδ0 hr hε hAlo
    -- n2 ≤ ρ² (δ² + 2A - 1)
    have h1 : n2 ≤ ρ ^ 2 * (δ ^ 2 + 2 * A - 1) := by
      rw [hA] at hnorm
      linarith [hnorm]
    -- A² ρ² ≤ 2 K (1 + δ/2), from a² ≤ K (1 + δ/2) (2ρ²)
    have h2 : A ^ 2 * ρ ^ 2 ≤ 2 * K * (1 + δ / 2) := by
      rw [hA] at hKlo
      have h3 : (A ^ 2 * ρ ^ 2) * ρ ^ 2 ≤ (2 * K * (1 + δ / 2)) * ρ ^ 2 := by
        nlinarith [hKlo]
      exact le_of_mul_le_mul_right h3 hρ2
    -- (1 - ε) ρ² (δ² + 2A - 1) (1 + δ/2) ≤ A² ρ²
    have h4 : (1 - ε) * (ρ ^ 2 * (δ ^ 2 + 2 * A - 1)) * (1 + δ / 2) ≤ A ^ 2 * ρ ^ 2 := by
      have := mul_le_mul_of_nonneg_right hpoly hρ2.le
      nlinarith [this]
    have h5 : (1 - ε) * n2 * (1 + δ / 2) ≤
        (1 - ε) * (ρ ^ 2 * (δ ^ 2 + 2 * A - 1)) * (1 + δ / 2) := by
      apply mul_le_mul_of_nonneg_right _ (by linarith)
      exact mul_le_mul_of_nonneg_left h1 (by linarith)
    have h6 : (1 - ε) * n2 * (1 + δ / 2) ≤ 2 * K * (1 + δ / 2) := by linarith
    have h7 : (1 - ε) * n2 ≤ 2 * K := le_of_mul_le_mul_right h6 (by linarith)
    linarith
  · have h1 : K * (1 - δ / 2) * 2 ≤ n2 := by
      have h2 : (K * (1 - δ / 2) * 2) * ρ ^ 2 ≤ n2 * ρ ^ 2 := by nlinarith [hKup, hCS]
      exact le_of_mul_le_mul_right h2 hρ2
    have h3 : K ≤ (1 + δ) * (K * (1 - δ / 2)) := by
      nlinarith [mul_nonneg hK0 (mul_nonneg hδ0 (sub_nonneg.2 hδ1))]
    have h4 : (1 + δ) * (K * (1 - δ / 2)) ≤ (1 + δ) * (n2 / 2) :=
      mul_le_mul_of_nonneg_left (by linarith) (by linarith)
    have h5 : (1 + δ) * (n2 / 2) ≤ (1 + ε) * (n2 / 2) :=
      mul_le_mul_of_nonneg_right (by linarith) (by linarith)
    linarith

end JSG
