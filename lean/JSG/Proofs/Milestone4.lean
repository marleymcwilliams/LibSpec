import JSG.Defs
import JSG.Lemmas.Twins

/-!
Milestone 4 proofs: the executable twins that `statements-v4` added, each proved to agree
with its frozen definition. Each theorem restates its frozen statement in `JSG.Statements`
under the same name, and CI's Comparator run checks that it proves exactly that statement.
The cast lemmas are in `JSG.Lemmas.Twins`.
-/

namespace JSG

variable {ι : Type} (kind : ι → Kind)

theorem xknown_agrees (x : WithTop ℚ≥0) : (XBound.known x).toBound = Bound.known (xcast x) := rfl

theorem xunknown_agrees : XBound.unknown.toBound = Bound.unknown := by
  ext <;> simp [XBound.toBound, XBound.unknown, Bound.unknown, xcast_zero, xcast_top]

end JSG
