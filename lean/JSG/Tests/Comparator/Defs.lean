/-!
Comparator self-test, shared definitions. The challenge and every solution import
this module, so the definitions are the same constants on both sides, exactly as
`JSG.Defs` is shared by `JSG.Statements` and the proofs.
-/

namespace JSG.Tests.ComparatorSelfTest

/-- Doubling, defined once and shared. -/
def double (n : Nat) : Nat := n + n

end JSG.Tests.ComparatorSelfTest
