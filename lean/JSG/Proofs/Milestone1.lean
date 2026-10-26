import JSG.Defs

/-!
Milestone 1 proofs: the algebraic core. Each theorem restates its frozen statement in
`JSG.Statements` under the same name, and CI's Comparator run checks that it proves
exactly that statement.
-/

namespace JSG

variable {ι : Type} (kind : ι → Kind)

theorem combine_comm (g h : Grade ι) : combine kind g h = combine kind h g := by
  ext i
  all_goals
  · rw[combine, combine]
    cases kind i
    · apply max_comm
    · apply add_comm

theorem combine_assoc (g h k : Grade ι) :
    combine kind (combine kind g h) k = combine kind g (combine kind h k) := by
  funext i
  simp only [combine]
  cases kind i
  · exact Bound.ext (max_assoc _ _ _) (max_assoc _ _ _)
  · exact Bound.ext (add_assoc _ _ _) (add_assoc _ _ _)

theorem interchange : Interchange (seqComp kind) (parComp kind) := by
  intro a b c d
  funext i
  simp only [seqComp, parComp, combine]
  cases kind i
  · exact Bound.ext (max_max_max_comm _ _ _ _) (max_max_max_comm _ _ _ _)
  · exact Bound.ext (add_add_add_comm _ _ _ _) (add_add_add_comm _ _ _ _)

theorem verdict_sound (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hover : θ i < (g i).hi) : verdict θ g = .reject := by
  unfold verdict
  split_ifs with h
  · exact absurd (h i) (not_le.mpr hover)
  · rfl

theorem verdict_complete (θ : ι → ENNReal) (g : Grade ι)
    (hk : ∀ i, (g i).lo = (g i).hi) (hin : ∀ i, (g i).lo ≤ θ i) :
    verdict θ g = .accept := by
  unfold verdict
  split_ifs with h
  · rfl
  · exact absurd (fun i => by rw [← hk i]; exact hin i) h

theorem residual_spec (θ x y : ENNReal) (hθ : θ ≠ ⊤) (hx : x ≤ θ) :
    y ≤ residual θ x ↔ x + y ≤ θ := by
  unfold residual
  exact ENNReal.le_sub_iff_add_le_left (ne_top_of_le_ne_top hθ hx) hx

theorem no_flip {E : Type} (θ : ι → ENNReal) (gradeOf : Evidence E → Grade ι)
    (hni : Noninterfering gradeOf) (r : E) (m m' : List (String × Float)) :
    verdict θ (gradeOf ⟨r, m⟩) = verdict θ (gradeOf ⟨r, m'⟩) := by
  rw [hni r m m']

theorem fold_check_vacuous (Rmax lam : ℝ) (h : 0 ≤ Rmax) (rs : List ℝ) :
    fold Rmax lam rs ≤ Rmax := by
  unfold fold
  induction rs using List.reverseRecOn with
  | nil => simpa using h
  | append_singleton l y _ =>
    rw [List.foldl_append, List.foldl_cons, List.foldl_nil]
    exact min_le_left _ _

end JSG
