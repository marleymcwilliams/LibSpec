import JSG.Defs

/-!
Milestone 2 proofs: obligations and leases, the Loader, the frontier charge, the policy
lattice and the must-fail gate. Each theorem restates its frozen statement in
`JSG.Statements` under the same name, and CI's Comparator run checks that it proves
exactly that statement.
-/

namespace JSG

variable {ι : Type} (kind : ι → Kind)
variable {E : Type} [NormedAddCommGroup E]
variable {P : Type} [CompleteLattice P]   -- larger = stricter
variable {St O W : Type}
variable {Bytes D : Type}

theorem Loader.safe {S O : Type} [Preorder O] (L : Loader S O) {s t : S}
    (hs : L.Inv s) (hr : Relation.ReflTransGen L.step s t) : L.Inv t := by
  induction hr with
  | refl => exact hs
  | tail _ hst ih => exact L.inv_step _ _ ih hst

theorem Loader.terminates {S O : Type} [Preorder O] [WellFoundedLT O]
    (L : Loader S O) : WellFounded (fun t s => L.step s t) :=
  Subrelation.wf (fun {t s} h => L.progress s t h)
    (InvImage.wf L.pending Multiset.wellFounded_isDershowitzMannaLT)

theorem charge_append (A : ENNReal) (j₁ j₂ : List E) :
    charge A (j₁ ++ j₂) = charge A j₁ + charge A j₂ := by
  unfold charge
  rw [List.map_append, List.sum_append, mul_add]

theorem charge_chatter (A : ENNReal) (v : E) :
    charge A [v, -v] = 2 * A * (‖v‖₊ : ENNReal) := by
  simp only [charge, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, nnnorm_neg,
    add_zero]
  ring

theorem expiry_tightens (B : P) {a a' : Set P} (h : a' ⊆ a) :
    effective B a ≤ effective B a' := by
  unfold effective
  gcongr

theorem bridge {Inp : Type} (gradeOf : Inp → Grade ι) {dial₁ dial₂ : ι → ENNReal}
    (h : dial₁ ≤ dial₂) :
    {x | verdict (threshold dial₂) (gradeOf x) = .accept}
      ⊆ {x | verdict (threshold dial₁) (gradeOf x) = .accept} := by
  intro x hx
  change verdict (threshold dial₂) (gradeOf x) = .accept at hx
  change verdict (threshold dial₁) (gradeOf x) = .accept
  unfold verdict at hx ⊢
  split_ifs at hx with h₂
  split_ifs with h₁
  · rfl
  · exact absurd (fun i => (h₂ i).trans (ENNReal.inv_le_inv.mpr (h i))) h₁

theorem mfGate_signed {C : Type} (signed : Set C → Prop) (MF : ℕ → Set C)
    (hg : ∀ t, mfGate signed (MF t) (MF (t + 1))) {s t : ℕ} (hst : s ≤ t) {c : C}
    (hs : c ∈ MF s) (ht : c ∉ MF t) :
    ∃ u, s ≤ u ∧ u < t ∧ c ∈ MF u \ MF (u + 1) ∧ signed (MF u \ MF (u + 1)) := by
  induction t, hst using Nat.le_induction with
  | base => exact absurd hs ht
  | succ t hst ih =>
    by_cases hct : c ∈ MF t
    · refine ⟨t, hst, Nat.lt_succ_self t, ⟨hct, ht⟩, ?_⟩
      rcases hg t with hsub | hsig
      · exact absurd (hsub hct) ht
      · exact hsig
    · obtain ⟨u, hsu, hut, hmem, hsig⟩ := ih hct
      exact ⟨u, hsu, Nat.lt_succ_of_lt hut, hmem, hsig⟩

theorem lease_sound (θ β : ι → ENNReal) (g : Grade ι) (i : ι)
    (hout : θ i < (g i).hi ∨ β i < (g i).width) : leaseVerdict θ β g = .reject := by
  unfold leaseVerdict
  split_ifs with h
  · rcases hout with hθ | hβ
    · exact absurd (h i).1 (not_le.mpr hθ)
    · exact absurd (h i).2 (not_le.mpr hβ)
  · rfl

theorem lease_complete (θ β : ι → ENNReal) (g : Grade ι) (hlease : WithinLease β g)
    (hin : ∀ i, (g i).hi ≤ θ i) : leaseVerdict θ β g = .accept := by
  unfold leaseVerdict
  split_ifs with h
  · rfl
  · exact absurd (fun i => ⟨hin i, hlease i⟩) h

theorem pass_sound (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (stages : Multiset St)
    (carried : Multiset O) (pre post : List (StageRun ι St O W)) (r : StageRun ι St O W)
    (hpass : Passes kind θ β M stages carried (pre ++ r :: post)) {p : Pending St O}
    (hp : p ∈ pendingAfter M (windowStart stages carried) pre + r.emits.map Pending.obl) :
    ∃ s ∈ r :: post, M.Clears s p := by
  classical
  obtain ⟨-, hzero⟩ := hpass
  unfold pendingAfter at hzero hp
  rw [List.foldl_append, List.foldl_cons] at hzero
  -- An item still pending before a run that ends with nothing pending is cleared in it.
  have key : ∀ (rest : List (StageRun ι St O W)) (Q : Multiset (Pending St O)),
      p ∈ Q → rest.foldl (afterStage M) Q = 0 → ∃ s ∈ rest, M.Clears s p := by
    intro rest
    induction rest with
    | nil =>
      intro Q hQ h0
      simp only [List.foldl_nil] at h0
      simp [h0] at hQ
    | cons s rest ih =>
      intro Q hQ h0
      by_cases hc : M.Clears s p
      · exact ⟨s, List.mem_cons_self .., hc⟩
      · rw [List.foldl_cons] at h0
        have hQ' : p ∈ afterStage M Q s := by
          unfold afterStage
          exact Multiset.mem_filter.mpr ⟨Multiset.mem_add.mpr (Or.inl hQ), hc⟩
        obtain ⟨s', hs', h'⟩ := ih _ hQ' h0
        exact ⟨s', List.mem_cons_of_mem _ hs', h'⟩
  by_cases hc : M.Clears r p
  · exact ⟨r, List.mem_cons_self .., hc⟩
  · have hmem :
        p ∈ afterStage M (List.foldl (afterStage M) (windowStart stages carried) pre) r := by
      unfold afterStage
      exact Multiset.mem_filter.mpr ⟨hp, hc⟩
    obtain ⟨s, hs, hcs⟩ := key post _ hmem hzero
    exact ⟨s, List.mem_cons_of_mem _ hs, hcs⟩

theorem pass_complete (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (stages : Multiset St)
    (carried : Multiset O) (pre : List (StageRun ι St O W)) (r : StageRun ι St O W)
    (hgrade : leaseVerdict θ β (windowGrade kind (pre ++ [r])) = .accept)
    (hlast : ∀ p ∈ pendingAfter M (windowStart stages carried) pre + r.emits.map Pending.obl,
      M.Clears r p) :
    Passes kind θ β M stages carried (pre ++ [r]) := by
  classical
  refine ⟨hgrade, ?_⟩
  unfold pendingAfter at hlast ⊢
  rw [List.foldl_append, List.foldl_cons, List.foldl_nil]
  unfold afterStage
  exact Multiset.filter_eq_nil.mpr fun p hp => not_not.mpr (hlast p hp)

theorem LoaderStep.inv_step (prims : Prims Bytes D) (M : DischargeMatrix St O W)
    (s t : LoaderState ι St O Bytes D) (hs : LoaderInv kind prims s)
    (h : LoaderStep kind prims M s t) : LoaderInv kind prims t := by
  cases h with
  | stage r rows ε receipt hprice hiso hround hbudget hticket =>
    obtain ⟨h1, h2, h3, h4, h5, h6, h7, -, -, -⟩ := hs
    refine ⟨h1, h2, h3, h4, h5, ?_, h7, hround, hbudget, rfl⟩
    rintro ⟨st, i⟩ (hp | ⟨hp1, hp2⟩)
    · exact h6 _ hp
    · simp only at hp1 hp2 ⊢
      subst hp1
      exact hiso i hp2

theorem LoaderStep.progress [Preorder O] (prims : Prims Bytes D) (M : DischargeMatrix St O W)
    (s t : LoaderState ι St O Bytes D) (h : LoaderStep kind prims M s t) :
    Multiset.IsDershowitzMannaLT t.pending s.pending := by
  cases h with
  | stage r rows ε receipt hprice hiso hround hbudget hticket =>
    show Multiset.IsDershowitzMannaLT (afterStage M s.pending r) s.pending
    unfold afterStage
    classical
    refine ⟨s.pending.filter (fun p => ¬ M.Clears r p),
      (r.emits.map Pending.obl).filter (fun p => ¬ M.Clears r p),
      s.pending.filter (fun p => M.Clears r p), ?_, ?_, ?_, ?_⟩
    · intro hZ
      have hmem : Pending.ticket r.stage ∈ s.pending.filter (fun p => M.Clears r p) :=
        Multiset.mem_filter.mpr ⟨hticket, rfl⟩
      rw [hZ] at hmem
      simp at hmem
    · exact Multiset.filter_add ..
    · rw [add_comm]
      exact (Multiset.filter_add_not ..).symm
    · intro y hy
      obtain ⟨hy1, -⟩ := Multiset.mem_filter.mp hy
      obtain ⟨e, -, rfl⟩ := Multiset.mem_map.mp hy1
      refine ⟨Pending.ticket r.stage, Multiset.mem_filter.mpr ⟨hticket, rfl⟩, ?_⟩
      show (e : WithTop O) < ⊤
      exact WithTop.coe_lt_top e

theorem threads_spec (θ : ENNReal) (hθ : θ ≠ ⊤) (xs : List ENNReal) :
    Threads θ xs ↔ xs.sum ≤ θ := by
  induction xs generalizing θ with
  | nil => simp [Threads]
  | cons x xs ih =>
    have hres : residual θ x ≠ ⊤ := ne_top_of_le_ne_top hθ tsub_le_self
    show (x ≤ θ ∧ Threads (residual θ x) xs) ↔ (x :: xs).sum ≤ θ
    rw [ih (residual θ x) hres, List.sum_cons]
    unfold residual
    constructor
    · rintro ⟨hx, hs⟩
      calc x + xs.sum ≤ x + (θ - x) := add_le_add le_rfl hs
        _ = θ := add_tsub_cancel_of_le hx
    · intro h
      have hx : x ≤ θ := le_trans le_self_add h
      exact ⟨hx, (ENNReal.le_sub_iff_add_le_left (ne_top_of_le_ne_top hθ hx) hx).mpr h⟩

end JSG
