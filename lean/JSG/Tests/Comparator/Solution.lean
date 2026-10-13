import JSG.Tests.Comparator.Defs

/-! Comparator self-test, a correct solution: the same statement under the same name,
with a different proof. Comparator must accept it. -/

namespace JSG.Tests.ComparatorSelfTest

theorem double_eq (n : Nat) : double n = 2 * n := by
  unfold double
  exact (Nat.two_mul n).symm

end JSG.Tests.ComparatorSelfTest
