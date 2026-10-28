import JSG.Defs
import JSG.Lemmas.KLFisher

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

theorem kl_fisher_local (μ : Measure Ω) [IsProbabilityMeasure μ] (T : Ω → V)
    (κ : V → V) (H : V → V →L[ℝ] V) {L ε : ℝ} {θ : V}
    (hgrad : ∀ x ∈ segment ℝ 0 θ, HasGradientAt (logPartition μ T) (κ x) x)
    (hhess : ∀ x ∈ segment ℝ 0 θ, HasFDerivAt κ (H x) x)
    (hcenter : κ 0 = 0)
    (hlip : ∀ x ∈ segment ℝ 0 θ, ‖H x - 1‖ ≤ L * ‖x‖)
    (hint : θ ∈ interior {x | Integrable (fun ω => Real.exp (inner ℝ x (T ω))) μ})
    (hr : L * ‖θ‖ ≤ ε) (hε : ε ≤ 1) :
    ENNReal.ofReal ((1 - ε) / 2 * ‖κ θ‖ ^ 2) ≤ klDiv (expFamily μ T θ) μ ∧
      klDiv (expFamily μ T θ) μ ≤ ENNReal.ofReal ((1 + ε) / 2 * ‖κ θ‖ ^ 2) := by
  set Y : Ω → ℝ := fun ω => inner ℝ θ (T ω) with hY
  have hseg : ∀ t ∈ Set.Icc (0 : ℝ) 1, t • θ ∈ segment ℝ 0 θ := by
    intro t ht
    rw [segment_eq_image]
    exact ⟨t, ht, by simp⟩
  have hline : ∀ t : ℝ, HasDerivAt (fun s : ℝ => s • θ) θ t := by
    intro t
    simpa using (hasDerivAt_id t).smul_const θ
  have hg : ∀ t ∈ Set.Icc (0 : ℝ) 1,
      HasDerivAt (fun s : ℝ => logPartition μ T (s • θ)) (inner ℝ θ (κ (t • θ))) t := by
    intro t ht
    have h1 := ((hgrad _ (hseg t ht)).hasFDerivAt).comp_hasDerivAt t (hline t)
    rw [InnerProductSpace.toDual_apply_apply, real_inner_comm] at h1
    exact h1
  have hm : ∀ t ∈ Set.Icc (0 : ℝ) 1,
      HasDerivAt (fun s : ℝ => inner ℝ θ (κ (s • θ))) (inner ℝ θ (H (t • θ) θ)) t := by
    intro t ht
    have h1 := (hhess _ (hseg t ht)).comp_hasDerivAt t (hline t)
    have h2 := (hasDerivAt_const t θ).inner ℝ h1
    simp only [inner_zero_left, add_zero] at h2
    exact h2
  have hg0 : logPartition μ T ((0 : ℝ) • θ) = 0 := by simp [logPartition]
  have hm0 : inner ℝ θ (κ ((0 : ℝ) • θ)) = 0 := by simp [hcenter]
  have hcgf : cgf Y μ = fun s : ℝ => logPartition μ T (s • θ) := by
    funext t
    simp [cgf, mgf, logPartition, Y, real_inner_smul_left]
  have h1int : (1 : ℝ) ∈ interior (integrableExpSet Y μ) := by
    have hcont : Continuous fun t : ℝ => t • θ := continuous_id.smul continuous_const
    have hsub : (fun t : ℝ => t • θ) ⁻¹'
        interior {x | Integrable (fun ω => Real.exp (inner ℝ x (T ω))) μ}
          ⊆ integrableExpSet Y μ := by
      intro t ht
      have h3 := interior_subset ht
      simpa [integrableExpSet, Y, real_inner_smul_left] using h3
    refine interior_mono hsub ?_
    rw [(isOpen_interior.preimage hcont).interior_eq]
    simpa using hint
  have hexp : Integrable (fun ω => Real.exp (Y ω)) μ := by
    simpa [integrableExpSet] using interior_subset h1int
  have hYm : AEMeasurable Y μ := by
    have h3 := Real.measurable_log.comp_aemeasurable hexp.aemeasurable
    simpa [Function.comp_def] using h3
  have hYi : Integrable Y (μ.tilted Y) := by
    have h3 := memLp_tilted_mul h1int 1
    simp only [one_mul] at h3
    exact memLp_one_iff_integrable.1 (by simpa using h3)
  have hKL : klDiv (expFamily μ T θ) μ =
      ENNReal.ofReal (inner ℝ θ (κ θ) - logPartition μ T θ) := by
    have h3 := integral_tilted_mul_self h1int
    simp only [one_mul] at h3
    have h4 : deriv (cgf Y μ) 1 = inner ℝ θ (κ θ) := by
      rw [hcgf]
      simpa using (hg 1 ⟨zero_le_one, le_rfl⟩).deriv
    rw [expFamily, klDiv_tilted_self μ hexp hYm hYi, h3, h4]
    simp [logPartition, Y]
  rcases eq_or_ne θ 0 with rfl | hθ0
  · have h0 : klDiv (expFamily μ T 0) μ = 0 := by
      rw [hKL]
      simp [hcenter, logPartition]
    simp [h0, hcenter]
  have hρ : 0 < ‖θ‖ := norm_pos_iff.2 hθ0
  have hL : 0 ≤ L := by
    have h1 := hlip θ (right_mem_segment ℝ 0 θ)
    by_contra hneg
    push Not at hneg
    have : L * ‖θ‖ < 0 := mul_neg_of_neg_of_pos hneg hρ
    linarith [norm_nonneg (H θ - 1)]
  have hh : ∀ t ∈ Set.Icc (0 : ℝ) 1,
      |inner ℝ θ (H (t • θ) θ) - ‖θ‖ ^ 2| ≤ (L * ‖θ‖) * t * ‖θ‖ ^ 2 := by
    intro t ht
    have h1 : inner ℝ θ (H (t • θ) θ) - ‖θ‖ ^ 2 = inner ℝ θ ((H (t • θ) - 1) θ) := by
      simp [inner_sub_right]
    rw [h1]
    calc |inner ℝ θ ((H (t • θ) - 1) θ)| ≤ ‖θ‖ * ‖(H (t • θ) - 1) θ‖ :=
          abs_real_inner_le_norm _ _
      _ ≤ ‖θ‖ * (‖H (t • θ) - 1‖ * ‖θ‖) := by
          gcongr
          exact ContinuousLinearMap.le_opNorm _ _
      _ ≤ ‖θ‖ * ((L * ‖t • θ‖) * ‖θ‖) := by
          gcongr
          exact hlip _ (hseg t ht)
      _ = (L * ‖θ‖) * t * ‖θ‖ ^ 2 := by
          rw [norm_smul, Real.norm_of_nonneg ht.1]
          ring
  obtain ⟨hm1lo, hm1hi, hK0, hKup, hKlo⟩ :=
    kl_ray_bound (sq_pos_of_pos hρ) (hr.trans hε) hg hm hh hg0 hm0
  simp only [one_smul] at hm1lo hm1hi hK0 hKup hKlo
  have hCS : inner ℝ θ (κ θ) ^ 2 ≤ ‖θ‖ ^ 2 * ‖κ θ‖ ^ 2 := by
    have h1 := abs_real_inner_le_norm θ (κ θ)
    rw [← mul_pow, ← sq_abs]
    exact pow_le_pow_left₀ (abs_nonneg _) h1 2
  have hclose : ‖κ θ - θ‖ ≤ L * ‖θ‖ ^ 2 := by
    have hder : ∀ t ∈ Set.Icc (0 : ℝ) 1, HasDerivWithinAt (fun s : ℝ => κ (s • θ) - s • θ)
        (H (t • θ) θ - θ) (Set.Icc 0 1) t := by
      intro t ht
      have h1 := (hhess _ (hseg t ht)).comp_hasDerivAt t (hline t)
      exact (h1.sub (hline t)).hasDerivWithinAt
    have hbound : ∀ t ∈ Set.Ico (0 : ℝ) 1, ‖H (t • θ) θ - θ‖ ≤ L * ‖θ‖ ^ 2 := by
      intro t ht
      have ht' := Set.Ico_subset_Icc_self ht
      calc ‖H (t • θ) θ - θ‖ = ‖(H (t • θ) - 1) θ‖ := by simp
        _ ≤ ‖H (t • θ) - 1‖ * ‖θ‖ := ContinuousLinearMap.le_opNorm _ _
        _ ≤ (L * ‖t • θ‖) * ‖θ‖ := by
            gcongr
            exact hlip _ (hseg t ht')
        _ ≤ L * ‖θ‖ ^ 2 := by
            rw [norm_smul, Real.norm_of_nonneg ht.1]
            have h2 : t ≤ 1 := ht.2.le
            have h3 : 0 ≤ L * ‖θ‖ * ‖θ‖ := by positivity
            nlinarith
    have h1 := norm_image_sub_le_of_norm_deriv_le_segment' hder hbound 1 ⟨zero_le_one, le_rfl⟩
    simpa [hcenter] using h1
  have hnorm : ‖κ θ‖ ^ 2 ≤ (L * ‖θ‖) ^ 2 * ‖θ‖ ^ 2 + 2 * inner ℝ θ (κ θ) - ‖θ‖ ^ 2 := by
    have h1 := norm_sub_sq_real (κ θ) θ
    rw [real_inner_comm] at h1
    have h2 : ‖κ θ - θ‖ ^ 2 ≤ (L * ‖θ‖ ^ 2) ^ 2 := pow_le_pow_left₀ (norm_nonneg _) hclose 2
    nlinarith
  rw [hKL]
  obtain ⟨hlo', hhi'⟩ := kl_algebra hρ hL hr hε hm1lo hm1hi hK0 hKup hKlo hCS hnorm
    (by positivity)
  exact ⟨ENNReal.ofReal_le_ofReal hlo', ENNReal.ofReal_le_ofReal hhi'⟩

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
