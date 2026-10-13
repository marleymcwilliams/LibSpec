import JSG.Tests.Comparator.Defs

/-! Comparator self-test, the frozen statement. Comparator compares statements only,
so the challenge may carry any proof. -/

namespace JSG.Tests.ComparatorSelfTest

theorem double_eq (n : Nat) : double n = 2 * n := by
  unfold double
  omega

end JSG.Tests.ComparatorSelfTest
