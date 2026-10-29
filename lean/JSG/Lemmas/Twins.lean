import JSG.Defs

/-!
Helper lemmas for Milestone 4: how `xcast`, the cast from `WithTop ℚ≥0` into `ENNReal`,
treats 0, ∞, order, max, + and truncated subtraction.
-/

namespace JSG

/-- `xcast` on an exact rational, by its definition. -/
theorem xcast_coe (q : ℚ≥0) : xcast q = ((q : NNReal) : ENNReal) := rfl

/-- `xcast` sends ∞ to ∞. -/
theorem xcast_top : xcast ⊤ = ⊤ := rfl

/-- `xcast` sends 0 to 0. -/
theorem xcast_zero : xcast 0 = 0 := by
  rw [← WithTop.coe_zero, xcast_coe, NNRat.cast_zero, ENNReal.coe_zero]

end JSG
