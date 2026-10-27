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

end JSG
