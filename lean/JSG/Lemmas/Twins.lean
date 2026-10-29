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

/-- Truncated subtraction commutes with the cast from ℚ≥0 to ℝ≥0. Mathlib's
    `NNRat.cast_sub` needs a `DivisionRing`, which ℝ≥0 isn't. -/
theorem nnrat_cast_tsub (p q : ℚ≥0) : ((p - q : ℚ≥0) : NNReal) = (p : NNReal) - (q : NNReal) := by
  rcases le_total q p with h | h
  · obtain ⟨d, rfl⟩ := exists_add_of_le h
    simp [NNRat.cast_add]
  · rw [tsub_eq_zero_of_le h, tsub_eq_zero_of_le (NNRat.cast_le.2 h), NNRat.cast_zero]

/-- `xcast` preserves truncated subtraction, ∞ − ∞ = 0 included. -/
theorem xcast_sub (a b : WithTop ℚ≥0) : xcast (a - b) = xcast a - xcast b := by
  induction b using WithTop.recTopCoe with
  | top => simp [WithTop.sub_top, xcast_top, xcast_zero]
  | coe q =>
    induction a using WithTop.recTopCoe with
    | top => simp [xcast_top, xcast_coe]
    | coe p =>
      rw [← WithTop.coe_sub, xcast_coe, xcast_coe, xcast_coe, nnrat_cast_tsub, ENNReal.coe_sub]

end JSG
