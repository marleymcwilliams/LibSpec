import Mathlib

/-! Phase 0 smoke test: proves the toolchain, Mathlib and CI are wired up. -/

namespace JSG.Tests

/-- A trivial theorem that still goes through Mathlib's `ℝ` and `norm_num`. -/
theorem smoke : (1 : ℝ) + 1 = 2 := by norm_num

end JSG.Tests
