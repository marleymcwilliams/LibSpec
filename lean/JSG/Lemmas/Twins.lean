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

/-- `xcast` preserves and reflects order. -/
theorem xcast_le_iff {a b : WithTop ℚ≥0} : xcast a ≤ xcast b ↔ a ≤ b :=
  WithTop.map_le_iff _ NNRat.cast_le

/-- `xcast` preserves max, since it preserves order. -/
theorem xcast_max (a b : WithTop ℚ≥0) : xcast (max a b) = max (xcast a) (xcast b) := by
  rcases le_total a b with h | h
  · rw [max_eq_right h, max_eq_right (xcast_le_iff.2 h)]
  · rw [max_eq_left h, max_eq_left (xcast_le_iff.2 h)]

/-- `xcast` preserves +: ∞ absorbs in both carriers, and finite values add as rationals. -/
theorem xcast_add (a b : WithTop ℚ≥0) : xcast (a + b) = xcast a + xcast b := by
  induction a using WithTop.recTopCoe <;> induction b using WithTop.recTopCoe <;>
    simp [xcast_top, xcast_coe, ← WithTop.coe_add, NNRat.cast_add]

end JSG
