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

theorem verdict_sound (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hover : θ i < (g i).hi) : verdict θ g = .reject := by
  unfold verdict
  split_ifs with h
  · exact absurd (h i) (not_le.mpr hover)
  · rfl

theorem no_flip {E : Type} (θ : ι → ENNReal) (gradeOf : Evidence E → Grade ι)
    (hni : Noninterfering gradeOf) (r : E) (m m' : List (String × Float)) :
    verdict θ (gradeOf ⟨r, m⟩) = verdict θ (gradeOf ⟨r, m'⟩) := by
  rw [hni r m m']

end JSG
