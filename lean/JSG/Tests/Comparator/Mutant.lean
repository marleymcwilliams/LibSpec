import JSG.Tests.Comparator.Defs

/-! Comparator self-test, the mutant: a weaker statement under the frozen name.
It builds and its proof is complete, so only a statement comparison can catch it.
Comparator must reject it. -/

namespace JSG.Tests.ComparatorSelfTest

theorem double_eq (n : Nat) : double n = n + n := rfl

end JSG.Tests.ComparatorSelfTest
