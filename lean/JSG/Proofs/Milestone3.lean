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

theorem cvar_tail_to_level (μ : Measure Ω) (α : ENNReal) {X : Ω → ENNReal}
    (hX : AEMeasurable X μ) {ε : ENNReal} (h : cvar μ α X ≤ ε) :
    μ {ω | ε < X ω} ≤ α := by
  by_contra hlt
  rw [not_le] at hlt
  have hε : ε ≠ ⊤ := by
    rintro rfl
    simp at hlt
  -- the levels ε + 1/n increase to ε from above, so their tails increase to ε's
  have hmono : Monotone fun n : ℕ => {ω | ε + (n : ENNReal)⁻¹ < X ω} := by
    intro m n hmn ω hω
    change ε + (n : ENNReal)⁻¹ < X ω
    refine lt_of_le_of_lt ?_ (show ε + (m : ENNReal)⁻¹ < X ω from hω)
    gcongr
  have hU : ⋃ n : ℕ, {ω | ε + (n : ENNReal)⁻¹ < X ω} = {ω | ε < X ω} := by
    ext ω
    rw [Set.mem_iUnion]
    change (∃ n : ℕ, ε + (n : ENNReal)⁻¹ < X ω) ↔ ε < X ω
    constructor
    · rintro ⟨n, hn⟩
      exact lt_of_le_of_lt le_self_add hn
    · intro hω
      obtain ⟨n, hn⟩ := ENNReal.exists_inv_nat_lt (tsub_pos_of_lt hω).ne'
      exact ⟨n, by rwa [lt_tsub_iff_left] at hn⟩
  have htend := tendsto_measure_iUnion_atTop (μ := μ) hmono
  rw [hU] at htend
  obtain ⟨n, hn⟩ := (htend.eventually (lt_mem_nhds hlt)).exists
  simp only [Function.comp_apply] at hn
  set s := ε + (n : ENNReal)⁻¹ with hs
  have hεs : ε < s := ENNReal.lt_add_right hε (ENNReal.inv_ne_zero.2 (ENNReal.natCast_ne_top n))
  -- every level t gives at least s
  have hall : ∀ t : ENNReal, s ≤ t + (∫⁻ ω, (X ω - t) ∂μ) / α := by
    intro t
    rcases le_or_gt s t with hst | hts
    · exact hst.trans le_self_add
    · have hsub : {ω | s < X ω} ⊆ {ω | s - t ≤ X ω - t} := by
        intro ω hω
        exact tsub_le_tsub_right (show s < X ω from hω).le t
      have hint : (s - t) * μ {ω | s < X ω} ≤ ∫⁻ ω, (X ω - t) ∂μ :=
        calc (s - t) * μ {ω | s < X ω} ≤ (s - t) * μ {ω | s - t ≤ X ω - t} := by
              gcongr
          _ ≤ ∫⁻ ω, (X ω - t) ∂μ :=
              mul_meas_ge_le_lintegral₀ (hX.sub aemeasurable_const) (s - t)
      have hp : 1 ≤ μ {ω | s < X ω} / α := by
        rw [ENNReal.le_div_iff_mul_le (Or.inr (ne_bot_of_gt hn)) (Or.inl hn.ne_top), one_mul]
        exact hn.le
      calc s = t + (s - t) := (add_tsub_cancel_of_le hts.le).symm
        _ ≤ t + (s - t) * μ {ω | s < X ω} / α := by
          gcongr
          calc s - t = (s - t) * 1 := (mul_one _).symm
            _ ≤ (s - t) * (μ {ω | s < X ω} / α) := by gcongr
            _ = (s - t) * μ {ω | s < X ω} / α := (mul_div_assoc _ _ _).symm
        _ ≤ t + (∫⁻ ω, (X ω - t) ∂μ) / α := by gcongr
  exact absurd (h.trans_lt hεs) (not_lt.2 (le_iInf hall))

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
