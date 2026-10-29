import JSG.Defs

/-!
Milestone 4 proofs: the executable twins that `statements-v4` added, each proved to agree
with its frozen definition. Each theorem restates its frozen statement in `JSG.Statements`
under the same name, and CI's Comparator run checks that it proves exactly that statement.
-/

namespace JSG

variable {ι : Type} (kind : ι → Kind)

theorem xknown_agrees (x : WithTop ℚ≥0) : (XBound.known x).toBound = Bound.known (xcast x) := rfl

end JSG
