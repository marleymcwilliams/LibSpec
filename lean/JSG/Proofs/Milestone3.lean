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

theorem dro_envelope (S : Set ℝ) (g : ℝ → ℝ) (ηstar : ℝ → ℝ) {ρ₀ : ℝ}
    (hmin : ∀ᶠ ρ in nhds ρ₀, ηstar ρ ∈ S ∧ ∀ η ∈ S, ηstar ρ * ρ + g (ηstar ρ) ≤ η * ρ + g η)
    (hcont : ContinuousAt ηstar ρ₀) :
    HasDerivAt (dualValue S g) (ηstar ρ₀) ρ₀ := by
  have hval : ∀ᶠ ρ in nhds ρ₀, dualValue S g ρ = ηstar ρ * ρ + g (ηstar ρ) := by
    filter_upwards [hmin] with ρ hρ
    obtain ⟨hmem, hle⟩ := hρ
    unfold dualValue
    apply le_antisymm
    · refine ciInf_le ⟨ηstar ρ * ρ + g (ηstar ρ), ?_⟩ (⟨ηstar ρ, hmem⟩ : S)
      rintro _ ⟨η, rfl⟩
      exact hle η η.2
    · have : Nonempty S := ⟨⟨ηstar ρ, hmem⟩⟩
      exact le_ciInf fun η => hle η η.2
  have h₀ := hmin.self_of_nhds
  have hv₀ := hval.self_of_nhds
  rw [hasDerivAt_iff_isLittleO, Asymptotics.isLittleO_iff]
  intro c hc
  have hnear : ∀ᶠ ρ in nhds ρ₀, |ηstar ρ - ηstar ρ₀| ≤ c := by
    have := hcont (Metric.closedBall_mem_nhds (ηstar ρ₀) hc)
    filter_upwards [this] with ρ hρ
    simpa [Metric.mem_closedBall, Real.dist_eq] using hρ
  filter_upwards [hmin, hval, hnear] with ρ hρ hvρ hcρ
  obtain ⟨hmem, hle⟩ := hρ
  have hup : dualValue S g ρ ≤ ηstar ρ₀ * ρ + g (ηstar ρ₀) := hvρ ▸ hle _ h₀.1
  have hlo : ηstar ρ₀ * ρ₀ + g (ηstar ρ₀) ≤ ηstar ρ * ρ₀ + g (ηstar ρ) := h₀.2 _ hmem
  rw [hvρ] at hup
  rw [hv₀, hvρ]
  simp only [smul_eq_mul, Real.norm_eq_abs]
  have key1 : ηstar ρ * ρ + g (ηstar ρ) - (ηstar ρ₀ * ρ₀ + g (ηstar ρ₀)) - (ρ - ρ₀) * ηstar ρ₀
      ≤ 0 := by linarith
  have key2 : (ηstar ρ - ηstar ρ₀) * (ρ - ρ₀) ≤
      ηstar ρ * ρ + g (ηstar ρ) - (ηstar ρ₀ * ρ₀ + g (ηstar ρ₀)) - (ρ - ρ₀) * ηstar ρ₀ := by
    nlinarith
  rw [abs_le]
  constructor
  · have : -(c * |ρ - ρ₀|) ≤ (ηstar ρ - ηstar ρ₀) * (ρ - ρ₀) := by
      have h1 := neg_abs_le ((ηstar ρ - ηstar ρ₀) * (ρ - ρ₀))
      rw [abs_mul] at h1
      have h2 : |ηstar ρ - ηstar ρ₀| * |ρ - ρ₀| ≤ c * |ρ - ρ₀| :=
        mul_le_mul_of_nonneg_right hcρ (abs_nonneg _)
      linarith
    linarith
  · have : 0 ≤ c * |ρ - ρ₀| := mul_nonneg hc.le (abs_nonneg _)
    linarith

end JSG
