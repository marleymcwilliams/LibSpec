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

end JSG
